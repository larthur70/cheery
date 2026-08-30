import 'package:cheery/features/auth/presentation/controllers/auth_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Set from [main] before Supabase.initialize (tokens may be cleared after).
final passwordRecoveryBootstrapProvider = Provider<bool>((ref) => false);

/// True while the user arrived via a Supabase password-recovery link.
/// Keeps GoRouter on `/auth/reset-password` instead of bouncing to `/home`.
final passwordRecoveryPendingProvider =
    NotifierProvider<PasswordRecoveryPending, bool>(
  PasswordRecoveryPending.new,
);

class PasswordRecoveryPending extends Notifier<bool> {
  @override
  bool build() {
    final bootstrapped = ref.watch(passwordRecoveryBootstrapProvider);
    final repository = ref.watch(authRepositoryProvider);

    if (repository != null) {
      final sub = repository.watchPasswordRecovery().listen((_) {
        state = true;
      });
      ref.onDispose(sub.cancel);
    }

    return bootstrapped;
  }

  void clear() => state = false;

  void markPending() => state = true;
}

/// Call before [Supabase.initialize] so fragment/query tokens are still present.
bool detectPasswordRecoveryFromUri(Uri uri) {
  if (uri.path.contains('/auth/reset-password')) return true;
  if (uri.queryParameters['type'] == 'recovery') return true;
  final fragment = Uri.splitQueryString(uri.fragment);
  return fragment['type'] == 'recovery';
}
