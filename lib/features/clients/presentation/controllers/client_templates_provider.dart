import 'package:cheery/features/templates/domain/template_summary.dart';
import 'package:cheery/features/templates/domain/templates_failure.dart';
import 'package:cheery/features/templates/presentation/controllers/templates_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientTemplatesProvider =
    FutureProvider<List<TemplateSummary>>((ref) async {
  final repository = ref.watch(templatesRepositoryProvider);
  if (repository == null) return const [];

  try {
    await repository.ensureDefaultTemplate();
  } on TemplatesFailure {
    // Offline / empty cache: still show whatever templates we have locally.
  }
  return repository.listSummaries();
});
