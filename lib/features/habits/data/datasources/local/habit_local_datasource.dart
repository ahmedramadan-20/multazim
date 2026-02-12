import '../../models/habit_model.dart';
import '../../models/habit_event_model.dart';
import '../../models/streak_repair_model.dart';
import '../../models/milestone_model.dart';

abstract class HabitLocalDataSource {
  Future<List<HabitModel>> getHabits();
  Future<HabitModel?> getHabitById(String id);
  Future<void> saveHabit(HabitModel habit);
  Future<void> deleteHabit(String id);

  Future<void> saveEvent(HabitEventModel event);
  Future<List<HabitEventModel>> getEventsForHabit(String habitId);
  Future<List<HabitEventModel>> getEventsForDate(DateTime date);
  Future<HabitEventModel?> getTodayEvent(String habitId);

  // Phase 5
  Future<void> saveStreakRepair(StreakRepairModel repair);
  Future<List<StreakRepairModel>> getStreakRepairs(String habitId);
  Future<void> saveMilestone(MilestoneModel milestone);
  Future<List<MilestoneModel>> getMilestones(String habitId);
  Future<List<MilestoneModel>> getAllMilestones();
}
