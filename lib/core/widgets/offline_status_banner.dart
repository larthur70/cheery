import 'package:cheery/core/offline/offline_providers.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Non-blocking chip: the app stays usable while writes wait in the outbox.
class OfflineStatusBanner extends ConsumerWidget {
  const OfflineStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider).valueOrNull ?? true;
    final pending = ref.watch(pendingSyncCountProvider).valueOrNull ?? 0;
    ref.watch(syncEngineProvider);

    if (online && pending == 0) return const SizedBox.shrink();

    final message = online
        ? 'Enviando $pending ${pending == 1 ? 'alteração' : 'alterações'}…'
        : pending > 0
            ? 'Sem internet · $pending ${pending == 1 ? 'alteração aguardando' : 'alterações aguardando'}'
            : 'Sem internet · você pode continuar usando o app';

    return Material(
      color: online ? AppColors.mintSoft : AppColors.cherrySoft,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Icon(
                online ? Icons.cloud_upload_outlined : Icons.cloud_off_outlined,
                size: 18,
                color: online ? AppColors.mint : AppColors.cherry,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
