import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_logo.dart';
import 'package:flutter/material.dart';

/// Shared brand panel for web auth screens.
class AuthWebBrandPanel extends StatelessWidget {
  const AuthWebBrandPanel({
    this.headline =
        'Fidelize clientes com mensagens de aniversário no WhatsApp.',
    super.key,
  });

  final String headline;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cherry, AppColors.cherryDark],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CheeryLogo(
              size: 56,
              wordmarkSize: 44,
              wordmarkColor: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              headline,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
