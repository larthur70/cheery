import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/platform/store_compliance.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_empty_state.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/clients/presentation/controllers/client_templates_provider.dart';
import 'package:cheery/features/onboarding/domain/onboarding_anchors.dart';
import 'package:cheery/features/templates/domain/template.dart';
import 'package:cheery/features/templates/domain/templates_failure.dart';
import 'package:cheery/features/templates/presentation/controllers/templates_controller.dart';
import 'package:cheery/features/templates/presentation/widgets/template_list_card.dart';
import 'package:cheery/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TemplatesMobileScreen extends ConsumerWidget {
  const TemplatesMobileScreen({super.key});

  void _onCreateOrUpgrade(
    BuildContext context,
    WidgetRef ref, {
    required bool isPro,
    required int templateCount,
  }) {
    if (isPro) {
      context.go(AppRoutes.templatesNew);
      return;
    }
    ref.read(analyticsServiceProvider).trackLimiteAtingido(
          tipo: LimiteAnalyticsTipo.templates,
          valorAtual: templateCount,
        );
    if (StoreCompliance.hideExternalPayments) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(StoreCompliance.limitReached)),
      );
      return;
    }
    context.push(
      AppRoutes.profilePlansFrom(
        AssinaturaOrigemGatilho.limiteTemplates.wireValue,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Template template,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir template'),
        content: Text('Remover "${template.name}"?'),
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
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(templatesControllerProvider.notifier)
          .deleteTemplate(template.id);
      ref.invalidate(clientTemplatesProvider);
    } on TemplatesFailure catch (failure) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    }
  }

  Future<void> _submitForApproval(
    BuildContext context,
    WidgetRef ref,
    Template template,
  ) async {
    try {
      await ref
          .read(templatesControllerProvider.notifier)
          .submitForApproval(template.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Template enviado para aprovação da Meta.'),
        ),
      );
    } on TemplatesFailure catch (failure) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    }
  }

  Future<void> _syncStatus(
    BuildContext context,
    WidgetRef ref,
    Template template,
  ) async {
    try {
      await ref
          .read(templatesControllerProvider.notifier)
          .syncApprovalStatus(template.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status atualizado.')),
      );
    } on TemplatesFailure catch (failure) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesControllerProvider);
    final isPro = ref.watch(currentProfileProvider).valueOrNull?.isPro ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final count = templatesAsync.valueOrNull?.length ?? 0;
          _onCreateOrUpgrade(
            context,
            ref,
            isPro: isPro,
            templateCount: count,
          );
        },
        backgroundColor: AppColors.cherry,
        foregroundColor: Colors.white,
        tooltip: isPro
            ? 'Novo template'
            : StoreCompliance.hideExternalPayments
                ? StoreCompliance.limitReached
                : 'Upgrade para Pro',
        child: Icon(
          isPro || StoreCompliance.hideExternalPayments
              ? Icons.add
              : Icons.workspace_premium_outlined,
        ),
      ),
      body: SafeArea(
        child: templatesAsync.when(
          loading: () =>
              const CheeryLoading(message: 'Carregando templates...'),
          error: (error, _) => CheeryEmptyState(
            title: 'Não foi possível carregar',
            message: error is TemplatesFailure
                ? error.message
                : 'Tente novamente em instantes.',
            icon: Icons.error_outline,
            actionLabel: 'Tentar novamente',
            onAction: () =>
                ref.read(templatesControllerProvider.notifier).refresh(),
          ),
          data: (templates) {
            return RefreshIndicator(
              color: AppColors.cherry,
              onRefresh: () =>
                  ref.read(templatesControllerProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: KeyedSubtree(
                        key: OnboardingAnchors.templatesHeader,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Templates',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: AppColors.cherry,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            if (!isPro) ...[
                              const SizedBox(height: 6),
                              Text(
                                StoreCompliance.hideExternalPayments
                                    ? 'Plano Free: edite o template padrão.'
                                    : 'Plano Free: edite o template padrão. Upgrade para criar mais.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.inkMuted),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (templates.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: CheeryEmptyState(
                        title: 'Nenhum template ainda',
                        message: 'Crie sua primeira mensagem personalizada.',
                        icon: Icons.message_outlined,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      sliver: SliverList.separated(
                        itemCount: templates.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final template = templates[index];
                          return TemplateListCard(
                            template: template,
                            showMenu: true,
                            onEdit: () => context
                                .go(AppRoutes.templateEdit(template.id)),
                            onDelete: template.isDefault
                                ? null
                                : () =>
                                    _confirmDelete(context, ref, template),
                            onSubmitForApproval: () =>
                                _submitForApproval(context, ref, template),
                            onSyncStatus: () =>
                                _syncStatus(context, ref, template),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
