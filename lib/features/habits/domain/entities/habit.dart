import 'package:equatable/equatable.dart';

enum HabitCategory {
  worship,
  health,
  fitness,
  mind,
  learning,
  work,
  finance,
  social,
  selfCare,
  nutrition,
  creativity,
  other,
}

enum StrictnessLevel { low, medium, high }

enum HabitScheduleType { daily, timesPerWeek, customDays }

class HabitSchedule extends Equatable {
  final HabitScheduleType type;
  final int? timesPerWeek;
  final List<int>? customDays;

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

/// Lightweight time-of-day value object.
/// Stored as total minutes since midnight (0–1439).
/// e.g. 5:30 AM = 330, 9:00 PM = 1260
class HabitReminderTime extends Equatable {
  final int hour; // 0–23
  final int minute; // 0–59

  const HabitReminderTime({required this.hour, required this.minute});

  /// Construct from total minutes since midnight
  factory HabitReminderTime.fromMinutes(int totalMinutes) {
    return HabitReminderTime(
      hour: totalMinutes ~/ 60,
      minute: totalMinutes % 60,
    );
  }

  /// Total minutes since midnight — used for storage
  int get totalMinutes => hour * 60 + minute;

  /// Display string e.g. "05:30" or "21:00"
  String get display =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [hour, minute];
}

class Habit extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String color;
  final HabitCategory category;
  final HabitSchedule schedule;
  final HabitGoal goal;
  final int difficulty;
  final StrictnessLevel strictness;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final int version;

  /// Optional daily reminder time.
  /// null = no reminder set for this habit.
  final HabitReminderTime? reminderTime;

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
    this.reminderTime,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    HabitCategory? category,
    HabitSchedule? schedule,
    HabitGoal? goal,
    int? difficulty,
    StrictnessLevel? strictness,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    int? version,
    HabitReminderTime? reminderTime,
    bool clearReminderTime = false,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      schedule: schedule ?? this.schedule,
      goal: goal ?? this.goal,
      difficulty: difficulty ?? this.difficulty,
      strictness: strictness ?? this.strictness,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      version: version ?? this.version,
      reminderTime: clearReminderTime
          ? null
          : (reminderTime ?? this.reminderTime),
    );
  }

  Habit incrementVersion() => copyWith(version: version + 1);

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
    reminderTime,
  ];
}
