import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Google / Apple auth actions.
class AuthSocialButtons extends StatelessWidget {
  const AuthSocialButtons({
    this.onGooglePressed,
    this.onApplePressed,
    this.isGoogleLoading = false,
    this.isAppleLoading = false,
    super.key,
  });

  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final bool isGoogleLoading;
  final bool isAppleLoading;

  static const _googleIconAsset =
      'assets/images/svgs/google-icon-logo-svgrepo-com.svg';
  static const _appleIconAsset =
      'assets/images/svgs/apple-logo-svgrepo-com.svg';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheeryButton(
          label: 'Continuar com Google',
          variant: CheeryButtonVariant.outlined,
          leading: SizedBox(
            width: 18,
            height: 18,
            child: SvgPicture.asset(
              _googleIconAsset,
              width: 18,
              height: 18,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
              placeholderBuilder: (_) => const SizedBox(width: 18, height: 18),
            ),
          ),
          expanded: true,
          isLoading: isGoogleLoading,
          onPressed: onGooglePressed,
        ),
        const SizedBox(height: 10),
        CheeryButton(
          label: 'Continuar com Apple',
          variant: CheeryButtonVariant.outlined,
          leading: SizedBox(
            width: 18,
            height: 18,
            child: SvgPicture.asset(
              _appleIconAsset,
              width: 18,
              height: 18,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                AppColors.ink,
                BlendMode.srcIn,
              ),
              excludeFromSemantics: true,
              placeholderBuilder: (_) => const SizedBox(width: 18, height: 18),
            ),
          ),
          expanded: true,
          isLoading: isAppleLoading,
          onPressed: onApplePressed,
        ),
      ],
    );
  }
}
