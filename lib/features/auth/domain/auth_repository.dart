import 'package:cheery/features/auth/domain/auth_user.dart';
import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/domain/sign_up_result.dart';

/// Contract for authentication and profile persistence.
abstract class AuthRepository {
  Stream<AuthUser?> watchAuthState();

  /// Emits whenever Supabase signals a password-recovery session.
  Stream<void> watchPasswordRecovery();

  AuthUser? currentUser();

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String companyName,
  });

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> updatePassword({required String newPassword});

  /// Sends a confirmation email with a one-time deletion link.
  Future<void> requestAccountDeletion();

  /// Completes deletion after the user opens the email confirmation link.
  Future<void> confirmAccountDeletion({required String token});

  Future<void> resendSignupConfirmationEmail({required String email});

  Future<void> signOut();

  Future<Profile?> fetchProfile(String userId);

  Future<Profile> upsertProfile(Profile profile);

  /// Updates editable account fields (name / company). Billing columns are
  /// protected by a database trigger.
  Future<Profile> updateProfileFields({
    required String userId,
    required String fullName,
    required String companyName,
  });

  /// Marks the first-run product tour as finished (or skipped).
  Future<Profile> markOnboardingCompleted(String userId);

  Future<void> updateEmail({required String email});

  Future<Profile> ensureProfileFromMetadata(String userId);

  /// Recovers OAuth/email session from the current browser/app URL.
  Future<AuthUser?> recoverSessionFromCurrentUrl();

  Future<AuthUser> signInWithGoogle();

  Future<AuthUser> signInWithApple();
}
