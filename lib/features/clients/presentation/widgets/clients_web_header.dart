import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/clients/domain/clients_sort.dart';
import 'package:cheery/features/clients/presentation/widgets/clients_search_field.dart';
import 'package:cheery/features/onboarding/domain/onboarding_anchors.dart';
import 'package:flutter/material.dart';

class ClientsWebHeader extends StatelessWidget {
  const ClientsWebHeader({
    required this.onImport,
    required this.onAdd,
    super.key,
  });

  final VoidCallback onImport;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lista de Clientes',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.cherry,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Gerencie sua lista de contatos e preferências.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.inkMuted,
              ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.end,
          children: [
            CheeryButton(
              key: OnboardingAnchors.clientsImport,
              label: 'Importar planilha',
              variant: CheeryButtonVariant.outlined,
              icon: Icons.upload_file_outlined,
              onPressed: onImport,
            ),
            CheeryButton(
              key: OnboardingAnchors.clientsAdd,
              label: 'Adicionar cliente',
              icon: Icons.add,
              onPressed: onAdd,
            ),
          ],
        ),
        const SizedBox(height: 14),
        const _MobileContactsImportHint(),
      ],
    );
  }
}

class _MobileContactsImportHint extends StatelessWidget {
  const _MobileContactsImportHint();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.smartphone_outlined,
          size: 16,
          color: AppColors.inkMuted.withValues(alpha: 0.85),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'No app mobile você também pode importar contatos da agenda. '
            'Baixe o Cheery no celular para usar essa opção.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.inkMuted,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );
  }
}

class ClientsWebToolbar extends StatelessWidget {
  const ClientsWebToolbar({
    required this.searchController,
    required this.onSearch,
    required this.sort,
    required this.onSortChanged,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final ClientsSort sort;
  final ValueChanged<ClientsSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final sortLabel =
        sort == ClientsSort.name ? 'Nome' : 'Aniversário';

    return Row(
      children: [
        Expanded(
          child: ClientsSearchField(
            controller: searchController,
            onChanged: onSearch,
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<ClientsSort>(
          initialValue: sort,
          tooltip: 'Ordenar',
          onSelected: onSortChanged,
          itemBuilder: (context) => [
            CheckedPopupMenuItem(
              value: ClientsSort.birthday,
              checked: sort == ClientsSort.birthday,
              child: const Text('Aniversário'),
            ),
            CheckedPopupMenuItem(
              value: ClientsSort.name,
              checked: sort == ClientsSort.name,
              child: const Text('Nome'),
            ),
          ],
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
              color: AppColors.surfaceElevated,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort, size: 18, color: AppColors.ink),
                const SizedBox(width: 8),
                Text(
                  sortLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.ink,
                      ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, color: AppColors.inkMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
