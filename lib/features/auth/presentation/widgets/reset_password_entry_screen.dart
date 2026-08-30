import 'package:cheery/features/auth/presentation/mobile/reset_password_screen_mobile.dart';
import 'package:cheery/features/auth/presentation/web/reset_password_screen_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Adaptive entry for the reset-password screen (email recovery link).
class ResetPasswordEntryScreen extends StatelessWidget {
  const ResetPasswordEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const ResetPasswordScreenWeb();
    return const ResetPasswordScreenMobile();
  }
}
