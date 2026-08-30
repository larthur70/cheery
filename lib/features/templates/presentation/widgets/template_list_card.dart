import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/templates/domain/template.dart';
import 'package:cheery/features/templates/domain/template_approval_status.dart';
import 'package:cheery/features/templates/domain/template_body_converter.dart';
import 'package:cheery/features/templates/presentation/widgets/template_approval_badge.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_automation_ui.dart';
import 'package:flutter/material.dart';

/// Card showing a template name and friendly message preview.
class TemplateListCard extends StatelessWidget {
  const TemplateListCard({
    required this.template,
    required this.onEdit,
    this.onDelete,
    this.onSubmitForApproval,
    this.onSyncStatus,
    this.showMenu = false,
    super.key,
  });

  final Template template;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSubmitForApproval;
  final VoidCallback? onSyncStatus;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    final friendly = TemplateBodyConverter.toFriendly(
      template.message,
      template.variables,
    );
    final preview = friendly.length > 140
        ? '${friendly.substring(0, 140)}…'
        : friendly;
    final showApprovalUi = WhatsAppAutomationUi.showMetaApprovalUi;

    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (template.isDefault) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Color(0xFFC47A12),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Template padrão',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: const Color(0xFFC47A12),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          template.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        if (showApprovalUi) ...[
                          const SizedBox(height: 6),
                          TemplateApprovalBadge(
                            status: template.approvalStatus,
                          ),
                          if (template.approvalStatus ==
                                  TemplateApprovalStatus.rejected &&
                              template.rejectedReason != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              template.rejectedReason!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.danger,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  if (showMenu)
                    PopupMenuButton<_TemplateCardAction>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.inkMuted,
                      ),
                      onSelected: (action) {
                        switch (action) {
                          case _TemplateCardAction.edit:
                            onEdit();
                          case _TemplateCardAction.submit:
                            onSubmitForApproval?.call();
                          case _TemplateCardAction.sync:
                            onSyncStatus?.call();
                          case _TemplateCardAction.delete:
                            onDelete?.call();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: _TemplateCardAction.edit,
                          child: Text('Editar'),
                        ),
                        if (showApprovalUi &&
                            template.approvalStatus.canSubmitForApproval &&
                            onSubmitForApproval != null)
                          const PopupMenuItem(
                            value: _TemplateCardAction.submit,
                            child: Text('Enviar para aprovação'),
                          ),
                        if (showApprovalUi &&
                            template.approvalStatus ==
                                TemplateApprovalStatus.pendingApproval &&
                            onSyncStatus != null)
                          const PopupMenuItem(
                            value: _TemplateCardAction.sync,
                            child: Text('Atualizar status'),
                          ),
                        if (!template.isDefault && onDelete != null)
                          const PopupMenuItem(
                            value: _TemplateCardAction.delete,
                            child: Text('Excluir'),
                          ),
                      ],
                    )
                  else
                    IconButton(
                      onPressed: onEdit,
                      tooltip: 'Editar',
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.cherry,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blushDeep,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  preview,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.ink,
                        height: 1.35,
                      ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _TemplateCardAction { edit, submit, sync, delete }
