import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/whatsapp_automation/domain/whatsapp_failure.dart';
import 'package:cheery/features/whatsapp_automation/presentation/controllers/whatsapp_connection_controller.dart';
import 'package:cheery/features/whatsapp_automation/presentation/widgets/whatsapp_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WhatsAppManageEntryScreen extends StatelessWidget {
  const WhatsAppManageEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => const WhatsAppManageMobile(),
      desktop: (_) => const WhatsAppManageWeb(),
    );
  }
}

class WhatsAppManageWeb extends ConsumerWidget {
  const WhatsAppManageWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: WhatsAppManagePanel(
                onClose: () => context.pop(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WhatsAppManageMobile extends ConsumerWidget {
  const WhatsAppManageMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('WhatsApp Business'),
        backgroundColor: AppColors.background,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: WhatsAppManagePanel(),
      ),
    );
  }
}

class WhatsAppManagePanel extends ConsumerWidget {
  const WhatsAppManagePanel({this.onClose, super.key});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(whatsappConnectionControllerProvider);

    return connectionAsync.when(
      loading: () => const CheeryLoading(message: 'Carregando status…'),
      error: (error, _) => Text(
        error is WhatsAppFailure
            ? error.message
            : 'Não foi possível carregar o status.',
        style: const TextStyle(color: AppColors.danger),
      ),
      data: (connection) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onClose != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'WhatsApp Business',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.cherry,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            WhatsAppStatusBadge(connection: connection),
            if (connection.lastError != null) ...[
              const SizedBox(height: 12),
              Text(
                connection.lastError!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 24),
            if (connection.isReady)
              CheeryButton(
                label: 'Desconectar',
                variant: CheeryButtonVariant.outlined,
                onPressed: () async {
                  try {
                    await ref
                        .read(whatsappConnectionControllerProvider.notifier)
                        .disconnect();
                    if (context.mounted && onClose != null) onClose!();
                  } on WhatsAppFailure catch (failure) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(failure.message)),
                    );
                  }
                },
              )
            else
              CheeryButton(
                label: 'Conectar novamente',
                onPressed: () async {
                  try {
                    await ref
                        .read(whatsappConnectionControllerProvider.notifier)
                        .startConnect();
                  } on WhatsAppFailure catch (failure) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(failure.message)),
                    );
                  }
                },
              ),
          ],
        );
      },
    );
  }
}
