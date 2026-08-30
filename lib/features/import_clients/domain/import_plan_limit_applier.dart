import 'package:cheery/features/billing/domain/plan_limits.dart';
import 'package:cheery/features/import_clients/domain/import_row_draft.dart';
import 'package:cheery/features/import_clients/domain/import_validation_result.dart';

/// Marks trailing valid Free-plan rows that exceed remaining client capacity.
abstract final class ImportPlanLimitApplier {
  /// [maxClients] null means unlimited (Pro).
  static ImportValidationResult apply({
    required ImportValidationResult validation,
    required int currentClientCount,
    int? maxClients,
  }) {
    if (maxClients == null) return validation;

    final remaining = maxClients - currentClientCount;
    var slotsLeft = remaining < 0 ? 0 : remaining;

    final rows = <ImportRowDraft>[];
    for (final row in validation.rows) {
      if (!row.isValid) {
        rows.add(row);
        continue;
      }
      if (slotsLeft > 0) {
        slotsLeft--;
        rows.add(row.copyWith(skippedForPlanLimit: false));
        continue;
      }
      rows.add(row.copyWith(skippedForPlanLimit: true));
    }

    return ImportValidationResult(rows: rows);
  }

  static int? maxClientsForPlan({required bool isPro}) =>
      isPro ? null : PlanLimits.freeMaxClients;
}
