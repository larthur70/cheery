/// Typed failures for calendar operations.
sealed class CalendarFailure implements Exception {
  const CalendarFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class CalendarNotReadyFailure extends CalendarFailure {
  const CalendarNotReadyFailure([
    super.message = 'Supabase não configurado. Verifique assets/env/.env.',
  ]);
}

final class CalendarNetworkFailure extends CalendarFailure {
  const CalendarNetworkFailure([
    super.message = 'Falha de conexão. Tente novamente.',
  ]);
}

final class CalendarUnknownFailure extends CalendarFailure {
  const CalendarUnknownFailure([
    super.message = 'Não foi possível carregar o calendário. Tente novamente.',
  ]);
}
