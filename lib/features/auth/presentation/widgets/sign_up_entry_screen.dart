import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/auth/presentation/mobile/sign_up_screen_mobile.dart';
import 'package:cheery/features/auth/presentation/web/sign_up_screen_web.dart';
import 'package:flutter/widgets.dart';

/// Adaptive entry for the sign-up screen.
class SignUpEntryScreen extends StatelessWidget {
  const SignUpEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => const SignUpScreenMobile(),
      desktop: (_) => const SignUpScreenWeb(),
    );
  }
}
