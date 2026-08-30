import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/import_clients/presentation/web/import_clients_web_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Entry point for the client import wizard (web only).
class ImportClientsEntryScreen extends StatelessWidget {
  const ImportClientsEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => const _ImportClientsWebOnlyScreen(),
      desktop: (_) => const ImportClientsWebScreen(),
    );
  }
}

class _ImportClientsWebOnlyScreen extends StatelessWidget {
  const _ImportClientsWebOnlyScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cherry),
          onPressed: () => context.go(AppRoutes.clients),
        ),
        title: Text(
          'Importar Clientes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.cherry,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.desktop_windows_outlined,
                size: 56,
                color: AppColors.cherry,
              ),
              const SizedBox(height: 16),
              Text(
                'Importação disponível na web',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Para importar clientes por CSV ou Excel, use o Cheery no computador.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.inkMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              CheeryButton(
                label: 'Voltar para clientes',
                onPressed: () => context.go(AppRoutes.clients),
                expanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
