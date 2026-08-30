import 'dart:convert';
import 'dart:math';

import 'package:cheery/core/config/app_deep_links.dart';
import 'package:cheery/core/config/auth_redirect_urls.dart';
import 'package:cheery/core/utils/app_logger.dart';
import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/domain/auth_repository.dart';
import 'package:cheery/features/auth/domain/auth_user.dart';
import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/domain/sign_up_result.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  /// App-facing profile columns. Never select token fields from `profiles`.
  static const _profileSelect =
      'id, full_name, company_name, plan, created_at, '
      'notifications_enabled, notification_time, timezone, '
      'stripe_customer_id, stripe_subscription_id, '
      'subscription_status, current_period_end, '
      'whatsapp_connected, whatsapp_integration_status, '
      'whatsapp_phone_number_id, whatsapp_business_account_id, '
      'whatsapp_display_phone, whatsapp_connected_at, '
      'whatsapp_last_error, onboarding_completed';

  @override
  Stream<AuthUser?> watchAuthState() {
    return _client.auth.onAuthStateChange.map((event) {
      return _mapUser(event.session?.user);
    });
  }

  @override
  Stream<void> watchPasswordRecovery() {
    return _client.auth.onAuthStateChange
        .where((event) => event.event == AuthChangeEvent.passwordRecovery)
        .map((_) {});
  }

  @override
  AuthUser? currentUser() => _mapUser(_client.auth.currentUser);

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    try {
      final response = await _client.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );
      final user = _mapUser(response.user);
      if (user == null) {
        throw const AuthInvalidCredentialsFailure();
      }
      return user;
    } on AuthFailure {
      rethrow;
    } on AuthException catch (error, stackTrace) {
      AppLogger.e('signInWithEmail failed', error: error, stackTrace: stackTrace);
      throw _mapAuthException(error);
    } catch (error, stackTrace) {
      if (error is AuthFailure) rethrow;
      AppLogger.e(
        'signInWithEmail unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AuthUnknownFailure();
    }
  }

  @override
  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String companyName,
  }) async {
    try {
      final trimmedEmail = email.trim();
      final response = await _client.auth.signUp(
        email: trimmedEmail,
        password: password,
        emailRedirectTo: AuthRedirectUrls.emailRedirectTo,
        data: {
          'full_name': fullName.trim(),
          'company_name': companyName.trim(),
        },
      );

      // Supabase returns a user with empty identities when the email
      // already exists (and often does NOT send another confirmation mail).
      final identities = response.user?.identities ?? const [];
      if (response.user != null && identities.isEmpty) {
        throw const AuthEmailAlreadyInUseFailure(
          'Este e-mail já está cadastrado. Faça login ou use "Reenviar e-mail" na tela de confirmação.',
        );
      }

      final needsConfirmation = response.session == null;
      final user = _mapUser(response.user);

      AppLogger.i(
        'signUp result: needsConfirmation=$needsConfirmation '
        'hasSession=${response.session != null} '
        'userId=${user?.id}',
      );

      if (!needsConfirmation) {
        if (user == null) {
          throw const AuthUnknownFailure();
        }
        try {
          await upsertProfile(
            Profile(
              id: user.id,
              fullName: fullName.trim(),
              companyName: companyName.trim(),
              plan: 'free',
              createdAt: DateTime.now().toUtc(),
            ),
          );
        } catch (error, stackTrace) {
          // Profile can also be created by a DB trigger; don't block signup.
          AppLogger.e(
            'Profile upsert after signup failed (continuing)',
            error: error,
            stackTrace: stackTrace,
          );
        }
        return SignUpResult(
          email: trimmedEmail,
          needsEmailConfirmation: false,
          user: user,
        );
      }

      return SignUpResult(
        email: trimmedEmail,
        needsEmailConfirmation: true,
      );
    } on AuthFailure {
      rethrow;
    } on AuthException catch (error, stackTrace) {
      AppLogger.e('signUpWithEmail failed', error: error, stackTrace: stackTrace);
      throw _mapAuthException(error);
    } catch (error, stackTrace) {
      AppLogger.e(
        'signUpWithEmail unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AuthUnknownFailure();
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    final trimmedEmail = email.trim();
    try {
      await _client.auth.resetPasswordForEmail(
        trimmedEmail,
        redirectTo: AuthRedirectUrls.passwordResetRedirectTo,
      );
    } on AuthException catch (error, stackTrace) {
      AppLogger.e(
        'sendPasswordResetEmail failed',
        error: error,
        stackTrace: stackTrace,
      );
      // Same response whether the email exists or not.
      return;
    } catch (error, stackTrace) {
      AppLogger.e(
        'sendPasswordResetEmail unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AuthUnknownFailure();
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (response.user == null) {
        throw const AuthUnknownFailure(
          'Não foi possível atualizar a senha. Tente novamente.',
        );
      }
    } on AuthException catch (error, stackTrace) {
      AppLogger.e('updatePassword failed', error: error, stackTrace: stackTrace);
      throw _mapAuthException(error);
    } catch (error, stackTrace) {
      if (error is AuthFailure) rethrow;
      AppLogger.e(
        'updatePassword unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AuthUnknownFailure();
    }
  }

  @override
  Future<void> requestAccountDeletion() async {
    try {
      final email = _client.auth.currentUser?.email?.trim();
      if (email == null || email.isEmpty) {
        throw const AuthDeleteAccountEmailSentFailure(
          'Não foi possível confirmar sua conta. Faça login novamente.',
        );
      }

      final response = await _client.functions.invoke(
        'delete-account',
        body: AppDeepLinks.nativeReturnBody({'action': 'request'}),
      );
      final data = response.data;
      if (data is Map) {
        final error = data['error'];
        if (error is String && error.isNotEmpty) {
          throw AuthDeleteAccountEmailSentFailure(error);
        }
      }
    } on AuthFailure {
      rethrow;
    } on FunctionException catch (error, stackTrace) {
      AppLogger.e(
        'requestAccountDeletion failed',
        error: error,
        stackTrace: stackTrace,
      );
      final details = error.details;
      if (details is Map && details['error'] is String) {
        throw AuthDeleteAccountEmailSentFailure(details['error'] as String);
      }
      throw const AuthDeleteAccountEmailSentFailure();
    } catch (error, stackTrace) {
      if (error is AuthFailure) rethrow;
      AppLogger.e(
        'requestAccountDeletion unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AuthDeleteAccountEmailSentFailure();
    }
  }

  @override
  Future<void> confirmAccountDeletion({required String token}) async {
    try {
      final trimmed = token.trim();
      if (trimmed.isEmpty) {
        throw const AuthDeleteAccountFailure(
          'Link de confirmação inválido ou expirado.',
        );
      }

      final response = await _client.functions.invoke(
        'delete-account',
        body: {'action': 'confirm', 'token': trimmed},
      );
      final data = response.data;
      if (data is Map) {
        final error = data['error'];
        if (error is String && error.isNotEmpty) {
          throw AuthDeleteAccountFailure(error);
        }
      }

      await _client.auth.signOut();
    } on AuthFailure {
      rethrow;
    } on FunctionException catch (error, stackTrace) {
      AppLogger.e(
        'confirmAccountDeletion failed',
        error: error,
        stackTrace: stackTrace,
      );
      final details = error.details;
      if (details is Map && details['error'] is String) {
        throw AuthDeleteAccountFailure(details['error'] as String);
      }
      throw const AuthDeleteAccountFailure();
    } catch (error, stackTrace) {
      if (error is AuthFailure) rethrow;
      AppLogger.e(
        'confirmAccountDeletion unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AuthDeleteAccountFailure();
    }
  }

  @override
  Future<void> resendSignupConfirmationEmail({required String email}) async {
    try {
      AppLogger.i('Resending signup confirmation to ${email.trim()}');
      await _client.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
        emailRedirectTo: AuthRedirectUrls.emailRedirectTo,
      );
      AppLogger.i('Signup confirmation resend accepted by Supabase');
    } on AuthException catch (error, stackTrace) {
      AppLogger.e(
        'resendSignupConfirmationEmail failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw _mapAuthException(error);
    } catch (error, stackTrace) {
      AppLogger.e(
        'resendSignupConfirmationEmail unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AuthUnknownFailure(
        'Não foi possível reenviar o e-mail de confirmação.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error, stackTrace) {
      AppLogger.e(
        'signOut failed, falling back to local session',
        error: error,
        stackTrace: stackTrace,
      );
      try {
        await _client.auth.signOut(scope: SignOutScope.local);
      } on AuthException catch (localError, localStack) {
        AppLogger.e(
          'local signOut failed',
          error: localError,
          stackTrace: localStack,
        );
        throw _mapAuthException(localError);
      } catch (localError, localStack) {
        AppLogger.e(
          'local signOut unexpected',
          error: localError,
          stackTrace: localStack,
        );
        throw const AuthUnknownFailure();
      }
    }
  }

  @override
  Future<Profile?> fetchProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles_app')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) {
        // Fallback before migration creates profiles_app.
        final fallback = await _client
            .from('profiles')
            .select(_profileSelect)
            .eq('id', userId)
            .maybeSingle();
        if (fallback == null) return null;
        return Profile.fromJson(Map<String, dynamic>.from(fallback));
      }
      return Profile.fromJson(Map<String, dynamic>.from(data));
    } catch (error, stackTrace) {
      AppLogger.e('fetchProfile failed', error: error, stackTrace: stackTrace);
      throw const AuthUnknownFailure('Não foi possível carregar o perfil.');
    }
  }

  @override
  Future<Profile> upsertProfile(Profile profile) async {
    try {
      final data = await _client
          .from('profiles')
          .upsert({
            'id': profile.id,
            'full_name': profile.fullName,
            'company_name': profile.companyName,
          })
          .select(_profileSelect)
          .single();
      return Profile.fromJson(Map<String, dynamic>.from(data));
    } catch (error, stackTrace) {
      AppLogger.e('upsertProfile failed', error: error, stackTrace: stackTrace);
      throw const AuthUnknownFailure('Não foi possível salvar o perfil.');
    }
  }

  @override
  Future<Profile> updateProfileFields({
    required String userId,
    required String fullName,
    required String companyName,
  }) async {
    try {
      final data = await _client
          .from('profiles')
          .update({
            'full_name': fullName.trim(),
            'company_name': companyName.trim(),
          })
          .eq('id', userId)
          .select(_profileSelect)
          .single();
      return Profile.fromJson(Map<String, dynamic>.from(data));
    } catch (error, stackTrace) {
      AppLogger.e(
        'updateProfileFields failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AuthUnknownFailure('Não foi possível salvar o perfil.');
    }
  }

  @override
  Future<Profile> markOnboardingCompleted(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .update({'onboarding_completed': true})
          .eq('id', userId)
          .select(_profileSelect)
          .single();
      return Profile.fromJson(Map<String, dynamic>.from(data));
    } catch (error, stackTrace) {
      AppLogger.e(
        'markOnboardingCompleted failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AuthUnknownFailure(
        'Não foi possível concluir o onboarding.',
      );
    }
  }

  @override
  Future<void> updateEmail({required String email}) async {
    try {
      final current = _mapUser(_client.auth.currentUser);
      if (current != null && !current.canChangeEmail) {
        throw const AuthEmailChangeNotAllowedFailure();
      }
      final trimmed = email.trim();
      final response = await _client.auth.updateUser(
        UserAttributes(email: trimmed),
        emailRedirectTo: AuthRedirectUrls.oauthRedirectTo,
      );
      if (response.user == null) {
        throw const AuthUnknownFailure(
          'Não foi possível atualizar o e-mail. Tente novamente.',
        );
      }
    } on AuthException catch (error, stackTrace) {
      AppLogger.e('updateEmail failed', error: error, stackTrace: stackTrace);
      throw _mapAuthException(error);
    } catch (error, stackTrace) {
      AppLogger.e(
        'updateEmail unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      if (error is AuthFailure) rethrow;
      throw const AuthUnknownFailure(
        'Não foi possível atualizar o e-mail. Tente novamente.',
      );
    }
  }

  @override
  Future<Profile> ensureProfileFromMetadata(String userId) async {
    final existing = await fetchProfile(userId);
    final metadata = _client.auth.currentUser?.userMetadata ?? {};
    final fullName = _displayNameFromMetadata(metadata);
    final companyName = metadata['company_name'] as String?;

    if (existing != null) {
      final needsUpdate =
          (existing.fullName == null || existing.fullName!.trim().isEmpty) ||
              (existing.companyName == null ||
                  existing.companyName!.trim().isEmpty);
      if (!needsUpdate) return existing;

      return upsertProfile(
        existing.copyWith(
          fullName: existing.fullName?.trim().isNotEmpty == true
              ? existing.fullName
              : fullName,
          companyName: existing.companyName?.trim().isNotEmpty == true
              ? existing.companyName
              : companyName,
        ),
      );
    }

    return upsertProfile(
      Profile(
        id: userId,
        fullName: fullName,
        companyName: companyName,
        plan: 'free',
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  String? _displayNameFromMetadata(Map<String, dynamic> metadata) {
    final candidates = [
      metadata['full_name'],
      metadata['name'],
      [
        metadata['given_name'],
        metadata['family_name'],
      ].whereType<String>().map((part) => part.trim()).where((part) => part.isNotEmpty).join(' '),
    ];

    for (final candidate in candidates) {
      if (candidate is! String) continue;
      final trimmed = candidate.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  @override
  Future<AuthUser?> recoverSessionFromCurrentUrl() async {
    try {
      final uri = Uri.base;
      final hasCode = uri.queryParameters.containsKey('code');
      final hasHashTokens = uri.fragment.contains('access_token') ||
          uri.fragment.contains('refresh_token');

      if (!hasCode && !hasHashTokens) {
        return currentUser();
      }

      final response = await _client.auth.getSessionFromUrl(uri);
      return _mapUser(response.session.user);
    } on AuthException catch (error, stackTrace) {
      AppLogger.e(
        'recoverSessionFromCurrentUrl failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw _mapAuthException(error);
    } catch (error, stackTrace) {
      if (error is AuthFailure) rethrow;
      AppLogger.e(
        'recoverSessionFromCurrentUrl unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      // Session may already have been recovered by supabase_flutter init.
      return currentUser();
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() => _signInWithOAuth(OAuthProvider.google);

  @override
  Future<AuthUser> signInWithApple() async {
    // iOS: native Sign in with Apple (system account / Face ID).
    // Web & Android: OAuth browser flow.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return _signInWithAppleNative();
    }
    return _signInWithOAuth(OAuthProvider.apple);
  }

  /// Native Apple ID sheet on iPhone/iPad (no Safari OAuth).
  Future<AuthUser> _signInWithAppleNative() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthUnknownFailure(
          'A Apple não retornou o token de autenticação.',
        );
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      final user = _mapUser(response.user ?? response.session?.user);
      if (user == null) {
        throw const AuthUnknownFailure(
          'Não foi possível obter o usuário autenticado.',
        );
      }

      // Apple only sends the name on the first authorization.
      final fullName = [
        credential.givenName,
        credential.familyName,
      ].whereType<String>().map((part) => part.trim()).where((part) => part.isNotEmpty).join(' ');
      if (fullName.isNotEmpty) {
        try {
          await _client.auth.updateUser(
            UserAttributes(data: {'full_name': fullName}),
          );
        } catch (error, stackTrace) {
          AppLogger.e(
            'Could not persist Apple full_name on first sign-in',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }

      return user;
    } on AuthFailure {
      rethrow;
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const AuthCancelledFailure();
      }
      AppLogger.e('Native Apple sign-in failed', error: error);
      throw AuthUnknownFailure(
        error.message.isNotEmpty
            ? error.message
            : 'Não foi possível autenticar com a Apple.',
      );
    } on MissingPluginException catch (error, stackTrace) {
      AppLogger.e(
        'Native Apple plugin missing — full rebuild required',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AuthUnknownFailure(
        'Login Apple nativo precisa de um rebuild completo do app '
        '(pare o app e rode flutter run de novo).',
      );
    } on AuthException catch (error, stackTrace) {
      AppLogger.e(
        'Apple signInWithIdToken failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw _mapAuthException(error);
    } catch (error, stackTrace) {
      if (error is AuthFailure) rethrow;
      AppLogger.e(
        'Native Apple sign-in unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw AuthUnknownFailure(
        error is PlatformException && (error.message?.isNotEmpty ?? false)
            ? error.message!
            : 'Não foi possível autenticar com a Apple. Tente novamente.',
      );
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  Future<AuthUser> _signInWithOAuth(OAuthProvider provider) async {
    try {
      final redirectTo = AuthRedirectUrls.oauthRedirectTo;
      // Always show the Google account picker (avoids silent SSO reuse).
      final queryParams = provider == OAuthProvider.google
          ? const {'prompt': 'select_account'}
          : null;
      AppLogger.i('OAuth $provider redirectTo=$redirectTo');

      if (kIsWeb) {
        final launched = await _client.auth.signInWithOAuth(
          provider,
          redirectTo: redirectTo,
          queryParams: queryParams,
        );
        if (!launched) throw const AuthCancelledFailure();

        final user = currentUser();
        if (user != null) return user;

        throw const AuthUnknownFailure(
          'Continue a autenticação na janela aberta.',
        );
      }

      // Mobile: ASWebAuthenticationSession / Chrome Custom Tabs.
      // Captures cheery:// callback in-sheet — no "Open in Cheery?" prompt,
      // and cancel dismisses immediately (no spinner delay).
      final oauth = await _client.auth.getOAuthSignInUrl(
        provider: provider,
        redirectTo: redirectTo,
        queryParams: queryParams,
      );

      late final String callbackUrl;
      try {
        callbackUrl = await FlutterWebAuth2.authenticate(
          url: oauth.url,
          callbackUrlScheme: 'cheery',
        );
      } on PlatformException catch (error) {
        if (error.code == 'CANCELED') {
          throw const AuthCancelledFailure();
        }
        AppLogger.e('OAuth web auth failed', error: error);
        throw AuthUnknownFailure(
          error.message ?? 'Não foi possível autenticar com o provedor.',
        );
      }

      final response =
          await _client.auth.getSessionFromUrl(Uri.parse(callbackUrl));
      final user = _mapUser(response.session.user);
      if (user == null) {
        throw const AuthUnknownFailure(
          'Não foi possível obter o usuário autenticado.',
        );
      }
      return user;
    } on AuthFailure {
      rethrow;
    } on AuthException catch (error, stackTrace) {
      AppLogger.e('OAuth failed', error: error, stackTrace: stackTrace);
      throw _mapAuthException(error);
    } catch (error, stackTrace) {
      if (error is AuthFailure) rethrow;
      AppLogger.e('OAuth unexpected', error: error, stackTrace: stackTrace);
      throw const AuthUnknownFailure();
    }
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    final email = user.email;
    if (email == null || email.isEmpty) return null;
    final providers = user.identities
            ?.map((identity) => identity.provider)
            .where((provider) => provider.isNotEmpty)
            .toList(growable: false) ??
        const <String>[];
    return AuthUser(
      id: user.id,
      email: email,
      identityProviders: providers,
    );
  }

  AuthFailure _mapAuthException(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials')) {
      return const AuthInvalidCredentialsFailure();
    }
    if (message.contains('user already registered') ||
        message.contains('already been registered')) {
      return const AuthEmailAlreadyInUseFailure();
    }
    if (message.contains('password') && message.contains('weak')) {
      return const AuthWeakPasswordFailure();
    }
    if (message.contains('email not confirmed')) {
      return const AuthEmailNotConfirmedFailure();
    }
    if (message.contains('email address') &&
        (message.contains('cannot be updated') ||
            message.contains('not allowed') ||
            message.contains('oauth'))) {
      return const AuthEmailChangeNotAllowedFailure();
    }
    return AuthUnknownFailure(error.message);
  }
}
