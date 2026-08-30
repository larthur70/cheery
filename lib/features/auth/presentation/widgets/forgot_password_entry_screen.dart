import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/auth/presentation/mobile/forgot_password_screen_mobile.dart';
import 'package:cheery/features/auth/presentation/web/forgot_password_screen_web.dart';
import 'package:flutter/widgets.dart';

/// Adaptive entry for the forgot-password screen.
class ForgotPasswordEntryScreen extends StatelessWidget {
  const ForgotPasswordEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => const ForgotPasswordScreenMobile(),
      desktop: (_) => const ForgotPasswordScreenWeb(),
    );
  }
}
