import 'package:equatable/equatable.dart';

enum HabitCategory { health, work, mind, social, fitness, learning, other }

enum StrictnessLevel { low, medium, high }

enum HabitScheduleType { daily, timesPerWeek, customDays }

class HabitSchedule extends Equatable {
  final HabitScheduleType type;
  final int? timesPerWeek; // e.g., 3
  final List<int>? customDays; // 1=Mon … 7=Sun

  const HabitSchedule.daily()
    : type = HabitScheduleType.daily,
      timesPerWeek = null,
      customDays = null;

  const HabitSchedule.timesPerWeek(int times)
    : type = HabitScheduleType.timesPerWeek,
      timesPerWeek = times,
      customDays = null;

  const HabitSchedule.custom(List<int> days)
    : type = HabitScheduleType.customDays,
      timesPerWeek = null,
      customDays = days;

  @override
  List<Object?> get props => [type, timesPerWeek, customDays];
}

enum HabitGoalType { binary, numeric }

class HabitGoal extends Equatable {
  final HabitGoalType type;
  final double? targetValue; // e.g., 500 (ml), 10 (pages)
  final String? unit; // e.g., "ml", "pages"

  const HabitGoal({required this.type, this.targetValue, this.unit});

  const HabitGoal.binary()
    : type = HabitGoalType.binary,
      targetValue = null,
      unit = null;

  const HabitGoal.numeric(double value, String unit)
    : type = HabitGoalType.numeric,
      targetValue = value,
      unit = unit;

  @override
  List<Object?> get props => [type, targetValue, unit];
}

class Habit extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String color;
  final HabitCategory category;
  final HabitSchedule schedule;
  final HabitGoal goal;
  final int difficulty; // 1-5
  final StrictnessLevel strictness;
  final DateTime startDate;
  final DateTime? endDate; // nullable = no end
  final bool isActive;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.category,
    required this.schedule,
    required this.goal,
    required this.difficulty,
    required this.strictness,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  /// Checks if the habit is scheduled for a specific date
  bool isScheduledOn(DateTime date) {
    // 1. Check date range
    // Normalize dates to remove time components for accurate comparison
    final checkDate = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);

    if (checkDate.isBefore(start)) return false;

    if (endDate != null) {
      final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (checkDate.isAfter(end)) return false;
    }

    // 2. Check schedule type
    switch (schedule.type) {
      case HabitScheduleType.daily:
        return true;
      case HabitScheduleType.customDays:
        // weekday is 1(Mon)..7(Sun)
        return schedule.customDays?.contains(checkDate.weekday) ?? false;
      case HabitScheduleType.timesPerWeek:
        // For 'times per week', it's technically "available" any day.
        // We count it as scheduled.
        return true;
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    color,
    category,
    schedule,
    goal,
    difficulty,
    strictness,
    startDate,
    endDate,
    isActive,
    createdAt,
  ];
}
