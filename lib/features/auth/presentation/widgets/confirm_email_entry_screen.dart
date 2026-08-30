import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/auth/presentation/mobile/confirm_email_screen_mobile.dart';
import 'package:cheery/features/auth/presentation/web/confirm_email_screen_web.dart';
import 'package:flutter/widgets.dart';

/// Adaptive entry for the email confirmation screen.
class ConfirmEmailEntryScreen extends StatelessWidget {
  const ConfirmEmailEntryScreen({required this.email, super.key});

  final String email;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => ConfirmEmailScreenMobile(email: email),
      desktop: (_) => ConfirmEmailScreenWeb(email: email),
    );
  }
}
