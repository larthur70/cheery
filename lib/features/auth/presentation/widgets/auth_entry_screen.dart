import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/auth/presentation/mobile/login_screen_mobile.dart';
import 'package:cheery/features/auth/presentation/web/login_screen_web.dart';
import 'package:flutter/widgets.dart';

/// Adaptive entry for the login screen.
class AuthEntryScreen extends StatelessWidget {
  const AuthEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => const LoginScreenMobile(),
      desktop: (_) => const LoginScreenWeb(),
    );
  }
}
