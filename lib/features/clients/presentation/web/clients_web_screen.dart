import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_empty_state.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/features/clients/domain/client.dart';
import 'package:cheery/features/clients/domain/clients_failure.dart';
import 'package:cheery/features/clients/presentation/controllers/client_form_controller.dart';
import 'package:cheery/features/clients/presentation/controllers/clients_controller.dart';
import 'package:cheery/features/clients/presentation/widgets/client_form_view.dart';
import 'package:cheery/features/clients/presentation/widgets/clients_web_header.dart';
import 'package:cheery/features/clients/presentation/widgets/clients_web_table.dart';
import 'package:cheery/features/whatsapp_automation/presentation/widgets/whatsapp_connect_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClientsWebScreen extends ConsumerStatefulWidget {
  const ClientsWebScreen({super.key});

  @override
  ConsumerState<ClientsWebScreen> createState() => _ClientsWebScreenState();
}

class _ClientsWebScreenState extends ConsumerState<ClientsWebScreen> {
  final _searchController = TextEditingController();
  final _selectedIds = <String>{};
  final _updatingAutomaticIds = <String>{};
  var _page = 0;
  static const _pageSize = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreate() async {
    await ref.read(clientFormControllerProvider.notifier).openCreate();
    if (!mounted) return;
    await showClientFormDialog(context, ref);
  }

  Future<void> _openEdit(Client client) async {
    ref.read(clientFormControllerProvider.notifier).openEdit(client);
    await showClientFormDialog(context, ref);
  }

  Future<void> _confirmDelete(Client client) async {
    await _confirmDeleteIds(
      ids: [client.id],
      title: 'Excluir cliente',
      message: 'Remover ${client.name} da sua lista?',
    );
  }

  Future<void> _confirmBulkDelete() async {
    final count = _selectedIds.length;
    if (count == 0) return;
    await _confirmDeleteIds(
      ids: _selectedIds.toList(),
      title: 'Excluir clientes',
      message: count == 1
          ? 'Remover 1 cliente selecionado?'
          : 'Remover $count clientes selecionados?',
    );
  }

  Future<void> _confirmDeleteIds({
    required List<String> ids,
    required String title,
    required String message,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(clientsControllerProvider.notifier).deleteClients(ids);
      if (!mounted) return;
      setState(() => _selectedIds.removeAll(ids));
    } on ClientsFailure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    }
  }

  void _onImport() {
    context.go(AppRoutes.clientsImport);
  }

  Future<void> _setAutomaticEnabled(Client client, bool enabled) async {
    if (enabled) {
      await showWhatsAppComingSoonDialog(context);
      return;
    }

    setState(() => _updatingAutomaticIds.add(client.id));
    try {
      await ref.read(clientsControllerProvider.notifier).updateClient(
            id: client.id,
            name: client.name,
            phone: client.phone,
            birthDate: client.birthDate,
            templateId: client.templateId,
            automaticEnabled: false,
          );
    } on ClientsFailure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível atualizar a automação.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingAutomaticIds.remove(client.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsControllerProvider);
    final controller = ref.read(clientsControllerProvider.notifier);

    return ColoredBox(
      color: AppColors.background,
      child: clientsAsync.when(
        loading: () => const CheeryLoading(message: 'Carregando clientes...'),
        error: (error, _) => CheeryEmptyState(
          title: 'Não foi possível carregar',
          message: error is ClientsFailure
              ? error.message
              : 'Tente novamente em instantes.',
          icon: Icons.error_outline,
          actionLabel: 'Tentar de novo',
          onAction: () =>
              ref.read(clientsControllerProvider.notifier).refresh(),
        ),
        data: (clients) {
          final totalPages =
              clients.isEmpty ? 1 : ((clients.length - 1) ~/ _pageSize) + 1;
          final safePage = _page.clamp(0, totalPages - 1);
          if (safePage != _page) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _page = safePage);
            });
          }
          final start = clients.isEmpty ? 0 : safePage * _pageSize;
          final end = (start + _pageSize).clamp(0, clients.length);
          final pageItems =
              clients.isEmpty ? const <Client>[] : clients.sublist(start, end);
          final hasAnyClients = controller.hasAnyClients;
          final hasQuery = _searchController.text.trim().isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cherry.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClientsWebHeader(
                          onImport: _onImport,
                          onAdd: _openCreate,
                        ),
                        const SizedBox(height: 24),
                        ClientsWebToolbar(
                          searchController: _searchController,
                          sort: controller.sort,
                          onSortChanged: (sort) {
                            setState(() => _page = 0);
                            ref
                                .read(clientsControllerProvider.notifier)
                                .setSort(sort);
                          },
                          onSearch: (value) {
                            setState(() => _page = 0);
                            ref
                                .read(clientsControllerProvider.notifier)
                                .search(value);
                          },
                        ),
                        const SizedBox(height: 20),
                        if (clients.isEmpty)
                          CheeryEmptyState(
                            title: hasAnyClients || hasQuery
                                ? 'Nenhum resultado'
                                : 'Nenhum cliente ainda',
                            message: hasAnyClients || hasQuery
                                ? 'Tente outro nome ou telefone.'
                                : 'Adicione seu primeiro cliente para começar.',
                            icon: Icons.people_outline,
                            actionLabel:
                                hasAnyClients || hasQuery ? null : 'Adicionar cliente',
                            onAction:
                                hasAnyClients || hasQuery ? null : _openCreate,
                          )
                        else ...[
                          if (_selectedIds.isNotEmpty)
                            ClientsBulkActionsBar(
                              selectedCount: _selectedIds.length,
                              onDelete: _confirmBulkDelete,
                            ),
                          ClientsWebTable(
                            clients: pageItems,
                            selectedIds: _selectedIds,
                            onToggle: (id, selected) {
                              setState(() {
                                if (selected) {
                                  _selectedIds.add(id);
                                } else {
                                  _selectedIds.remove(id);
                                }
                              });
                            },
                            onToggleAll: (selectAll) {
                              setState(() {
                                if (selectAll) {
                                  _selectedIds.addAll(
                                    pageItems.map((c) => c.id),
                                  );
                                } else {
                                  _selectedIds.removeAll(
                                    pageItems.map((c) => c.id),
                                  );
                                }
                              });
                            },
                            onAutomaticChanged: _setAutomaticEnabled,
                            updatingAutomaticIds: _updatingAutomaticIds,
                            onEdit: _openEdit,
                            onDelete: _confirmDelete,
                          ),
                          const SizedBox(height: 16),
                          ClientsPaginationBar(
                            start: start + 1,
                            end: end,
                            total: clients.length,
                            page: safePage + 1,
                            onPrev: safePage > 0
                                ? () => setState(() => _page = safePage - 1)
                                : null,
                            onNext: safePage < totalPages - 1
                                ? () => setState(() => _page = safePage + 1)
                                : null,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
