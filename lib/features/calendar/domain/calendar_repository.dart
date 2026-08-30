import 'package:cheery/features/calendar/domain/calendar_birthday.dart';

/// Contract for calendar birthday data.
abstract class CalendarRepository {
  Future<List<CalendarBirthday>> listBirthdays();
}
