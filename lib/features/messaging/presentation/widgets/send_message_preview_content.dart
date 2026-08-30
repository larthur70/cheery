import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/messaging/domain/whatsapp_link_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shared preview body for the WhatsApp send bottom sheet / dialog.
class SendMessagePreviewContent extends StatefulWidget {
  const SendMessagePreviewContent({
    required this.clientName,
    required this.phone,
    required this.initialMessage,
    required this.variableInserts,
    this.clientId,
    this.templateId,
    this.onWhatsAppOpened,
    this.onMarkedSent,
    this.showHandle = false,
    super.key,
  });

  final String clientName;
  final String phone;
  final String initialMessage;
  /// Friendly token label → resolved value to insert on tap.
  final Map<String, String> variableInserts;
  final String? clientId;
  final String? templateId;
  /// Fired after the `wa.me` link opens successfully (analytics).
  final Future<void> Function()? onWhatsAppOpened;
  /// Called after WhatsApp opens successfully to persist "sent" status.
  final Future<void> Function()? onMarkedSent;
  final bool showHandle;

  static const whatsappIconAsset = 'assets/images/svgs/whatsapp-white-icon.svg';

  @override
  State<SendMessagePreviewContent> createState() =>
      _SendMessagePreviewContentState();
}

class _SendMessagePreviewContentState extends State<SendMessagePreviewContent> {
  late final TextEditingController _messageController;
  late final FocusNode _messageFocus;
  bool _editing = false;
  bool _launching = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: widget.initialMessage);
    _messageFocus = FocusNode();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  void _insertVariable(String value) {
    if (value.isEmpty) return;

    void doInsert() {
      final text = _messageController.text;
      final selection = _messageController.selection;
      final start = selection.isValid ? selection.start : text.length;
      final end = selection.isValid ? selection.end : text.length;
      final newText = text.replaceRange(start, end, value);
      _messageController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + value.length),
      );
      _messageFocus.requestFocus();
    }

    if (!_editing) {
      setState(() => _editing = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final text = _messageController.text;
        _messageController.selection =
            TextSelection.collapsed(offset: text.length);
        doInsert();
      });
      return;
    }

    doInsert();
  }

  Future<void> _openWhatsApp() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _showSnack('Escreva uma mensagem antes de enviar.');
      return;
    }

    final uri = WhatsAppLinkBuilder.build(
      phone: widget.phone,
      message: message,
    );
    if (uri == null) {
      _showSnack('Telefone inválido. Atualize o número do cliente.');
      return;
    }

    setState(() => _launching = true);
    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        _showSnack('Não foi possível abrir o WhatsApp.');
        return;
      }

      try {
        await widget.onWhatsAppOpened?.call();
      } catch (_) {}

      try {
        await widget.onMarkedSent?.call();
      } catch (_) {
        if (mounted) {
          _showSnack(
            'WhatsApp aberto, mas não foi possível marcar como enviado.',
          );
        }
      }

      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        _showSnack('Não foi possível abrir o WhatsApp.');
      }
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: widget.showHandle ? 8 : 24,
        bottom: 24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showHandle) ...[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cherry.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_border,
                color: AppColors.cherry,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Enviar Mensagem',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.inkMuted,
              ),
              children: [
                const TextSpan(text: 'Para '),
                TextSpan(
                  text: widget.clientName,
                  style: const TextStyle(
                    color: AppColors.cherry,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.visibility_outlined, size: 18, color: AppColors.ink),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Preview da Mensagem',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: _editing ? 'Concluir edição' : 'Editar mensagem',
                onPressed: () => setState(() => _editing = !_editing),
                icon: Icon(
                  _editing ? Icons.check : Icons.edit_outlined,
                  size: 20,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: _editing
                ? TextField(
                    controller: _messageController,
                    focusNode: _messageFocus,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.ink,
                      height: 1.45,
                    ),
                  )
                : SingleChildScrollView(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _messageController,
                        builder: (context, value, _) {
                          return Text(
                            value.text.isEmpty ? ' ' : value.text,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.ink,
                              height: 1.45,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
          if (widget.variableInserts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in widget.variableInserts.entries)
                  ActionChip(
                    avatar: const Icon(
                      Icons.add,
                      size: 16,
                      color: AppColors.cherry,
                    ),
                    label: Text(
                      entry.key,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.cherry,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: AppColors.cherrySoft,
                    side: BorderSide.none,
                    onPressed: entry.value.isEmpty
                        ? null
                        : () => _insertVariable(entry.value),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          CheeryButton(
            label: 'Abrir WhatsApp e enviar',
            expanded: true,
            isLoading: _launching,
            onPressed: _launching ? null : _openWhatsApp,
            leading: SvgPicture.asset(
              SendMessagePreviewContent.whatsappIconAsset,
              width: 18,
              height: 18,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
              placeholderBuilder: (_) => const SizedBox(width: 18, height: 18),
            ),
          ),
          const SizedBox(height: 12),
          CheeryButton(
            label: 'Cancelar',
            variant: CheeryButtonVariant.outlined,
            expanded: true,
            onPressed: _launching ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
