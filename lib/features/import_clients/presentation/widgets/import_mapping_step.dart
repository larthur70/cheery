import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/import_clients/domain/column_mapping.dart';
import 'package:cheery/features/import_clients/domain/import_column_field.dart';
import 'package:cheery/features/import_clients/domain/parsed_spreadsheet.dart';
import 'package:flutter/material.dart';

class ImportMappingStep extends StatelessWidget {
  const ImportMappingStep({
    required this.spreadsheet,
    required this.mapping,
    required this.onChanged,
    this.errorMessage,
    super.key,
  });

  final ParsedSpreadsheet spreadsheet;
  final ColumnMapping mapping;
  final void Function(ImportColumnField field, int? index) onChanged;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final previewRows = spreadsheet.rows.take(5).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Associe as colunas da planilha aos campos do Cheery.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkMuted,
                ),
          ),
          const SizedBox(height: 20),
          for (final field in ImportColumnFieldLabel.visibleForMapping) ...[
            _MappingRow(
              field: field,
              headers: spreadsheet.headers,
              selectedIndex: mapping.indexFor(field),
              onChanged: (index) => onChanged(field, index),
            ),
            const SizedBox(height: 12),
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              errorMessage!,
              style: const TextStyle(color: AppColors.danger),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          Text(
            'Prévia das primeiras linhas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          _PreviewTable(
            headers: spreadsheet.headers,
            rows: previewRows,
          ),
        ],
      ),
    );
  }
}

class _MappingRow extends StatelessWidget {
  const _MappingRow({
    required this.field,
    required this.headers,
    required this.selectedIndex,
    required this.onChanged,
  });

  final ImportColumnField field;
  final List<String> headers;
  final int? selectedIndex;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Row(
            children: [
              Text(
                field.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              if (field.isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<int?>(
            initialValue: selectedIndex,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceElevated,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            hint: Text(
              field.isRequired ? 'Selecione a coluna' : 'Opcional',
              style: const TextStyle(color: AppColors.inkMuted),
            ),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(
                  field.isRequired
                      ? 'Selecione a coluna'
                      : 'Não mapear (usar padrão)',
                ),
              ),
              for (var i = 0; i < headers.length; i++)
                DropdownMenuItem<int?>(
                  value: i,
                  child: Text(
                    headers[i].isEmpty ? 'Coluna ${i + 1}' : headers[i],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _PreviewTable extends StatelessWidget {
  const _PreviewTable({
    required this.headers,
    required this.rows,
  });

  final List<String> headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Text(
        'Nenhuma linha de dados na planilha.',
        style: TextStyle(color: AppColors.inkMuted),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.blush),
                columnSpacing: 24,
                horizontalMargin: 16,
                columns: [
                  for (final header in headers)
                    DataColumn(
                      label: Text(
                        header.isEmpty ? '—' : header,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
                rows: [
                  for (final row in rows)
                    DataRow(
                      cells: [
                        for (var i = 0; i < headers.length; i++)
                          DataCell(
                            Text(
                              i < row.length ? row[i] : '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
