/// Typed failures for client import operations.
sealed class ImportClientsFailure implements Exception {
  const ImportClientsFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ImportFileInvalidFailure extends ImportClientsFailure {
  const ImportFileInvalidFailure([
    super.message = 'Arquivo inválido. Envie um .CSV ou .XLSX.',
  ]);
}

final class ImportFileTooLargeFailure extends ImportClientsFailure {
  const ImportFileTooLargeFailure([
    super.message =
        'A planilha excede o limite de 2 MB ou 5000 linhas.',
  ]);
}

final class ImportFileEmptyFailure extends ImportClientsFailure {
  const ImportFileEmptyFailure([
    super.message = 'A planilha está vazia ou sem cabeçalho.',
  ]);
}

final class ImportMappingIncompleteFailure extends ImportClientsFailure {
  const ImportMappingIncompleteFailure([
    super.message = 'Mapeie as colunas obrigatórias: Nome, Telefone e Aniversário.',
  ]);
}

final class ImportNoValidRowsFailure extends ImportClientsFailure {
  const ImportNoValidRowsFailure([
    super.message = 'Nenhum registro válido para importar.',
  ]);
}

final class ImportNotReadyFailure extends ImportClientsFailure {
  const ImportNotReadyFailure([
    super.message = 'Supabase não configurado. Verifique assets/env/.env.',
  ]);
}

final class ImportUnknownFailure extends ImportClientsFailure {
  const ImportUnknownFailure([
    super.message = 'Não foi possível concluir a importação. Tente novamente.',
  ]);
}
