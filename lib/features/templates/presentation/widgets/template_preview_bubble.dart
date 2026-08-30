import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// WhatsApp-style message bubble for live template preview.
class TemplatePreviewBubble extends StatelessWidget {
  const TemplatePreviewBubble({
    required this.text,
    this.companyLabel = 'Nome da empresa',
    this.compact = false,
    super.key,
  });

  final String text;
  final String companyLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final timeLabel = TimeOfDay.now().format(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECE5DD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: const Color(0xFF075E54),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.storefront, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          companyLabel,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'online',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          text.isEmpty ? ' ' : text,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.ink,
                                height: 1.4,
                              ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeLabel,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.inkMuted,
                                  fontSize: 11,
                                ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.done_all,
                            size: 14,
                            color: Color(0xFF53BDEB),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
