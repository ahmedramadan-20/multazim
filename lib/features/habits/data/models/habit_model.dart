import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import '../../domain/entities/habit.dart';

@Entity()
class HabitModel {
  @Id()
  int dbId = 0; // ObjectBox requires int ID

  @Unique()
  late String id; // our UUID

  late String name;
  late String icon;
  late String color;
  late String categoryName; // stored as string
  late String scheduleJson; // stored as JSON string
  late String goalJson; // stored as JSON string
  late int
  difficulty; // Stored, but currently unused in entity, keeping for future
  late String strictnessName; // stored as string
  late DateTime startDate;
  DateTime? endDate;
  late bool isActive;
  late DateTime createdAt;

  // ObjectBox requires default constructor
  HabitModel();

  // Convert from domain entity
  factory HabitModel.fromEntity(Habit habit) {
    // Serialize Schedule
    final scheduleMap = {
      'type': habit.schedule.type.name,
      if (habit.schedule.timesPerWeek != null)
        'timesPerWeek': habit.schedule.timesPerWeek,
      if (habit.schedule.customDays != null)
        'customDays': habit.schedule.customDays,
    };

    // Serialize Goal
    final goalMap = {
      'type': habit.goal.type.name,
      if (habit.goal.targetCount != null) 'targetCount': habit.goal.targetCount,
      if (habit.goal.unit != null) 'unit': habit.goal.unit,
    };

    return HabitModel()
      ..id = habit.id
      ..name = habit.name
      ..icon = habit.icon
      ..color = habit.color
      ..categoryName = habit.category.name
      ..scheduleJson = jsonEncode(scheduleMap)
      ..goalJson = jsonEncode(goalMap)
      ..strictnessName = habit.strictness.name
      ..difficulty = habit.difficulty
      ..startDate = habit.startDate
      ..endDate = habit.endDate
      ..isActive = habit.isActive
      ..createdAt = habit.createdAt;
  }

  // Convert to domain entity
  Habit toEntity() {
    // Deserialize Schedule
    final scheduleMap = jsonDecode(scheduleJson) as Map<String, dynamic>;
    final scheduleType = HabitScheduleType.values.firstWhere(
      (e) => e.name == scheduleMap['type'],
    );

    HabitSchedule schedule;
    if (scheduleType == HabitScheduleType.daily) {
      schedule = const HabitSchedule.daily();
    } else if (scheduleType == HabitScheduleType.timesPerWeek) {
      schedule = HabitSchedule.timesPerWeek(scheduleMap['timesPerWeek'] as int);
    } else {
      schedule = HabitSchedule.custom(
        List<int>.from(scheduleMap['customDays']),
      );
    }

    // Deserialize Goal
    final goalMap = jsonDecode(goalJson) as Map<String, dynamic>;
    final goalType = HabitGoalType.values.firstWhere(
      (e) => e.name == goalMap['type'],
    );

    HabitGoal goal;
    if (goalType == HabitGoalType.binary) {
      goal = const HabitGoal.binary();
    } else {
      goal = HabitGoal.countBased(
        goalMap['targetCount'] as int,
        goalMap['unit'] as String,
      );
    }

    return Habit(
      id: id,
      name: name,
      icon: icon,
      color: color,
      category: HabitCategory.values.firstWhere((e) => e.name == categoryName),
      schedule: schedule,
      goal: goal,
      difficulty: difficulty,
      strictness: StrictnessLevel.values.firstWhere(
        (e) => e.name == strictnessName,
      ),
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}
