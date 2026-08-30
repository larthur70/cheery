import 'package:cheery/core/providers/supabase_provider.dart';
import 'package:cheery/features/billing/data/billing_repository_impl.dart';
import 'package:cheery/features/billing/domain/billing_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final billingRepositoryProvider = Provider<BillingRepository?>((ref) {
  final ready = ref.watch(supabaseReadyProvider);
  if (!ready) return null;
  return BillingRepositoryImpl(ref.watch(supabaseClientProvider));
});
