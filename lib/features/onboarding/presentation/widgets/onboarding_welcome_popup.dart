import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/core/widgets/cheery_logo.dart';
import 'package:cheery/features/onboarding/domain/onboarding_copy.dart';
import 'package:flutter/material.dart';

/// Large centered intro popup shown on Home before the guided tour.
class OnboardingWelcomePopup extends StatelessWidget {
  const OnboardingWelcomePopup({
    required this.onStart,
    required this.onSkip,
    super.key,
  });

  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.18),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: OnboardingCopy.skipLabel,
                onPressed: onSkip,
                icon: const Icon(Icons.close, color: AppColors.inkMuted),
              ),
            ),
            const Center(
              child: CheeryLogo(size: 56, wordmarkSize: 34, axis: Axis.vertical),
            ),
            const SizedBox(height: 24),
            Text(
              OnboardingCopy.welcomeTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              OnboardingCopy.welcomeBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.inkMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            CheeryButton(
              label: OnboardingCopy.welcomeCta,
              expanded: true,
              icon: Icons.explore_outlined,
              onPressed: onStart,
            ),
            const SizedBox(height: 8),
            CheeryButton(
              label: OnboardingCopy.skipLabel,
              expanded: true,
              variant: CheeryButtonVariant.text,
              onPressed: onSkip,
            ),
          ],
        ),
      ),
    );
  }
}
