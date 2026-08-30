import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/clients/domain/client.dart';
import 'package:cheery/features/clients/presentation/widgets/client_avatar.dart';
import 'package:cheery/features/clients/presentation/widgets/client_birthday_label.dart';
import 'package:cheery/features/clients/presentation/widgets/client_template_chip.dart';
import 'package:cheery/features/clients/presentation/widgets/clients_search_field.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_automation_ui.dart';
import 'package:flutter/material.dart';

class ClientsWebTable extends StatelessWidget {
  const ClientsWebTable({
    required this.clients,
    required this.selectedIds,
    required this.onToggle,
    required this.onToggleAll,
    required this.onAutomaticChanged,
    required this.onEdit,
    required this.onDelete,
    this.updatingAutomaticIds = const {},
    super.key,
  });

  final List<Client> clients;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onToggle;
  final ValueChanged<bool> onToggleAll;
  final void Function(Client client, bool enabled) onAutomaticChanged;
  final ValueChanged<Client> onEdit;
  final ValueChanged<Client> onDelete;
  final Set<String> updatingAutomaticIds;

  bool get _allSelected =>
      clients.isNotEmpty && clients.every((c) => selectedIds.contains(c.id));

  bool get _someSelected =>
      clients.any((c) => selectedIds.contains(c.id)) && !_allSelected;

  static const _showAutomatic = WhatsAppAutomationUi.showAutomaticControls;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: {
        0: const FixedColumnWidth(48),
        1: const FlexColumnWidth(2.4),
        2: const FlexColumnWidth(1.6),
        3: const FlexColumnWidth(1.1),
        4: const FlexColumnWidth(1.8),
        if (_showAutomatic) 5: const FixedColumnWidth(112),
        (_showAutomatic ? 6 : 5): const FixedColumnWidth(56),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Checkbox(
                tristate: true,
                value: _allSelected
                    ? true
                    : _someSelected
                        ? null
                        : false,
                onChanged: clients.isEmpty
                    ? null
                    : (_) => onToggleAll(!_allSelected),
              ),
            ),
            _header(context, 'Nome'),
            _header(context, 'Telefone'),
            _header(context, 'Aniversário'),
            _header(context, 'Template'),
            if (_showAutomatic) _header(context, 'Automático'),
            _header(context, 'Ações'),
          ],
        ),
        for (final client in clients)
          TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Checkbox(
                  value: selectedIds.contains(client.id),
                  onChanged: (value) => onToggle(client.id, value ?? false),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    ClientAvatar(name: client.name),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        client.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  formatBrazilianPhone(client.phone),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ClientBirthdayLabel(birthDate: client.birthDate),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ClientTemplateChip(
                    label: client.templateName ?? 'Template',
                  ),
                ),
              ),
              if (_showAutomatic)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Switch.adaptive(
                    value: client.automaticEnabled,
                    onChanged: updatingAutomaticIds.contains(client.id)
                        ? null
                        : (enabled) => onAutomaticChanged(client, enabled),
                  ),
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.inkMuted),
                onSelected: (value) {
                  if (value == 'edit') onEdit(client);
                  if (value == 'delete') onDelete(client);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _header(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.inkMuted,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class ClientsBulkActionsBar extends StatelessWidget {
  const ClientsBulkActionsBar({
    required this.selectedCount,
    required this.onDelete,
    super.key,
  });

  final int selectedCount;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.blushDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            '$selectedCount selecionado${selectedCount == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.cherry,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Excluir selecionados',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class ClientsPaginationBar extends StatelessWidget {
  const ClientsPaginationBar({
    required this.start,
    required this.end,
    required this.total,
    required this.page,
    required this.onPrev,
    required this.onNext,
    super.key,
  });

  final int start;
  final int end;
  final int total;
  final int page;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Mostrando $start a $end de $total clientes',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.inkMuted,
              ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '$page',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
