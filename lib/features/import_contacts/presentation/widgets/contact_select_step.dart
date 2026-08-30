import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/core/widgets/cheery_empty_state.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/features/clients/presentation/controllers/clients_controller.dart';
import 'package:cheery/features/clients/presentation/widgets/clients_search_field.dart';
import 'package:cheery/features/import_contacts/domain/device_contact.dart';
import 'package:cheery/features/import_contacts/presentation/controllers/import_contacts_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactSelectStep extends ConsumerStatefulWidget {
  const ContactSelectStep({super.key});

  @override
  ConsumerState<ContactSelectStep> createState() => _ContactSelectStepState();
}

class _ContactSelectStepState extends ConsumerState<ContactSelectStep> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importContactsControllerProvider);
    final controller = ref.read(importContactsControllerProvider.notifier);
    final existingKeys =
        ref.watch(clientsControllerProvider).maybeWhen(
              data: (_) =>
                  ref.read(clientsControllerProvider.notifier).existingPhoneKeys,
              orElse: () =>
                  ref.read(clientsControllerProvider.notifier).existingPhoneKeys,
            );

    if (state.isLoadingContacts) {
      return const CheeryLoading(message: 'Carregando contatos...');
    }

    if (state.permissionDenied) {
      return CheeryEmptyState(
        title: 'Sem acesso aos contatos',
        message: state.errorMessage ??
            'Precisamos da permissão para importar seus contatos.',
        icon: Icons.contacts_outlined,
        actionLabel: state.permissionPermanentlyDenied
            ? 'Abrir configurações'
            : 'Permitir acesso',
        onAction: () async {
          if (state.permissionPermanentlyDenied) {
            await controller.openSettings();
          } else {
            await controller.loadContacts();
          }
        },
      );
    }

    if (state.errorMessage != null && state.contacts.isEmpty) {
      return CheeryEmptyState(
        title: 'Não foi possível carregar',
        message: state.errorMessage!,
        icon: Icons.error_outline,
        actionLabel: 'Tentar de novo',
        onAction: controller.loadContacts,
      );
    }

    if (state.contacts.isEmpty) {
      return CheeryEmptyState(
        title: 'Nenhum contato encontrado',
        message:
            'Não encontramos contatos com telefone válido neste aparelho.',
        icon: Icons.person_off_outlined,
        actionLabel: 'Tentar de novo',
        onAction: controller.loadContacts,
      );
    }

    final filtered = state.filteredContacts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Selecione os contatos que deseja importar como clientes.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.inkMuted,
              ),
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            state.errorMessage!,
            style: const TextStyle(color: AppColors.danger),
          ),
        ],
        const SizedBox(height: 12),
        ClientsSearchField(
          controller: _searchController,
          hintText: 'Buscar contatos...',
          onChanged: controller.search,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: controller.selectAllFiltered,
              child: const Text('Selecionar todos'),
            ),
            TextButton(
              onPressed:
                  state.selectedCount == 0 ? null : controller.clearSelection,
              child: const Text('Limpar'),
            ),
            const Spacer(),
            Text(
              '${state.selectedCount} selecionado(s)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum contato corresponde à busca.',
                    style: TextStyle(color: AppColors.inkMuted),
                  ),
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final contact = filtered[index];
                    final selected = state.selectedIds.contains(contact.id);
                    final alreadyRegistered =
                        existingKeys.contains(contact.phoneNormalized);
                    return _ContactTile(
                      contact: contact,
                      selected: selected,
                      alreadyRegistered: alreadyRegistered,
                      onTap: () => controller.toggleContact(contact.id),
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        CheeryButton(
          label: 'Revisar seleção',
          icon: Icons.checklist_rtl,
          onPressed: state.selectedCount == 0 ? null : controller.goToReview,
          expanded: true,
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.selected,
    required this.alreadyRegistered,
    required this.onTap,
  });

  final DeviceContact contact;
  final bool selected;
  final bool alreadyRegistered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.cherrySoft : AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.cherry : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: (_) => onTap(),
                activeColor: AppColors.cherry,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.displayName.isEmpty
                          ? 'Sem nome'
                          : contact.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact.storedPhone,
                      style: const TextStyle(
                        color: AppColors.inkMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (alreadyRegistered)
                const _StatusBadge(
                  label: 'Já cadastrado',
                  color: AppColors.inkMuted,
                  background: AppColors.blush,
                )
              else if (contact.birthDate != null)
                const _StatusBadge(
                  label: 'Com aniversário',
                  color: AppColors.success,
                  background: AppColors.mintSoft,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
