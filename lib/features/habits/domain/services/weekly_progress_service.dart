import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';

/// Service to calculate fractional progress for habits in the current ISO week.
class WeeklyProgressService {
  /// Returns the current and target progress for a habit in its current ISO week.
  ///
  /// For daily habits, target is 7. For weekly habits, target is the goal target.
  ({int current, int target}) getProgress(
    Habit habit,
    List<HabitEvent> events,
    DateTime now,
  ) {
    final startOfWeek = _getStartOfISOWeek(now);
    final endOfWeek = _getEndOfISOWeek(now);

    final weeklyEvents = events.where((e) {
      return e.habitId == habit.id &&
          e.status == HabitEventStatus.completed &&
          !e.date.isBefore(startOfWeek) &&
          !e.date.isAfter(endOfWeek);
    }).toList();

    // Unique days count (in case user logs multiple times per day which shouldn't happen but safe)
    final uniqueDays = weeklyEvents
        .map((e) => _normalizeDate(e.date))
        .toSet()
        .length;

    int target;
    switch (habit.schedule.type) {
      case HabitScheduleType.daily:
        target = 7;
        break;
      case HabitScheduleType.timesPerWeek:
        target = habit.schedule.timesPerWeek ?? 1;
        break;
      case HabitScheduleType.customDays:
        target = habit.schedule.customDays?.length ?? 1;
        break;
    }

    return (current: uniqueDays, target: target);
  }

  DateTime _getStartOfISOWeek(DateTime date) {
    return _normalizeDate(date.subtract(Duration(days: date.weekday - 1)));
  }

  DateTime _getEndOfISOWeek(DateTime date) {
    final start = _getStartOfISOWeek(date);
    return start.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
