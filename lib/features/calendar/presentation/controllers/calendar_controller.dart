import 'package:cheery/features/calendar/domain/calendar_birthday.dart';
import 'package:cheery/features/calendar/domain/calendar_birthday_matcher.dart';
import 'package:cheery/features/calendar/domain/calendar_failure.dart';
import 'package:cheery/features/calendar/domain/calendar_repository.dart';
import 'package:cheery/features/calendar/presentation/controllers/calendar_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final calendarControllerProvider =
    AsyncNotifierProvider<CalendarController, CalendarViewState>(
  CalendarController.new,
);

/// Immutable UI state for the calendar feature.
class CalendarViewState {
  const CalendarViewState({
    required this.visibleMonth,
    required this.selectedDate,
    required this.birthdays,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final List<CalendarBirthday> birthdays;

  List<CalendarBirthday> get birthdaysForSelectedDay =>
      CalendarBirthdayMatcher.forDay(birthdays, selectedDate);

  Map<int, int> get birthdayCountsForVisibleMonth =>
      CalendarBirthdayMatcher.countsForMonth(birthdays, visibleMonth);

  List<CalendarBirthday> birthdaysOn(DateTime day) =>
      CalendarBirthdayMatcher.forDay(birthdays, day);

  CalendarViewState copyWith({
    DateTime? visibleMonth,
    DateTime? selectedDate,
    List<CalendarBirthday>? birthdays,
  }) {
    return CalendarViewState(
      visibleMonth: visibleMonth ?? this.visibleMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      birthdays: birthdays ?? this.birthdays,
    );
  }
}

class CalendarController extends AsyncNotifier<CalendarViewState> {
  CalendarRepository get _repository {
    final repository = ref.read(calendarRepositoryProvider);
    if (repository == null) {
      throw const CalendarNotReadyFailure();
    }
    return repository;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _monthOnly(DateTime d) => DateTime(d.year, d.month);

  @override
  Future<CalendarViewState> build() async {
    final now = DateTime.now();
    final today = _dateOnly(now);
    final repository = ref.watch(calendarRepositoryProvider);
    if (repository == null) {
      return CalendarViewState(
        visibleMonth: _monthOnly(today),
        selectedDate: today,
        birthdays: const [],
      );
    }

    final birthdays = await repository.listBirthdays();
    return CalendarViewState(
      visibleMonth: _monthOnly(today),
      selectedDate: today,
      birthdays: birthdays,
    );
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    final today = _dateOnly(DateTime.now());
    try {
      final birthdays = await _repository.listBirthdays();
      state = AsyncData(
        CalendarViewState(
          visibleMonth: current?.visibleMonth ?? _monthOnly(today),
          selectedDate: current?.selectedDate ?? today,
          birthdays: birthdays,
        ),
      );
    } catch (error, stackTrace) {
      if (!state.hasValue) {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    }
  }

  void selectDate(DateTime date) {
    final current = state.valueOrNull;
    if (current == null) return;
    final selected = _dateOnly(date);
    state = AsyncData(
      current.copyWith(
        selectedDate: selected,
        visibleMonth: _monthOnly(selected),
      ),
    );
  }

  void goToToday() {
    final current = state.valueOrNull;
    if (current == null) return;
    final today = _dateOnly(DateTime.now());
    state = AsyncData(
      current.copyWith(
        selectedDate: today,
        visibleMonth: _monthOnly(today),
      ),
    );
  }

  void previousMonth() {
    final current = state.valueOrNull;
    if (current == null) return;
    final previous = DateTime(
      current.visibleMonth.year,
      current.visibleMonth.month - 1,
    );
    state = AsyncData(
      current.copyWith(
        visibleMonth: previous,
        selectedDate: _clampSelectedToMonth(current.selectedDate, previous),
      ),
    );
  }

  void nextMonth() {
    final current = state.valueOrNull;
    if (current == null) return;
    final next = DateTime(
      current.visibleMonth.year,
      current.visibleMonth.month + 1,
    );
    state = AsyncData(
      current.copyWith(
        visibleMonth: next,
        selectedDate: _clampSelectedToMonth(current.selectedDate, next),
      ),
    );
  }

  /// Keep day-of-month when changing months; clamp to last day if needed.
  DateTime _clampSelectedToMonth(DateTime selected, DateTime month) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final day = selected.day.clamp(1, lastDay);
    return DateTime(month.year, month.month, day);
  }
}
