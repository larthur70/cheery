import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_connection.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_connection_repository.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_failure.dart';
import 'package:cheery/features/whatsapp_automation/presentation/controllers/whatsapp_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final whatsappConnectionControllerProvider =
    AsyncNotifierProvider<WhatsAppConnectionController, WhatsAppConnection>(
  WhatsAppConnectionController.new,
);

class WhatsAppConnectionController
    extends AsyncNotifier<WhatsAppConnection> {
  WhatsAppConnectionRepository get _repository {
    final repository = ref.read(whatsappRepositoryProvider);
    if (repository == null) {
      throw const WhatsAppNotReadyFailure();
    }
    return repository;
  }

  @override
  Future<WhatsAppConnection> build() async {
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    if (profile != null) {
      return _fromProfile(profile);
    }

    final repository = ref.watch(whatsappRepositoryProvider);
    if (repository == null) return WhatsAppConnection.disconnected;
    return repository.refreshStatus();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.refreshStatus());
    ref.invalidate(currentProfileProvider);
  }

  /// Starts Meta Embedded Signup in the browser.
  Future<void> startConnect() async {
    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile != null && profile.isFree) {
      throw const WhatsAppNotProFailure();
    }

    final url = await _repository.startConnect();
    final launched = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      throw const WhatsAppOAuthFailure(
        'Não foi possível abrir a página de conexão do WhatsApp.',
      );
    }
    ref.invalidate(currentProfileProvider);
    await refresh();
  }

  Future<void> completeConnect({
    String? code,
    String? phoneNumberId,
    String? wabaId,
    String? displayPhone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.completeConnect(
        code: code,
        phoneNumberId: phoneNumberId,
        wabaId: wabaId,
        displayPhone: displayPhone,
      ),
    );
    ref.invalidate(currentProfileProvider);
  }

  Future<void> disconnect() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.disconnect);
    ref.invalidate(currentProfileProvider);
  }

  static WhatsAppConnection _fromProfile(Profile profile) {
    return WhatsAppConnection(
      connected: profile.whatsappConnected,
      status: profile.whatsappIntegrationStatus,
      displayPhone: profile.whatsappDisplayPhone,
      connectedAt: profile.whatsappConnectedAt,
      lastError: profile.whatsappLastError,
    );
  }
}
