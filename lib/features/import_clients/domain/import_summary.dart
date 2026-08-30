/// Final outcome of a batch import.
class ImportSummary {
  const ImportSummary({
    required this.imported,
    required this.skipped,
    required this.errors,
    this.errorMessage,
  });

  final int imported;
  final int skipped;
  final int errors;
  final String? errorMessage;

  bool get hasPersistenceError => errors > 0 && imported == 0;
}
