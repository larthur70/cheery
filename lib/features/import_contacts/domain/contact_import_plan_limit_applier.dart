import 'package:cheery/features/billing/domain/plan_limits.dart';
import 'package:cheery/features/import_contacts/domain/contact_import_draft.dart';

/// Marks trailing field-ready Free-plan drafts that exceed remaining capacity.
abstract final class ContactImportPlanLimitApplier {
  /// [maxClients] null means unlimited (Pro).
  static List<ContactImportDraft> apply({
    required List<ContactImportDraft> drafts,
    required int currentClientCount,
    int? maxClients,
  }) {
    if (maxClients == null) {
      return [
        for (final draft in drafts)
          draft.copyWith(skippedForPlanLimit: false),
      ];
    }

    final remaining = maxClients - currentClientCount;
    var slotsLeft = remaining < 0 ? 0 : remaining;
    final result = <ContactImportDraft>[];

    for (final draft in drafts) {
      if (!draft.isFieldReady) {
        result.add(draft.copyWith(skippedForPlanLimit: false));
        continue;
      }
      if (slotsLeft > 0) {
        slotsLeft--;
        result.add(draft.copyWith(skippedForPlanLimit: false));
        continue;
      }
      result.add(draft.copyWith(skippedForPlanLimit: true));
    }

    return result;
  }

  static int? maxClientsForPlan({required bool isPro}) =>
      isPro ? null : PlanLimits.freeMaxClients;
}
