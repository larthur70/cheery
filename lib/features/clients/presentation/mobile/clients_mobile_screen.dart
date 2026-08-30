import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/core/widgets/cheery_empty_state.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/features/clients/domain/client.dart';
import 'package:cheery/features/clients/domain/clients_failure.dart';
import 'package:cheery/features/clients/domain/clients_sort.dart';
import 'package:cheery/features/clients/presentation/controllers/client_form_controller.dart';
import 'package:cheery/features/clients/presentation/controllers/clients_controller.dart';
import 'package:cheery/features/clients/presentation/mobile/client_form_mobile_screen.dart';
import 'package:cheery/features/clients/presentation/widgets/client_list_card.dart';
import 'package:cheery/features/clients/presentation/widgets/clients_search_field.dart';
import 'package:cheery/features/onboarding/domain/onboarding_anchors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClientsMobileScreen extends ConsumerStatefulWidget {
  const ClientsMobileScreen({super.key});

  @override
  ConsumerState<ClientsMobileScreen> createState() =>
      _ClientsMobileScreenState();
}

class _ClientsMobileScreenState extends ConsumerState<ClientsMobileScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreate() async {
    await ref.read(clientFormControllerProvider.notifier).openCreate();
    if (!mounted) return;
    await showClientFormMobile(context);
  }

  Future<void> _openEdit(Client client) async {
    ref.read(clientFormControllerProvider.notifier).openEdit(client);
    await showClientFormMobile(context);
  }

  Future<void> _confirmDelete(Client client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir cliente'),
        content: Text('Remover ${client.name} da sua lista?'),
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
      await ref.read(clientsControllerProvider.notifier).deleteClient(client.id);
    } on ClientsFailure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        key: OnboardingAnchors.clientsAdd,
        onPressed: _openCreate,
        backgroundColor: AppColors.cherry,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
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
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ClientsSearchField(
                                controller: _searchController,
                                hintText: 'Buscar clientes...',
                                onChanged: (value) => ref
                                    .read(clientsControllerProvider.notifier)
                                    .search(value),
                              ),
                            ),
                            const SizedBox(width: 10),
                            PopupMenuButton<ClientsSort>(
                              tooltip: 'Ordenar',
                              initialValue: ref
                                  .read(clientsControllerProvider.notifier)
                                  .sort,
                              onSelected: (sort) => ref
                                  .read(clientsControllerProvider.notifier)
                                  .setSort(sort),
                              itemBuilder: (context) {
                                final current = ref
                                    .read(clientsControllerProvider.notifier)
                                    .sort;
                                return [
                                  CheckedPopupMenuItem(
                                    value: ClientsSort.birthday,
                                    checked: current == ClientsSort.birthday,
                                    child: const Text('Aniversário'),
                                  ),
                                  CheckedPopupMenuItem(
                                    value: ClientsSort.name,
                                    checked: current == ClientsSort.name,
                                    child: const Text('Nome'),
                                  ),
                                ];
                              },
                              child: Material(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                                child: const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Icon(
                                    Icons.sort,
                                    color: AppColors.cherry,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CheeryButton(
                          key: OnboardingAnchors.clientsImportContacts,
                          label: 'Importar contatos',
                          icon: Icons.contacts_outlined,
                          variant: CheeryButtonVariant.outlined,
                          onPressed: () =>
                              context.push(AppRoutes.clientsImportContacts),
                          expanded: true,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Importar planilha disponível na versão web',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.inkMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Clientes',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppColors.cherry,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              ref
                                          .read(clientsControllerProvider.notifier)
                                          .clientCount ==
                                      clients.length
                                  ? '${clients.length} Total'
                                  : '${clients.length} encontrados · '
                                      '${ref.read(clientsControllerProvider.notifier).clientCount} Total',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.inkMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                if (clients.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: CheeryEmptyState(
                      title: 'Nenhum cliente ainda',
                      message: 'Toque em + para adicionar seu primeiro cliente.',
                      icon: Icons.people_outline,
                      actionLabel: 'Adicionar cliente',
                      onAction: _openCreate,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList.separated(
                      itemCount: clients.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final client = clients[index];
                        return ClientListCard(
                          client: client,
                          onEdit: () => _openEdit(client),
                          onDelete: () => _confirmDelete(client),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
