import 'dart:async';

import 'package:cheery/core/offline/connectivity_monitor.dart';
import 'package:cheery/core/offline/network_error.dart';
import 'package:cheery/core/offline/offline_store.dart';
import 'package:cheery/core/offline/sync_engine.dart';
import 'package:cheery/core/offline/sync_operation.dart';
import 'package:cheery/core/offline/sync_queue.dart';
import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/domain/auth_repository.dart';
import 'package:cheery/features/auth/domain/auth_user.dart';
import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/domain/sign_up_result.dart';

/// Caches profile reads and queues name/company/onboarding writes.
class OfflineAwareAuthRepository implements AuthRepository {
  OfflineAwareAuthRepository({
    required AuthRepository remote,
    required OfflineStore store,
    required SyncQueue queue,
    required SyncEngine engine,
    required ConnectivityMonitor connectivity,
  })  : _remote = remote,
        _store = store,
        _queue = queue,
        _engine = engine,
        _connectivity = connectivity;

  final AuthRepository _remote;
  final OfflineStore _store;
  final SyncQueue _queue;
  final SyncEngine _engine;
  final ConnectivityMonitor _connectivity;

  @override
  Stream<AuthUser?> watchAuthState() => _remote.watchAuthState();

  @override
  Stream<void> watchPasswordRecovery() => _remote.watchPasswordRecovery();

  @override
  AuthUser? currentUser() => _remote.currentUser();

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _remote.signInWithEmail(email: email, password: password);
  }

  @override
  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String companyName,
  }) {
    return _remote.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
      companyName: companyName,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _remote.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> updatePassword({required String newPassword}) {
    return _remote.updatePassword(newPassword: newPassword);
  }

  @override
  Future<void> requestAccountDeletion() {
    return _remote.requestAccountDeletion();
  }

  @override
  Future<void> confirmAccountDeletion({required String token}) {
    return _remote.confirmAccountDeletion(token: token);
  }

  @override
  Future<void> resendSignupConfirmationEmail({required String email}) {
    return _remote.resendSignupConfirmationEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    final userId = _remote.currentUser()?.id;
    try {
      await _remote.signOut();
    } finally {
      await _queue.clear();
      if (userId != null) {
        await _store.clearUser(userId);
      }
    }
  }

  @override
  Future<Profile?> fetchProfile(String userId) async {
    if (_connectivity.isOnline) {
      try {
        final profile = await _remote.fetchProfile(userId);
        if (profile != null) {
          await _store.saveProfile(userId, await _applyPending(profile));
        }
        return await _store.loadProfile(userId) ?? profile;
      } catch (error) {
        if (isInvalidSessionError(error)) rethrow;
        final cached = await _store.loadProfile(userId);
        if (cached != null) return cached;
        if (isLikelyNetworkError(error)) return null;
        rethrow;
      }
    }
    return _store.loadProfile(userId);
  }

  @override
  Future<Profile> upsertProfile(Profile profile) {
    return _remote.upsertProfile(profile);
  }

  @override
  Future<Profile> updateProfileFields({
    required String userId,
    required String fullName,
    required String companyName,
  }) async {
    final current =
        await _store.loadProfile(userId) ?? _stubProfile(userId);
    final updated = current.copyWith(
      fullName: fullName.trim(),
      companyName: companyName.trim(),
    );
    await _store.saveProfile(userId, updated);
    await _queue.enqueue(
      SyncOperation(
        id: '',
        seq: 0,
        entity: SyncEntity.profile,
        action: SyncAction.update,
        entityId: userId,
        payload: {
          'full_name': updated.fullName,
          'company_name': updated.companyName,
        },
        createdAt: DateTime.now().toUtc(),
      ),
    );
    unawaited(_engine.process());
    return updated;
  }

  @override
  Future<Profile> markOnboardingCompleted(String userId) async {
    final current =
        await _store.loadProfile(userId) ?? _stubProfile(userId);
    final updated = current.copyWith(onboardingCompleted: true);
    await _store.saveProfile(userId, updated);
    await _queue.enqueue(
      SyncOperation(
        id: '',
        seq: 0,
        entity: SyncEntity.profile,
        action: SyncAction.update,
        entityId: userId,
        payload: {'onboarding_completed': true},
        createdAt: DateTime.now().toUtc(),
      ),
    );
    unawaited(_engine.process());
    return updated;
  }

  @override
  Future<void> updateEmail({required String email}) {
    return _remote.updateEmail(email: email);
  }

  @override
  Future<Profile> ensureProfileFromMetadata(String userId) async {
    if (_connectivity.isOnline) {
      try {
        final profile = await _remote.ensureProfileFromMetadata(userId);
        final merged = await _applyPending(profile);
        await _store.saveProfile(userId, merged);
        return merged;
      } catch (error) {
        if (isInvalidSessionError(error)) rethrow;
        final cached = await _store.loadProfile(userId);
        if (cached != null) return cached;
        if (isLikelyNetworkError(error)) {
          throw const AuthNetworkFailure();
        }
        rethrow;
      }
    }
    final cached = await _store.loadProfile(userId);
    if (cached != null) return cached;
    throw const AuthNetworkFailure();
  }

  @override
  Future<AuthUser?> recoverSessionFromCurrentUrl() {
    return _remote.recoverSessionFromCurrentUrl();
  }

  @override
  Future<AuthUser> signInWithGoogle() => _remote.signInWithGoogle();

  @override
  Future<AuthUser> signInWithApple() => _remote.signInWithApple();

  Future<Profile> _applyPending(Profile profile) async {
    var next = profile;
    for (final op in await _queue.list()) {
      if (op.entity != SyncEntity.profile) continue;
      next = next.copyWith(
        fullName: (op.payload['full_name'] as String?) ?? next.fullName,
        companyName:
            (op.payload['company_name'] as String?) ?? next.companyName,
        onboardingCompleted: op.payload['onboarding_completed'] as bool? ??
            next.onboardingCompleted,
      );
    }
    return next;
  }

  Profile _stubProfile(String userId) {
    return Profile(
      id: userId,
      createdAt: DateTime.now().toUtc(),
    );
  }
}
