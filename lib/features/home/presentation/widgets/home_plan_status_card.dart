import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/billing/domain/plan_limits.dart';
import 'package:flutter/material.dart';

/// Free-plan quota card used on the mobile home screen.
class HomePlanStatusCard extends StatelessWidget {
  const HomePlanStatusCard({
    required this.clientCount,
    this.limit = PlanLimits.freeMaxClients,
    this.onTap,
    super.key,
  });

  final int clientCount;
  final int limit;
  final VoidCallback? onTap;

  double get _progress =>
      limit == 0 ? 0 : (clientCount / limit).clamp(0, 1).toDouble();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.cherry.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PLANO ATUAL',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.inkMuted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$clientCount / $limit',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.cherry,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'clientes cadastrados',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 8,
                  backgroundColor: AppColors.blushDeep,
                  color: AppColors.cherry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
