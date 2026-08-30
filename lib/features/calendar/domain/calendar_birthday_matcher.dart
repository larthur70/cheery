import 'package:cheery/core/utils/birthday_date.dart';
import 'package:cheery/features/calendar/domain/calendar_birthday.dart';

/// Pure helpers for matching birthdays by month/day (year ignored).
abstract final class CalendarBirthdayMatcher {
  static bool matchesDay(CalendarBirthday birthday, DateTime day) {
    return BirthdayDate.matchesCalendarDay(birthday.birthDate, day);
  }

  static List<CalendarBirthday> forDay(
    List<CalendarBirthday> birthdays,
    DateTime day,
  ) {
    final matches = birthdays.where((b) => matchesDay(b, day)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return matches;
  }

  /// Day-of-month → count for birthdays that fall in [month]'s calendar month.
  static Map<int, int> countsForMonth(
    List<CalendarBirthday> birthdays,
    DateTime month,
  ) {
    final counts = <int, int>{};
    for (final birthday in birthdays) {
      final celebrated =
          BirthdayDate.occurrenceInYear(birthday.birthDate, month.year);
      if (celebrated.month != month.month) continue;
      counts[celebrated.day] = (counts[celebrated.day] ?? 0) + 1;
    }
    return counts;
  }

  /// Short display names for a day cell (e.g. "Ana S.").
  static List<String> shortNamesForDay(
    List<CalendarBirthday> birthdays,
    DateTime day, {
    int max = 2,
  }) {
    final matches = forDay(birthdays, day);
    return [
      for (final birthday in matches.take(max)) shortName(birthday.name),
    ];
  }

  static String shortName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return fullName;
    if (parts.length == 1) return parts.first;
    final lastInitial = parts.last.isNotEmpty
        ? '${parts.last[0].toUpperCase()}.'
        : '';
    return '${parts.first} $lastInitial'.trim();
  }

  static int ageTurningOn(DateTime birthDate, DateTime onDate) {
    return onDate.year - birthDate.year;
  }
}
