import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/onboarding/domain/onboarding_copy.dart';
import 'package:cheery/features/onboarding/domain/onboarding_tour_step.dart';
import 'package:flutter/material.dart';

/// Explanation card shown during the product tour.
class OnboardingCoachCard extends StatelessWidget {
  const OnboardingCoachCard({
    required this.step,
    required this.stepIndex,
    required this.stepCount,
    required this.isMobile,
    required this.onNext,
    required this.onSkip,
    super.key,
  });

  final OnboardingTourStep step;
  final int stepIndex;
  final int stepCount;
  final bool isMobile;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final isLast = stepIndex >= stepCount - 1;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cherrySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${stepIndex + 1} de $stepCount',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.cherryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.inkMuted,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(OnboardingCopy.skipLabel),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              OnboardingCopy.title(step),
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              OnboardingCopy.body(step, isMobile: isMobile),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (var i = 0; i < stepCount; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: i == stepIndex ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == stepIndex
                          ? AppColors.cherry
                          : AppColors.blushDeep,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
                const Spacer(),
                CheeryButton(
                  label: OnboardingCopy.cta(step, isLast: isLast),
                  onPressed: onNext,
                  icon: isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
