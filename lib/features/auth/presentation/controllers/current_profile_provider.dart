import 'package:cheery/core/offline/network_error.dart';
import 'package:cheery/features/auth/domain/auth_failure.dart';
import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(authControllerProvider).valueOrNull;
  final repository = ref.watch(authRepositoryProvider);
  if (user == null || repository == null) return null;

  try {
    return await repository.ensureProfileFromMetadata(user.id);
  } catch (error) {
    // Only drop the session when the JWT itself is invalid — never on
    // a missing network, or the user would be kicked out while offline.
    if (!isInvalidSessionError(error)) {
      if (error is AuthNetworkFailure || isLikelyNetworkError(error)) {
        return null;
      }
      if (error is AuthFailure) rethrow;
      throw const AuthUnknownFailure('Não foi possível carregar o perfil.');
    }
    try {
      await ref.read(authControllerProvider.notifier).signOut();
    } catch (_) {
      // Ignore secondary sign-out failures.
    }
    if (error is AuthFailure) rethrow;
    throw const AuthUnknownFailure(
      'Sessão inválida. Faça login novamente.',
    );
  }
});
