import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/billing/domain/plan_limits.dart';
import 'package:cheery/features/import_clients/domain/import_row_draft.dart';
import 'package:cheery/features/import_clients/domain/import_validation_result.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_automation_ui.dart';
import 'package:cheery/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ImportReviewStep extends StatelessWidget {
  const ImportReviewStep({
    required this.validation,
    required this.authorizationConfirmed,
    required this.onAuthorizationChanged,
    this.errorMessage,
    super.key,
  });

  final ImportValidationResult validation;
  final bool authorizationConfirmed;
  final ValueChanged<bool> onAuthorizationChanged;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final allRows = validation.rows;
    final invalidRows = validation.invalidRows;
    final warningRows = validation.warningRows;
    final planLimitRows = validation.planLimitSkippedRows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _StatChip(
              label: '${validation.validCount} serão importados',
              color: AppColors.success,
              background: AppColors.mintSoft,
            ),
            if (validation.planLimitSkippedCount > 0)
              _StatChip(
                label:
                    '${validation.planLimitSkippedCount} fora do limite Free',
                color: AppColors.cherry,
                background: AppColors.blushDeep,
              ),
            if (validation.invalidCount > 0)
              _StatChip(
                label: '${validation.invalidCount} com erro (ignorados)',
                color: AppColors.danger,
                background: AppColors.blushDeep,
              ),
            if (validation.warningCount > 0)
              _StatChip(
                label: '${validation.warningCount} com aviso de template',
                color: AppColors.warning,
                background: const Color(0xFFFFF0D6),
              ),
            _StatChip(
              label: '${validation.totalCount} no total',
              color: AppColors.inkMuted,
              background: AppColors.blush,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Linhas com erro (vermelho) serão ignoradas. '
          'Linhas fora do limite Free não serão importadas. '
          'Avisos de template (âmbar) entram com o template padrão.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.inkMuted,
              ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: const TextStyle(color: AppColors.danger),
          ),
        ],
        if (planLimitRows.isNotEmpty ||
            invalidRows.isNotEmpty ||
            warningRows.isNotEmpty) ...[
          const SizedBox(height: 10),
          if (planLimitRows.isNotEmpty)
            _IssueBanner(
              icon: Icons.workspace_premium_outlined,
              color: AppColors.cherry,
              background: AppColors.blushDeep,
              title:
                  '${planLimitRows.length} linha(s) não serão importadas '
                  'por causa do limite do plano Free '
                  '(máx. ${PlanLimits.freeMaxClients} clientes)',
              lines: [
                for (final row in planLimitRows)
                  'Linha ${row.rowNumber}: ${ImportRowDraft.planLimitSkipMessage}',
              ],
              footer: CheeryButton(
                label: 'Ver planos',
                icon: Icons.workspace_premium_outlined,
                onPressed: () => context.push(
                  AppRoutes.profilePlansFrom(
                    AssinaturaOrigemGatilho.limiteClientes.wireValue,
                  ),
                ),
                expanded: true,
              ),
            ),
          if (planLimitRows.isNotEmpty &&
              (invalidRows.isNotEmpty || warningRows.isNotEmpty))
            const SizedBox(height: 8),
          if (invalidRows.isNotEmpty)
            _IssueBanner(
              icon: Icons.error_outline,
              color: AppColors.danger,
              background: AppColors.blushDeep,
              title:
                  '${invalidRows.length} erro(s) — essas linhas serão ignoradas',
              lines: [
                for (final row in invalidRows)
                  'Linha ${row.rowNumber}: ${row.errors.join(' · ')}',
              ],
            ),
          if (invalidRows.isNotEmpty && warningRows.isNotEmpty)
            const SizedBox(height: 8),
          if (warningRows.isNotEmpty)
            _IssueBanner(
              icon: Icons.info_outline,
              color: AppColors.warning,
              background: const Color(0xFFFFF0D6),
              title:
                  '${warningRows.length} template(s) não encontrado(s) — '
                  'entrarão com o padrão',
              lines: [
                for (final row in warningRows)
                  'Linha ${row.rowNumber}: "${row.templateRaw}" → '
                      '${row.templateName ?? 'padrão'}',
              ],
            ),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: _ReviewTable(
            rows: allRows,
            dateFormat: dateFormat,
            rowColor: _rowColor,
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: authorizationConfirmed,
          onChanged: (value) => onAuthorizationChanged(value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.cherry,
          title: Text(
            'Confirmo que tenho autorização desses contatos para receber mensagem',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );
  }

  Color? _rowColor(ImportRowDraft row) {
    if (!row.isValid) {
      return AppColors.blushDeep.withValues(alpha: 0.65);
    }
    if (row.skippedForPlanLimit) {
      return AppColors.blush.withValues(alpha: 0.9);
    }
    if (row.hasWarnings) {
      return const Color(0xFFFFF0D6).withValues(alpha: 0.7);
    }
    return null;
  }
}

class _ReviewTable extends StatefulWidget {
  const _ReviewTable({
    required this.rows,
    required this.dateFormat,
    required this.rowColor,
  });

  final List<ImportRowDraft> rows;
  final DateFormat dateFormat;
  final Color? Function(ImportRowDraft row) rowColor;

  @override
  State<_ReviewTable> createState() => _ReviewTableState();
}

class _ReviewTableState extends State<_ReviewTable> {
  final _horizontalController = ScrollController();
  final _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        controller: _horizontalController,
        thumbVisibility: true,
        notificationPredicate: (notification) =>
            notification.metrics.axis == Axis.horizontal,
        child: SingleChildScrollView(
          controller: _horizontalController,
          scrollDirection: Axis.horizontal,
          child: Scrollbar(
            controller: _verticalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _verticalController,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.blush),
                columnSpacing: 28,
                horizontalMargin: 16,
                columns: [
                  const DataColumn(label: Text('#')),
                  const DataColumn(label: Text('Nome')),
                  const DataColumn(label: Text('Telefone')),
                  const DataColumn(label: Text('Aniversário')),
                  const DataColumn(label: Text('Template')),
                  if (WhatsAppAutomationUi.showAutomaticControls)
                    const DataColumn(label: Text('Automático')),
                  const DataColumn(label: Text('Status')),
                ],
                rows: [
                  for (final row in widget.rows)
                    DataRow(
                      color: WidgetStateProperty.all(widget.rowColor(row)),
                      cells: [
                        DataCell(Text('${row.rowNumber}')),
                        DataCell(
                          _FieldText(
                            text: row.name.isEmpty ? '—' : row.name,
                            hasError: row.nameHasError,
                            minWidth: 140,
                          ),
                        ),
                        DataCell(
                          _FieldText(
                            text: row.phone.isEmpty ? '—' : row.phone,
                            hasError: row.phoneHasError,
                            minWidth: 130,
                          ),
                        ),
                        DataCell(
                          _FieldText(
                            text: row.birthDate != null
                                ? widget.dateFormat.format(row.birthDate!)
                                : (row.birthDateRaw.isEmpty
                                    ? '—'
                                    : row.birthDateRaw),
                            hasError: row.birthDateHasError,
                            minWidth: 110,
                          ),
                        ),
                        DataCell(
                          _FieldText(
                            text: row.usedFallbackTemplate
                                ? '${row.templateName ?? 'Padrão'} '
                                    '(era: ${row.templateRaw})'
                                : (row.templateName ??
                                    (row.templateRaw.isEmpty
                                        ? 'Padrão'
                                        : row.templateRaw)),
                            hasWarning: row.usedFallbackTemplate,
                            minWidth: 200,
                          ),
                        ),
                        if (WhatsAppAutomationUi.showAutomaticControls)
                          DataCell(
                            Text(row.automaticEnabled ? 'Sim' : 'Não'),
                          ),
                        DataCell(
                          SizedBox(
                            width: 220,
                            child: _StatusCell(row: row),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  const _StatusCell({required this.row});

  final ImportRowDraft row;

  @override
  Widget build(BuildContext context) {
    if (!row.isValid) {
      return Row(
        children: [
          const Icon(Icons.cancel_outlined, size: 16, color: AppColors.danger),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              row.errors.join(' · '),
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    if (row.skippedForPlanLimit) {
      return const Row(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 16,
            color: AppColors.cherry,
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              ImportRowDraft.planLimitSkipMessage,
              style: TextStyle(
                color: AppColors.cherry,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    if (row.hasWarnings) {
      return const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: AppColors.warning,
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Template padrão',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return const Row(
      children: [
        Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
        SizedBox(width: 6),
        Text(
          'OK',
          style: TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FieldText extends StatelessWidget {
  const _FieldText({
    required this.text,
    this.hasError = false,
    this.hasWarning = false,
    this.minWidth = 0,
  });

  final String text;
  final bool hasError;
  final bool hasWarning;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final child = (!hasError && !hasWarning)
        ? Text(text)
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: hasError
                  ? AppColors.danger.withValues(alpha: 0.12)
                  : AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: hasError ? AppColors.danger : AppColors.warning,
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: hasError ? AppColors.danger : AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          );

    if (minWidth <= 0) return child;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: child,
    );
  }
}

class _IssueBanner extends StatelessWidget {
  const _IssueBanner({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.lines,
    this.footer,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final List<String> lines;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                initiallyExpanded: false,
                leading: Icon(icon, size: 18, color: color),
                title: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  'Toque para ver detalhes',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                iconColor: color,
                collapsedIconColor: color,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 88),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: lines.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            lines[index],
                            style: TextStyle(
                              color: AppColors.ink.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: footer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
