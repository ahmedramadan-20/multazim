import 'package:equatable/equatable.dart';

enum HabitCategory { health, work, mind, social, fitness, learning, other }

enum StrictnessLevel { low, medium, high }

enum HabitScheduleType { daily, timesPerWeek, customDays }

class HabitSchedule extends Equatable {
  final HabitScheduleType type;
  final int? timesPerWeek; // e.g. 3
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
  final double? targetValue;
  final String? unit;

  const HabitGoal._({required this.type, this.targetValue, this.unit});

  const HabitGoal.binary() : this._(type: HabitGoalType.binary);

  const HabitGoal.numeric(double value, String unit)
    : this._(type: HabitGoalType.numeric, targetValue: value, unit: unit);

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
  final int difficulty; // 1–5
  final StrictnessLevel strictness;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;

  /// Used for sync & conflict resolution
  final int version;

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
    this.version = 1,
  });

  /// Determines whether the habit is *available* on a given date
  bool isScheduledOn(DateTime date) {
    final checkDate = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);

    if (checkDate.isBefore(start)) return false;

    if (endDate != null) {
      final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (checkDate.isAfter(end)) return false;
    }

    switch (schedule.type) {
      case HabitScheduleType.daily:
        return true;
      case HabitScheduleType.customDays:
        return schedule.customDays?.contains(checkDate.weekday) ?? false;
      case HabitScheduleType.timesPerWeek:
        // Availability is daily; completion is validated elsewhere
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
    version,
  ];
}
