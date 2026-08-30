import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Compact notice linking to terms and privacy (signup / account screens).
class PrivacyPolicyLinkText extends StatelessWidget {
  const PrivacyPolicyLinkText({
    this.prefix = 'Ao continuar, você concorda com os ',
    super.key,
  });

  final String prefix;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.inkMuted,
          height: 1.4,
        );
    final link = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.cherry,
          fontWeight: FontWeight.w600,
          height: 1.4,
        );

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text(prefix, style: muted),
        GestureDetector(
          onTap: () => context.push(AppRoutes.terms),
          child: Text('Termos de Uso', style: link),
        ),
        Text(' e a ', style: muted),
        GestureDetector(
          onTap: () => context.push(AppRoutes.privacy),
          child: Text('Política de Privacidade', style: link),
        ),
        Text('.', style: muted),
      ],
    );
  }
}
