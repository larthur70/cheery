import 'dart:async';

import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_repository_provider.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const profilePasswordResetCooldown = Duration(seconds: 60);

class ProfileFormState {
  const ProfileFormState({
    this.isSavingAccount = false,
    this.isSendingPasswordReset = false,
    this.passwordResetRemainingSeconds = 0,
    this.accountMessage,
    this.passwordMessage,
    this.accountError,
    this.passwordError,
  });

  final bool isSavingAccount;
  final bool isSendingPasswordReset;
  final int passwordResetRemainingSeconds;
  final String? accountMessage;
  final String? passwordMessage;
  final String? accountError;
  final String? passwordError;

  bool get canSendPasswordReset =>
      passwordResetRemainingSeconds <= 0 && !isSendingPasswordReset;

  ProfileFormState copyWith({
    bool? isSavingAccount,
    bool? isSendingPasswordReset,
    int? passwordResetRemainingSeconds,
    String? accountMessage,
    String? passwordMessage,
    String? accountError,
    String? passwordError,
    bool clearAccountFeedback = false,
    bool clearPasswordFeedback = false,
  }) {
    return ProfileFormState(
      isSavingAccount: isSavingAccount ?? this.isSavingAccount,
      isSendingPasswordReset:
          isSendingPasswordReset ?? this.isSendingPasswordReset,
      passwordResetRemainingSeconds: passwordResetRemainingSeconds ??
          this.passwordResetRemainingSeconds,
      accountMessage:
          clearAccountFeedback ? null : (accountMessage ?? this.accountMessage),
      passwordMessage: clearPasswordFeedback
          ? null
          : (passwordMessage ?? this.passwordMessage),
      accountError:
          clearAccountFeedback ? null : (accountError ?? this.accountError),
      passwordError:
          clearPasswordFeedback ? null : (passwordError ?? this.passwordError),
    );
  }
}

final profileFormControllerProvider =
    NotifierProvider.autoDispose<ProfileFormController, ProfileFormState>(
  ProfileFormController.new,
);

class ProfileFormController extends AutoDisposeNotifier<ProfileFormState> {
  Timer? _passwordResetTimer;

  @override
  ProfileFormState build() {
    ref.onDispose(() => _passwordResetTimer?.cancel());
    return const ProfileFormState();
  }

  Future<void> saveAccount({
    required String fullName,
    required String companyName,
    required String email,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final user = ref.read(authControllerProvider).valueOrNull;
    if (repository == null || user == null) {
      state = state.copyWith(
        accountError: 'Sessão inválida. Faça login novamente.',
        clearAccountFeedback: true,
      );
      return;
    }

    state = state.copyWith(
      isSavingAccount: true,
      clearAccountFeedback: true,
    );

    try {
      await repository.updateProfileFields(
        userId: user.id,
        fullName: fullName,
        companyName: companyName,
      );

      final trimmedEmail = email.trim();
      final emailChanged = trimmedEmail.isNotEmpty &&
          trimmedEmail.toLowerCase() != user.email.toLowerCase();
      if (emailChanged) {
        if (!user.canChangeEmail) {
          throw const AuthEmailChangeNotAllowedFailure();
        }
        await repository.updateEmail(email: trimmedEmail);
        state = state.copyWith(
          isSavingAccount: false,
          accountMessage:
              'Enviamos um link para $trimmedEmail e outro para ${user.email}. '
              'A troca só vale depois que você confirmar os dois e-mails.',
        );
      } else {
        state = state.copyWith(
          isSavingAccount: false,
          accountMessage: 'Dados da conta atualizados.',
        );
      }
      ref.invalidate(currentProfileProvider);
    } on AuthFailure catch (failure) {
      state = state.copyWith(
        isSavingAccount: false,
        accountError: failure.message,
      );
    } catch (_) {
      state = state.copyWith(
        isSavingAccount: false,
        accountError: 'Não foi possível salvar os dados da conta.',
      );
    }
  }

  Future<void> sendPasswordResetEmail() async {
    if (!state.canSendPasswordReset) return;

    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) {
      state = state.copyWith(
        passwordError: 'Sessão inválida. Faça login novamente.',
        clearPasswordFeedback: true,
      );
      return;
    }
    if (!user.canSetPassword) {
      state = state.copyWith(
        passwordError:
            'Contas conectadas ao ${user.linkedOAuthLabel ?? 'Google ou Apple'} '
            'não usam senha no Cheery.',
        clearPasswordFeedback: true,
      );
      return;
    }

    final email = user.email.trim();
    if (email.isEmpty || !email.contains('@')) {
      state = state.copyWith(
        passwordError: 'Não encontramos um e-mail válido nesta conta.',
        clearPasswordFeedback: true,
      );
      return;
    }

    state = state.copyWith(
      isSendingPasswordReset: true,
      clearPasswordFeedback: true,
    );

    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordResetEmail(email: email);
      state = state.copyWith(
        isSendingPasswordReset: false,
        passwordMessage:
            'Enviamos um link para $email. Abra o e-mail para definir uma nova senha.',
      );
      _startPasswordResetCooldown();
    } on AuthFailure catch (failure) {
      state = state.copyWith(
        isSendingPasswordReset: false,
        passwordError: failure.message,
      );
    } catch (_) {
      state = state.copyWith(
        isSendingPasswordReset: false,
        passwordError: 'Não foi possível enviar o e-mail. Tente novamente.',
      );
    }
  }

  void _startPasswordResetCooldown() {
    _passwordResetTimer?.cancel();
    state = state.copyWith(
      passwordResetRemainingSeconds: profilePasswordResetCooldown.inSeconds,
    );
    _passwordResetTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.passwordResetRemainingSeconds - 1;
      if (next <= 0) {
        timer.cancel();
        state = state.copyWith(passwordResetRemainingSeconds: 0);
        return;
      }
      state = state.copyWith(passwordResetRemainingSeconds: next);
    });
  }
}
