import 'package:cheery/features/auth/domain/auth_user.dart';

/// Outcome of an email/password sign-up attempt.
class SignUpResult {
  const SignUpResult({
    required this.email,
    required this.needsEmailConfirmation,
    this.user,
  });

  final String email;
  final bool needsEmailConfirmation;
  final AuthUser? user;
}
