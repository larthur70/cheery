import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/messaging/domain/birthday_message_composer.dart';
import 'package:cheery/features/messaging/presentation/widgets/set_birthday_message_sent_status.dart';
import 'package:cheery/features/messaging/presentation/widgets/show_send_message_preview.dart';
import 'package:cheery/features/templates/domain/templates_failure.dart';
import 'package:cheery/features/templates/presentation/controllers/templates_repository_provider.dart';
import 'package:cheery/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves the client template, fills the message, and opens the preview UI.
Future<void> openSendWhatsAppFlow(
  BuildContext context,
  WidgetRef ref, {
  required String clientId,
  required String clientName,
  required String phone,
  required String templateId,
}) async {
  final repository = ref.read(templatesRepositoryProvider);
  if (repository == null) {
    _showSnack(context, 'Conecte-se para enviar mensagens.');
    return;
  }

  if (phone.trim().isEmpty) {
    _showSnack(context, 'Este cliente não tem telefone cadastrado.');
    return;
  }

  try {
    final template = await repository.getById(templateId);
    final companyName =
        ref.read(currentProfileProvider).valueOrNull?.companyName?.trim() ??
            '';

    final message = BirthdayMessageComposer.compose(
      template: template,
      clientName: clientName,
      companyName: companyName,
    );
    final variableInserts = BirthdayMessageComposer.variableInserts(
      template: template,
      clientName: clientName,
      companyName: companyName,
    );

    if (!context.mounted) return;

    await showSendMessagePreview(
      context,
      clientName: clientName,
      phone: phone,
      initialMessage: message,
      variableInserts: variableInserts,
      clientId: clientId,
      templateId: templateId,
      onWhatsAppOpened: () async {
        await ref.read(analyticsServiceProvider).trackWhatsappAberto(
              clienteId: clientId,
              templateId: templateId,
            );
      },
      onMarkedSent: () => setBirthdayMessageSentStatus(
        ref,
        clientId: clientId,
        sent: true,
      ),
    );
  } on TemplatesFailure catch (failure) {
    if (context.mounted) {
      _showSnack(context, failure.message);
    }
  } catch (_) {
    if (context.mounted) {
      _showSnack(context, 'Não foi possível carregar o template.');
    }
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
