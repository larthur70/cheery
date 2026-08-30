import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/legal/domain/privacy_policy_copy.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared layout for public legal documents (privacy, terms).
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    required this.appBarTitle,
    required this.documentTitle,
    required this.lastUpdated,
    required this.intro,
    required this.sections,
    super.key,
  });

  final String appBarTitle;
  final String documentTitle;
  final String lastUpdated;
  final List<String> intro;
  final List<PrivacyPolicySection> sections;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.cherry),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            tooltip: 'Voltar',
          ),
          title: Text(
            appBarTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lastUpdated,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.inkMuted,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 20),
                  for (final paragraph in intro) ...[
                    Text(paragraph, style: privacyBodyStyle(context)),
                    const SizedBox(height: 12),
                  ],
                  for (final section in sections) ...[
                    const SizedBox(height: 20),
                    Text(
                      section.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    for (final block in section.blocks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LegalBlockView(block: block),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalBlockView extends StatelessWidget {
  const _LegalBlockView({required this.block});

  final PrivacyPolicyBlock block;

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      PrivacyParagraph(:final text, :final emphasis) => Text(
          text,
          style: privacyBodyStyle(context, emphasis: emphasis),
        ),
      PrivacyHeading(:final text) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      PrivacyBulletList(:final items, :final ordered) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text(
                        ordered ? '${i + 1}.' : '•',
                        style: privacyBodyStyle(context),
                      ),
                    ),
                    Expanded(
                      child: Text(items[i], style: privacyBodyStyle(context)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      PrivacyTableBlock(:final headers, :final rows) =>
        _LegalTable(headers: headers, rows: rows),
    };
  }
}

class _LegalTable extends StatelessWidget {
  const _LegalTable({
    required this.headers,
    required this.rows,
  });

  final List<String> headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        );
    final cellStyle = privacyBodyStyle(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 520),
          child: Table(
            border: TableBorder.all(color: AppColors.border, width: 1),
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            columnWidths: {
              for (var i = 0; i < headers.length; i++)
                i: const IntrinsicColumnWidth(flex: 1),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: AppColors.blushDeep),
                children: [
                  for (final header in headers)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(header, style: headerStyle),
                    ),
                ],
              ),
              for (final row in rows)
                TableRow(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceElevated,
                  ),
                  children: [
                    for (final cell in row)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(cell, style: cellStyle),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
