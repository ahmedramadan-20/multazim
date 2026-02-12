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

enum HabitGoalType { binary, countBased }

class HabitGoal extends Equatable {
  final HabitGoalType type;
  final int? targetCount; // e.g., 30 (minutes), 10 (pages)
  final String? unit; // e.g., "mins", "pages"

  const HabitGoal.binary()
    : type = HabitGoalType.binary,
      targetCount = null,
      unit = null;

  const HabitGoal.countBased(int count, String unit)
    : type = HabitGoalType.countBased,
      targetCount = count,
      unit = unit;

  @override
  List<Object?> get props => [type, targetCount, unit];
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
