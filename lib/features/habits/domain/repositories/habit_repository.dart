import '../entities/habit.dart';
import '../entities/habit_event.dart';
import '../entities/streak_repair.dart';
import '../entities/milestone.dart';

abstract class HabitRepository {
  Future<List<Habit>> getHabits();
  Future<Habit?> getHabitById(String id);
  Future<void> createHabit(Habit habit);
  Future<void> deleteHabit(String id);
  Future<void> updateHabit(Habit habit);

  Future<void> saveEvent(HabitEvent event);
  Future<List<HabitEvent>> getEventsForHabit(String habitId);
  Future<List<HabitEvent>> getEventsForDate(DateTime date);
  Future<HabitEvent?> getTodayEvent(String habitId);

  // Phase 5: Motivation Persistence
  Future<void> saveStreakRepair(StreakRepair repair);
  Future<List<StreakRepair>> getStreakRepairs(String habitId);
  Future<void> saveMilestone(Milestone milestone);
  Future<List<Milestone>> getMilestones(String habitId);
  Future<List<Milestone>> getAllMilestones();
}
