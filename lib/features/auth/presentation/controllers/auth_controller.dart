import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/domain/auth_repository.dart';
import 'package:cheery/features/auth/domain/auth_user.dart';
import 'package:cheery/features/auth/domain/sign_up_result.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_repository_provider.dart';
import 'package:cheery/features/auth/presentation/controllers/password_recovery_pending_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthUser?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthUser?> {
  AuthRepository get _repository {
    final repository = ref.read(authRepositoryProvider);
    if (repository == null) {
      throw const AuthUnknownFailure(
        'Supabase não configurado. Verifique assets/env/.env.',
      );
    }
    return repository;
  }

  @override
  Future<AuthUser?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    if (repository == null) return null;

    final sub = repository.watchAuthState().listen((user) {
      state = AsyncData(user);
    });
    ref.onDispose(sub.cancel);
    return repository.currentUser();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Avoid AsyncLoading() here: it clears valueOrNull and can race GoRouter
    // redirects / home data loads mid-login. The login form owns the busy UI.
    state = await AsyncValue.guard(() {
      return _repository.signInWithEmail(email: email, password: password);
    });
    _rethrowIfError();
  }

  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String companyName,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await _repository.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        companyName: companyName,
      );

      if (result.needsEmailConfirmation) {
        state = const AsyncData(null);
      } else {
        state = AsyncData(result.user);
      }
      return result;
    } on AuthFailure catch (failure) {
      state = AsyncError(failure, StackTrace.current);
      throw failure;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      if (error is AuthFailure) throw error;
      throw AuthUnknownFailure(error.toString());
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _repository.sendPasswordResetEmail(email: email);
  }

  Future<void> updatePassword({required String newPassword}) async {
    await _repository.updatePassword(newPassword: newPassword);
    ref.read(passwordRecoveryPendingProvider.notifier).clear();
  }

  Future<void> requestAccountDeletion() async {
    await _repository.requestAccountDeletion();
  }

  Future<void> confirmAccountDeletion({required String token}) async {
    await _repository.confirmAccountDeletion(token: token);
    ref.read(passwordRecoveryPendingProvider.notifier).clear();
    state = const AsyncData(null);
  }

  Future<void> resendSignupConfirmationEmail({required String email}) async {
    await _repository.resendSignupConfirmationEmail(email: email);
  }

  Future<void> ensureProfileAfterConfirmation() async {
    final user = _repository.currentUser();
    if (user == null) return;
    await _repository.ensureProfileFromMetadata(user.id);
  }

  Future<AuthUser?> recoverSessionFromCurrentUrl() async {
    final user = await _repository.recoverSessionFromCurrentUrl();
    state = AsyncData(user);
    if (user != null) {
      await _repository.ensureProfileFromMetadata(user.id);
    }
    return user;
  }

  Future<void> signInWithGoogle() async {
    try {
      state = const AsyncLoading();
      await _repository.signInWithGoogle();
      final user = _repository.currentUser();
      state = AsyncData(user);
      if (user != null) {
        await _repository.ensureProfileFromMetadata(user.id);
      }
    } on AuthFailure catch (failure) {
      state = AsyncData(_repository.currentUser());
      if (failure is! AuthUnknownFailure ||
          !failure.message.contains('janela aberta')) {
        throw failure;
      }
    } catch (error) {
      state = AsyncData(ref.read(authRepositoryProvider)?.currentUser());
      if (error is AuthFailure) throw error;
      throw AuthUnknownFailure(error.toString());
    }
  }

  Future<void> signInWithApple() async {
    try {
      // Native Apple sheet owns its own UI; avoid clearing auth mid-flow.
      await _repository.signInWithApple();
      final user = _repository.currentUser();
      state = AsyncData(user);
      if (user != null) {
        await _repository.ensureProfileFromMetadata(user.id);
      }
    } on AuthFailure catch (failure) {
      state = AsyncData(_repository.currentUser());
      throw failure;
    } catch (error) {
      state = AsyncData(ref.read(authRepositoryProvider)?.currentUser());
      if (error is AuthFailure) throw error;
      throw AuthUnknownFailure(error.toString());
    }
  }

  Future<void> cancelPasswordRecovery() async {
    ref.read(passwordRecoveryPendingProvider.notifier).clear();
    await signOut();
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncData(null);
  }

  void _rethrowIfError() {
    final error = state.error;
    if (error == null) return;
    if (error is AuthFailure) throw error;
    throw AuthUnknownFailure(error.toString());
  }
}
