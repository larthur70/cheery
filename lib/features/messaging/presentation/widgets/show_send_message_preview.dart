import 'package:cheery/core/constants/app_breakpoints.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/messaging/presentation/widgets/send_message_preview_content.dart';
import 'package:flutter/material.dart';

/// Opens the send-message preview as a bottom sheet (mobile) or dialog (web).
Future<void> showSendMessagePreview(
  BuildContext context, {
  required String clientName,
  required String phone,
  required String initialMessage,
  required Map<String, String> variableInserts,
  String? clientId,
  String? templateId,
  Future<void> Function()? onWhatsAppOpened,
  Future<void> Function()? onMarkedSent,
}) {
  final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

  if (isMobile) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: SingleChildScrollView(
            child: SendMessagePreviewContent(
              clientName: clientName,
              phone: phone,
              initialMessage: initialMessage,
              variableInserts: variableInserts,
              clientId: clientId,
              templateId: templateId,
              onWhatsAppOpened: onWhatsAppOpened,
              onMarkedSent: onMarkedSent,
              showHandle: true,
            ),
          ),
        );
      },
    );
  }

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.background,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: SendMessagePreviewContent(
              clientName: clientName,
              phone: phone,
              initialMessage: initialMessage,
              variableInserts: variableInserts,
              clientId: clientId,
              templateId: templateId,
              onWhatsAppOpened: onWhatsAppOpened,
              onMarkedSent: onMarkedSent,
            ),
          ),
        ),
      );
    },
  );
}
