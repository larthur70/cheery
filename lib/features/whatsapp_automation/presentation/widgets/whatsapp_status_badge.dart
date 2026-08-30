import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_connection.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_integration_status.dart';
import 'package:flutter/material.dart';

/// Compact connection status chip for Home / manage screens.
class WhatsAppStatusBadge extends StatelessWidget {
  const WhatsAppStatusBadge({
    required this.connection,
    this.onTap,
    super.key,
  });

  final WhatsAppConnection connection;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final connected = connection.isReady;
    final label = connected
        ? (connection.displayPhone != null
            ? 'WhatsApp ${connection.displayPhone}'
            : 'WhatsApp conectado')
        : connection.status == WhatsAppIntegrationStatus.needsReauth
            ? 'Reconectar WhatsApp'
            : connection.status == WhatsAppIntegrationStatus.connecting
                ? 'Conectando…'
                : 'WhatsApp desconectado';

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: connected
            ? const Color(0xFFD4EDDA)
            : AppColors.blushDeep,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: connected ? const Color(0xFF155724) : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            connected ? Icons.check_circle : Icons.chat_outlined,
            size: 16,
            color: connected ? const Color(0xFF155724) : AppColors.cherry,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: connected
                        ? const Color(0xFF155724)
                        : AppColors.cherry,
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: child,
    );
  }
}
