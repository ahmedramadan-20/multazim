import 'package:flutter_test/flutter_test.dart';
import 'package:multazim/features/habits/domain/entities/habit.dart';

void main() {
  group('Habit.isScheduledOn', () {
    final baseDate = DateTime(2023, 1, 1); // Sunday

    test('returns true for Daily habit within date range', () {
      final habit = Habit(
        id: '1',
        name: 'Test',
        icon: '',
        color: '',
        category: HabitCategory.other,
        schedule: const HabitSchedule.daily(),
        goal: const HabitGoal.binary(),
        difficulty: 1,
        strictness: StrictnessLevel.medium,
        startDate: baseDate,
        createdAt: baseDate,
      );

      // Same day
      expect(habit.isScheduledOn(baseDate), true);
      // Next day
      expect(habit.isScheduledOn(baseDate.add(const Duration(days: 1))), true);
    });

    test('returns false for date before startDate', () {
      final habit = Habit(
        id: '1',
        name: 'Test',
        icon: '',
        color: '',
        category: HabitCategory.other,
        schedule: const HabitSchedule.daily(),
        goal: const HabitGoal.binary(),
        difficulty: 1,
        strictness: StrictnessLevel.medium,
        startDate: baseDate,
        createdAt: baseDate,
      );

      expect(
        habit.isScheduledOn(baseDate.subtract(const Duration(days: 1))),
        false,
      );
    });

    test('returns false for date after endDate', () {
      final habit = Habit(
        id: '1',
        name: 'Test',
        icon: '',
        color: '',
        category: HabitCategory.other,
        schedule: const HabitSchedule.daily(),
        goal: const HabitGoal.binary(),
        difficulty: 1,
        strictness: StrictnessLevel.medium,
        startDate: baseDate,
        endDate: baseDate.add(const Duration(days: 5)),
        createdAt: baseDate,
      );

      expect(habit.isScheduledOn(baseDate.add(const Duration(days: 6))), false);
    });

    test('returns true for CustomDays matching weekday', () {
      // Custom days: Mon(1), Wed(3)
      final habit = Habit(
        id: '1',
        name: 'Test',
        icon: '',
        color: '',
        category: HabitCategory.other,
        schedule: const HabitSchedule.custom([1, 3]),
        goal: const HabitGoal.binary(),
        difficulty: 1,
        strictness: StrictnessLevel.medium,
        startDate: DateTime(2023, 1, 2), // Monday Jan 2nd
        createdAt: baseDate,
      );

      // Mon Jan 2nd -> True
      expect(habit.isScheduledOn(DateTime(2023, 1, 2)), true);
      // Tue Jan 3rd -> False
      expect(habit.isScheduledOn(DateTime(2023, 1, 3)), false);
      // Wed Jan 4th -> True
      expect(habit.isScheduledOn(DateTime(2023, 1, 4)), true);
    });
  });
}
