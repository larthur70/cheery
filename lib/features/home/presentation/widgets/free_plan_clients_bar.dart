import 'package:cheery/core/platform/store_compliance.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/billing/domain/plan_limits.dart';
import 'package:flutter/material.dart';

/// Free-plan client quota bar with upgrade CTA.
class FreePlanClientsBar extends StatelessWidget {
  const FreePlanClientsBar({
    required this.clientCount,
    this.limit = PlanLimits.freeMaxClients,
    this.onUpgrade,
    super.key,
  });

  final int clientCount;
  final int limit;
  final VoidCallback? onUpgrade;

  double get _progress =>
      limit == 0 ? 0 : (clientCount / limit).clamp(0, 1).toDouble();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clientes do plano Free',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.cherry,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 560;
            final hidePayments = StoreCompliance.hideExternalPayments;

            final progressBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Limite de clientes',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Text(
                      '$clientCount / $limit',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 12,
                    backgroundColor: AppColors.blushDeep,
                    color: AppColors.cherry,
                  ),
                ),
              ],
            );

            final upgradeButton = hidePayments
                ? null
                : CheeryButton(
                    label: 'Evoluir para plano Pro',
                    icon: Icons.workspace_premium_outlined,
                    onPressed: onUpgrade,
                  );

            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  progressBlock,
                  if (upgradeButton != null) ...[
                    const SizedBox(height: 16),
                    upgradeButton,
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: progressBlock),
                if (upgradeButton != null) ...[
                  const SizedBox(width: 20),
                  upgradeButton,
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
