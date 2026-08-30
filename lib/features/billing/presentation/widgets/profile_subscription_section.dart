import 'package:cheery/core/platform/store_compliance.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/billing/domain/plan_limits.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Current plan summary card (name, description, next billing).
class ProfilePlanSummaryCard extends StatelessWidget {
  const ProfilePlanSummaryCard({
    required this.isPro,
    this.currentPeriodEnd,
    super.key,
  });

  final bool isPro;
  final DateTime? currentPeriodEnd;

  @override
  Widget build(BuildContext context) {
    final title = isPro ? 'Plano Pro' : 'Plano Free';
    final description = isPro
        ? 'O plano perfeito para o seu negócio crescer com tranquilidade.'
        : 'Ideal para começar: até ${PlanLimits.freeMaxClients} clientes e o template padrão editável.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cherry.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 560;
          final billing = isPro && currentPeriodEnd != null
              ? _NextBillingBox(periodEnd: currentPeriodEnd!)
              : null;

          final textBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.cherry,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkMuted,
                    ),
              ),
            ],
          );

          if (billing == null) return textBlock;
          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                textBlock,
                const SizedBox(height: 16),
                billing,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: textBlock),
              const SizedBox(width: 16),
              billing,
            ],
          );
        },
      ),
    );
  }
}

class _NextBillingBox extends StatelessWidget {
  const _NextBillingBox({required this.periodEnd});

  final DateTime periodEnd;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(periodEnd.toLocal());
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próxima cobrança',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '${PlanLimits.proMonthlyPriceLabel} /mês',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.cherry,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'em $dateLabel',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.inkMuted,
                ),
          ),
        ],
      ),
    );
  }
}

/// Free-only client usage progress bar for the profile/subscription section.
class ProfileClientsUsageBar extends StatelessWidget {
  const ProfileClientsUsageBar({
    required this.clientCount,
    this.limit = PlanLimits.freeMaxClients,
    super.key,
  });

  final int clientCount;
  final int limit;

  double get _progress =>
      limit == 0 ? 0 : (clientCount / limit).clamp(0, 1).toDouble();

  @override
  Widget build(BuildContext context) {
    final percent = (_progress * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clientes cadastrados',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$clientCount / $limit',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.cherry,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                '$percent% utilizado',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkMuted,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 10,
              backgroundColor: AppColors.blushDeep,
              color: AppColors.cherry,
            ),
          ),
        ],
      ),
    );
  }
}

/// Side-by-side Free / Pro comparison cards.
class ProfilePlanCards extends StatelessWidget {
  const ProfilePlanCards({
    required this.isPro,
    required this.onUpgrade,
    required this.onManage,
    this.isBillingLoading = false,
    super.key,
  });

  final bool isPro;
  final VoidCallback? onUpgrade;
  final VoidCallback? onManage;
  final bool isBillingLoading;

  @override
  Widget build(BuildContext context) {
    final hidePayments = StoreCompliance.hideExternalPayments;
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 700;
        final freeCard = _PlanCard(
          title: 'Free',
          priceLabel: 'Grátis',
          features: const [
            'Até ${PlanLimits.freeMaxClients} clientes',
            'Somente template padrão editável',
            'Envio manual via WhatsApp',
            'Importação CSV/Excel',
            'Notificações',
          ],
          isCurrent: !isPro,
          badgeLabel: !isPro ? 'PLANO ATUAL' : null,
          buttonLabel: !isPro ? 'Plano ativo' : 'Plano Free',
          buttonEnabled: false,
          highlighted: false,
          onPressed: null,
          isLoading: false,
        );
        if (hidePayments) {
          return freeCard;
        }
        final proCard = _PlanCard(
          title: 'Pro',
          priceLabel: PlanLimits.proMonthlyPriceShort,
          priceNote: PlanLimits.proGrandfatheringNote,
          features: const [
            'Clientes ilimitados',
            'Templates ilimitados',
            'Envio manual via WhatsApp',
            'Importação CSV/Excel',
            'Notificações',
          ],
          isCurrent: isPro,
          badgeLabel: isPro ? 'PLANO ATUAL' : null,
          buttonLabel: isPro ? 'Gerenciar assinatura' : 'Assinar Pro',
          buttonEnabled: true,
          highlighted: true,
          onPressed: isPro ? onManage : onUpgrade,
          isLoading: isBillingLoading,
          showStar: true,
        );

        final planRow = stacked
            ? Column(
                children: [
                  freeCard,
                  const SizedBox(height: 16),
                  proCard,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: freeCard),
                  const SizedBox(width: 16),
                  Expanded(child: proCard),
                ],
              );

        return Column(
          children: [
            planRow,
            const SizedBox(height: 16),
            const _LaunchPriceCard(),
          ],
        );
      },
    );
  }
}

class _LaunchPriceCard extends StatelessWidget {
  const _LaunchPriceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cherry, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified, color: AppColors.cherry, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              PlanLimits.proLaunchPriceCard,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.priceLabel,
    required this.features,
    required this.isCurrent,
    required this.buttonLabel,
    required this.buttonEnabled,
    required this.highlighted,
    required this.isLoading,
    this.priceNote,
    this.badgeLabel,
    this.onPressed,
    this.showStar = false,
  });

  final String title;
  final String priceLabel;
  final String? priceNote;
  final List<String> features;
  final bool isCurrent;
  final String? badgeLabel;
  final String buttonLabel;
  final bool buttonEnabled;
  final bool highlighted;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool showStar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? AppColors.cherry : AppColors.border,
          width: highlighted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cherry.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
              ),
              if (showStar) ...[
                const SizedBox(width: 6),
                const Icon(Icons.star, color: AppColors.cherry, size: 20),
              ],
              const Spacer(),
              if (badgeLabel != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cherry,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeLabel!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            priceLabel,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.cherry,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (priceNote != null) ...[
            const SizedBox(height: 8),
            Text(
              priceNote!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.inkMuted,
                    height: 1.4,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          for (final feature in features) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: AppColors.mint, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.ink,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: CheeryButton(
              label: buttonLabel,
              onPressed: buttonEnabled ? onPressed : null,
              isLoading: isLoading && buttonEnabled,
              variant: highlighted && !isCurrent
                  ? CheeryButtonVariant.filled
                  : CheeryButtonVariant.outlined,
              expanded: true,
            ),
          ),
        ],
      ),
    );
  }
}
