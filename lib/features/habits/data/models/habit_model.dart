import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import '../../domain/entities/habit.dart';

@Entity()
class HabitModel {
  @Id()
  int dbId = 0; // ObjectBox internal ID

  @Unique()
  late String id; // UUID (shared with Supabase)

  late String name;
  late String icon;
  late String color;

  // Stored as string enums
  late String categoryName;
  late String scheduleType;
  late String goalType;
  late String strictnessName;

  // Serialized JSON blobs
  late String scheduleJson;
  late String goalJson;

  late int difficulty;
  late DateTime startDate;
  DateTime? endDate;
  late bool isActive;
  late DateTime createdAt;

  // Used for conflict resolution with Supabase
  late int version;

  HabitModel();

  // ─────────────────────────────────────────────
  // Domain → Data
  // ─────────────────────────────────────────────
  factory HabitModel.fromEntity(Habit habit) {
    final scheduleMap = {
      'type': habit.schedule.type.name,
      if (habit.schedule.timesPerWeek != null)
        'timesPerWeek': habit.schedule.timesPerWeek,
      if (habit.schedule.customDays != null)
        'customDays': habit.schedule.customDays,
    };

    final goalMap = {
      'type': habit.goal.type.name,
      if (habit.goal.targetValue != null) 'targetValue': habit.goal.targetValue,
      if (habit.goal.unit != null) 'unit': habit.goal.unit,
    };

    return HabitModel()
      ..id = habit.id
      ..name = habit.name
      ..icon = habit.icon
      ..color = habit.color
      ..categoryName = habit.category.name
      ..scheduleType = habit.schedule.type.name
      ..goalType = habit.goal.type.name
      ..scheduleJson = jsonEncode(scheduleMap)
      ..goalJson = jsonEncode(goalMap)
      ..strictnessName = habit.strictness.name
      ..difficulty = habit.difficulty
      ..startDate = habit.startDate
      ..endDate = habit.endDate
      ..isActive = habit.isActive
      ..createdAt = habit.createdAt
      ..version = habit.version;
  }

  // ─────────────────────────────────────────────
  // Data → Domain
  // ─────────────────────────────────────────────
  Habit toEntity() {
    final scheduleMap = jsonDecode(scheduleJson) as Map<String, dynamic>;
    final scheduleTypeEnum = HabitScheduleType.values.firstWhere(
      (e) => e.name == scheduleMap['type'],
      orElse: () => HabitScheduleType.daily,
    );

    final HabitSchedule schedule;
    switch (scheduleTypeEnum) {
      case HabitScheduleType.timesPerWeek:
        schedule = HabitSchedule.timesPerWeek(
          scheduleMap['timesPerWeek'] as int,
        );
        break;
      case HabitScheduleType.customDays:
        schedule = HabitSchedule.custom(
          List<int>.from(scheduleMap['customDays']),
        );
        break;
      default:
        schedule = const HabitSchedule.daily();
    }

    final goalMap = jsonDecode(goalJson) as Map<String, dynamic>;
    final goalTypeName = goalMap['type'] as String?;

    HabitGoal goal;
    final knownGoal = HabitGoalType.values
        .where((e) => e.name == goalTypeName)
        .toList();

    if (knownGoal.isNotEmpty) {
      final type = knownGoal.first;
      goal = type == HabitGoalType.numeric
          ? HabitGoal.numeric(
              (goalMap['targetValue'] as num).toDouble(),
              goalMap['unit'] as String,
            )
          : const HabitGoal.binary();
    } else {
      // Legacy or corrupted data fallback
      goal = const HabitGoal.binary();
    }

    return Habit(
      id: id,
      name: name,
      icon: icon,
      color: color,
      category: HabitCategory.values.firstWhere(
        (e) => e.name == categoryName,
        orElse: () => HabitCategory.other,
      ),
      schedule: schedule,
      goal: goal,
      difficulty: difficulty,
      strictness: StrictnessLevel.values.firstWhere(
        (e) => e.name == strictnessName,
        orElse: () => StrictnessLevel.medium,
      ),
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      createdAt: createdAt,
      version: version,
    );
  }
}
