import 'package:cheery/core/utils/app_logger.dart';
import 'package:cheery/features/calendar/domain/calendar_birthday.dart';
import 'package:cheery/features/calendar/domain/calendar_failure.dart';
import 'package:cheery/features/calendar/domain/calendar_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl(this._client);

  final SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const CalendarUnknownFailure('Usuário não autenticado.');
    }
    return id;
  }

  @override
  Future<List<CalendarBirthday>> listBirthdays() async {
    try {
      final rows = <Map<String, dynamic>>[];
      const pageSize = 200;
      const maxRows = 2000;
      var from = 0;
      while (rows.length < maxRows) {
        final page = await _client
            .from('clients')
            .select(
              'id, name, phone, template_id, birth_date, message_sent_year, '
              'automatic_enabled',
            )
            .eq('user_id', _userId)
            .order('birth_date')
            .range(from, from + pageSize - 1);
        for (final row in page) {
          rows.add(Map<String, dynamic>.from(row as Map));
        }
        if (page.length < pageSize) break;
        from += pageSize;
      }

      return rows
          .map(
            (row) => CalendarBirthday.fromJson(
              Map<String, dynamic>.from(row)..['phone'] = (row['phone'] as String?) ?? '',
            ),
          )
          .toList();
    } on CalendarFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      AppLogger.e(
        'listBirthdays failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw CalendarUnknownFailure(error.message);
    } catch (error, stackTrace) {
      AppLogger.e(
        'listBirthdays unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw const CalendarNetworkFailure();
    }
  }
}
