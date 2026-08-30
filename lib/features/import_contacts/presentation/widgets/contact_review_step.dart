import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/platform/store_compliance.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_button.dart';
import 'package:cheery/features/billing/domain/plan_limits.dart';
import 'package:cheery/features/import_contacts/domain/contact_import_draft.dart';
import 'package:cheery/features/import_contacts/presentation/controllers/import_contacts_controller.dart';
import 'package:cheery/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ContactReviewStep extends ConsumerStatefulWidget {
  const ContactReviewStep({super.key});

  @override
  ConsumerState<ContactReviewStep> createState() => _ContactReviewStepState();
}

class _ContactReviewStepState extends ConsumerState<ContactReviewStep>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate(ContactImportDraft draft) async {
    final now = DateTime.now();
    final initial =
        draft.birthDate ?? DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Data de aniversário',
      cancelText: 'Cancelar',
      confirmText: 'Salvar',
    );
    if (picked == null || !mounted) return;
    ref
        .read(importContactsControllerProvider.notifier)
        .updateDraftBirthDate(draft.contactId, picked);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importContactsControllerProvider);
    final controller = ref.read(importContactsControllerProvider.notifier);
    final ready = state.readyDrafts;
    final pending = state.pendingDrafts;
    final excluded = state.excludedDrafts;
    final planLimitCount = state.planLimitSkippedCount;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatChip(
              label: '${ready.length} serão importados',
              color: AppColors.success,
              background: AppColors.mintSoft,
            ),
            if (planLimitCount > 0)
              _StatChip(
                label: '$planLimitCount fora do limite Free',
                color: AppColors.cherry,
                background: AppColors.blushDeep,
              ),
            if (pending.length > planLimitCount)
              _StatChip(
                label: '${pending.length - planLimitCount} pendente(s)',
                color: AppColors.warning,
                background: const Color(0xFFFFF0D6),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Confira os dados antes de importar. Contatos pendentes podem '
          'ser completados; removidos podem ser restaurados.'
          '${planLimitCount > 0 ? ' Contatos fora do limite Free não serão importados.' : ''}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.inkMuted,
              ),
        ),
        if (planLimitCount > 0) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blushDeep,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.cherry.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      StoreCompliance.hideExternalPayments
                          ? Icons.info_outline
                          : Icons.workspace_premium_outlined,
                      color: AppColors.cherry,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        StoreCompliance.hideExternalPayments
                            ? '$planLimitCount contato(s) não serão importados. '
                                '${StoreCompliance.limitReached} '
                                '(máx. ${PlanLimits.freeMaxClients} clientes). '
                                'Os primeiros que cabem no limite serão importados.'
                            : '$planLimitCount contato(s) não serão importados '
                                'por causa do limite do plano Free '
                                '(máx. ${PlanLimits.freeMaxClients} clientes). '
                                'Os primeiros que cabem no limite serão importados.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.cherry,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                      ),
                    ),
                  ],
                ),
                if (!StoreCompliance.hideExternalPayments) ...[
                  const SizedBox(height: 12),
                  CheeryButton(
                    label: 'Ver planos',
                    icon: Icons.workspace_premium_outlined,
                    variant: CheeryButtonVariant.filled,
                    onPressed: () => context.push(
                      AppRoutes.profilePlansFrom(
                        AssinaturaOrigemGatilho.limiteClientes.wireValue,
                      ),
                    ),
                    expanded: true,
                  ),
                ],
              ],
            ),
          ),
        ],
        if (state.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            state.errorMessage!,
            style: const TextStyle(color: AppColors.danger),
          ),
        ],
        const SizedBox(height: 12),
        Material(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.cherry,
            unselectedLabelColor: AppColors.inkMuted,
            indicatorColor: AppColors.cherry,
            isScrollable: true,
            tabs: [
              Tab(text: 'Prontos (${ready.length})'),
              Tab(text: 'Pendentes (${pending.length})'),
              Tab(text: 'Removidos (${excluded.length})'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _DraftList(
                drafts: ready,
                emptyMessage: 'Nenhum contato pronto ainda. '
                    'Complete a data nos pendentes.',
                dateFormat: dateFormat,
                onEditBirthday: _pickBirthDate,
                onExclude: controller.excludeDraft,
              ),
              _DraftList(
                drafts: pending,
                emptyMessage: 'Nada pendente — todos estão prontos.',
                dateFormat: dateFormat,
                onEditBirthday: _pickBirthDate,
                onExclude: controller.excludeDraft,
                emphasizePending: true,
              ),
              _DraftList(
                drafts: excluded,
                emptyMessage: 'Nenhum contato removido.',
                dateFormat: dateFormat,
                onEditBirthday: _pickBirthDate,
                onRestore: controller.restoreDraft,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          ready.isEmpty
              ? (planLimitCount > 0
                  ? (StoreCompliance.hideExternalPayments
                      ? StoreCompliance.limitReached
                      : 'Nenhum contato cabe no limite Free. Remova alguns '
                          'já cadastrados ou faça upgrade para Pro.')
                  : 'Preencha o aniversário dos pendentes ou volte e '
                      'ajuste a seleção.')
              : '${ready.length} serão importados'
                  '${planLimitCount > 0 ? ' · $planLimitCount fora do limite' : ''}'
                  '${pending.length > planLimitCount ? ' · ${pending.length - planLimitCount} pendente(s)' : ''}'
                  '${excluded.isNotEmpty ? ' · ${excluded.length} removido(s)' : ''}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: state.authorizationConfirmed,
          onChanged: (value) =>
              controller.setAuthorizationConfirmed(value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.cherry,
          title: Text(
            'Confirmo que tenho autorização desses contatos para receber mensagem',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
          ),
        ),
        const SizedBox(height: 10),
        CheeryButton(
          label: ready.isEmpty
              ? 'Nenhum pronto para importar'
              : 'Importar ${ready.length} contato(s)',
          icon: Icons.download_done_outlined,
          isLoading: state.isImporting,
          onPressed: !state.canImport ? null : controller.confirmImport,
          expanded: true,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DraftList extends StatelessWidget {
  const _DraftList({
    required this.drafts,
    required this.emptyMessage,
    required this.dateFormat,
    required this.onEditBirthday,
    this.onExclude,
    this.onRestore,
    this.emphasizePending = false,
  });

  final List<ContactImportDraft> drafts;
  final String emptyMessage;
  final DateFormat dateFormat;
  final Future<void> Function(ContactImportDraft draft) onEditBirthday;
  final void Function(String contactId)? onExclude;
  final void Function(String contactId)? onRestore;
  final bool emphasizePending;

  @override
  Widget build(BuildContext context) {
    if (drafts.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.inkMuted),
        ),
      );
    }

    return ListView.separated(
      itemCount: drafts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final draft = drafts[index];
        return _DraftCard(
          draft: draft,
          dateFormat: dateFormat,
          emphasizePending: emphasizePending,
          onEditBirthday: () => onEditBirthday(draft),
          onExclude:
              onExclude == null ? null : () => onExclude!(draft.contactId),
          onRestore:
              onRestore == null ? null : () => onRestore!(draft.contactId),
        );
      },
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.draft,
    required this.dateFormat,
    required this.onEditBirthday,
    this.onExclude,
    this.onRestore,
    this.emphasizePending = false,
  });

  final ContactImportDraft draft;
  final DateFormat dateFormat;
  final VoidCallback onEditBirthday;
  final VoidCallback? onExclude;
  final VoidCallback? onRestore;
  final bool emphasizePending;

  @override
  Widget build(BuildContext context) {
    final pendingReason = draft.pendingReason;
    final canEditBirthday = !draft.excluded &&
        !draft.alreadyRegistered &&
        !draft.duplicateInSelection;
    final planLimited = draft.skippedForPlanLimit;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: planLimited
            ? AppColors.blushDeep.withValues(alpha: 0.55)
            : emphasizePending && !draft.isReady
                ? AppColors.blushDeep.withValues(alpha: 0.35)
                : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: planLimited
              ? AppColors.cherry.withValues(alpha: 0.45)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  draft.name.isEmpty ? 'Sem nome' : draft.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (draft.alreadyRegistered)
                const _Badge(
                  label: 'Já cadastrado',
                  color: AppColors.inkMuted,
                  background: AppColors.blush,
                )
              else if (draft.excluded)
                const _Badge(
                  label: 'Removido',
                  color: AppColors.inkMuted,
                  background: AppColors.blush,
                )
              else if (draft.isReady)
                const _Badge(
                  label: 'Pronto',
                  color: AppColors.success,
                  background: AppColors.mintSoft,
                )
              else if (planLimited)
                const _Badge(
                  label: 'Fora do limite Free',
                  color: AppColors.cherry,
                  background: AppColors.blushDeep,
                )
              else if (pendingReason != null)
                _Badge(
                  label: pendingReason,
                  color: AppColors.warning,
                  background: const Color(0xFFFFF0D6),
                ),
              if (onExclude != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Remover da importação',
                  onPressed: onExclude,
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.inkMuted,
                  visualDensity: VisualDensity.compact,
                ),
              ],
              if (onRestore != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Restaurar',
                  onPressed: onRestore,
                  icon: const Icon(Icons.undo, size: 18),
                  color: AppColors.cherry,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
          if (planLimited) ...[
            const SizedBox(height: 6),
            Text(
              ContactImportDraft.planLimitSkipMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.cherry,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            draft.phone.isEmpty ? 'Telefone inválido' : draft.phone,
            style: TextStyle(
              color:
                  draft.hasValidPhone ? AppColors.inkMuted : AppColors.danger,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!draft.excluded) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: canEditBirthday ? onEditBirthday : null,
                    icon: const Icon(Icons.cake_outlined, size: 16),
                    label: Text(
                      draft.birthDate == null
                          ? 'Definir aniversário'
                          : dateFormat.format(draft.birthDate!),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: draft.birthDate == null
                          ? AppColors.warning
                          : AppColors.cherry,
                      side: BorderSide(
                        color: draft.birthDate == null
                            ? AppColors.warning
                            : AppColors.border,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
