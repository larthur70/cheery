/// Helpers for birthday calendar dates (month/day, leap-year safe).
abstract final class BirthdayDate {
  static bool isLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  /// Day this birthday is celebrated in [year].
  ///
  /// Feb 29 → Feb 28 in non-leap years (avoids Dart overflowing to Mar 1).
  static DateTime occurrenceInYear(DateTime birthDate, int year) {
    if (birthDate.month == 2 && birthDate.day == 29 && !isLeapYear(year)) {
      return DateTime(year, 2, 28);
    }
    return DateTime(year, birthDate.month, birthDate.day);
  }

  static bool matchesCalendarDay(DateTime birthDate, DateTime day) {
    final celebrated = occurrenceInYear(birthDate, day.year);
    return celebrated.year == day.year &&
        celebrated.month == day.month &&
        celebrated.day == day.day;
  }
}
