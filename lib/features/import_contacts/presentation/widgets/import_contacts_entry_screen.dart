import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/import_contacts/presentation/mobile/import_contacts_mobile_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Contact import is device-only (address book). Web always shows guidance.
class ImportContactsEntryScreen extends StatelessWidget {
  const ImportContactsEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const _ImportContactsMobileOnlyScreen();
    }

    return ResponsiveBuilder(
      mobile: (_) => const ImportContactsMobileScreen(),
      desktop: (_) => const _ImportContactsMobileOnlyScreen(),
    );
  }
}

class _ImportContactsMobileOnlyScreen extends StatelessWidget {
  const _ImportContactsMobileOnlyScreen();

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
          'Importar contatos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.cherry,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.smartphone_outlined,
                    size: 56,
                    color: AppColors.cherry,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Disponível no app mobile',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A importação da agenda do aparelho só funciona no app. '
                    'Na web, use a importação por planilha.',
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
        ),
      ),
    );
  }
}
