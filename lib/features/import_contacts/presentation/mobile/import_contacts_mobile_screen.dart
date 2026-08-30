import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/import_contacts/domain/contact_import_step.dart';
import 'package:cheery/features/import_contacts/presentation/controllers/import_contacts_controller.dart';
import 'package:cheery/features/import_contacts/presentation/widgets/contact_import_confirm_step.dart';
import 'package:cheery/features/import_contacts/presentation/widgets/contact_review_step.dart';
import 'package:cheery/features/import_contacts/presentation/widgets/contact_select_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ImportContactsMobileScreen extends ConsumerWidget {
  const ImportContactsMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importContactsControllerProvider);
    final controller = ref.read(importContactsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cherry),
          onPressed: () {
            if (state.step == ContactImportStep.select ||
                state.step == ContactImportStep.confirmation) {
              context.go(AppRoutes.clients);
            } else {
              controller.goBack();
            }
          },
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: switch (state.step) {
            ContactImportStep.select => const ContactSelectStep(),
            ContactImportStep.review => const ContactReviewStep(),
            ContactImportStep.confirmation => state.summary == null
                ? const ContactSelectStep()
                : ContactImportConfirmStep(
                    summary: state.summary!,
                    onGoToClients: () => context.go(AppRoutes.clients),
                    onImportAgain: controller.reset,
                  ),
          },
        ),
      ),
    );
  }
}
