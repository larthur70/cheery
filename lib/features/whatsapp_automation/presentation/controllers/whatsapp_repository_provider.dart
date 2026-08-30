import 'package:cheery/core/providers/supabase_provider.dart';
import 'package:cheery/features/whatsapp_automation/data/whatsapp_connection_repository_impl.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_connection_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final whatsappRepositoryProvider =
    Provider<WhatsAppConnectionRepository?>((ref) {
  final ready = ref.watch(supabaseReadyProvider);
  if (!ready) return null;
  return WhatsAppConnectionRepositoryImpl(ref.watch(supabaseClientProvider));
});
