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
  Future<HabitEventModel?> getEventByDate(String habitId, DateTime date);

  // Phase 5
  Future<void> saveStreakRepair(StreakRepairModel repair);
  Future<List<StreakRepairModel>> getStreakRepairs(String habitId);
  Future<void> saveMilestone(MilestoneModel milestone);
  Future<List<MilestoneModel>> getMilestones(String habitId);
  Future<List<MilestoneModel>> getAllMilestones();
  Future<List<HabitEventModel>> getAllEvents();
  Future<List<StreakRepairModel>> getAllStreakRepairs();

  Future<HabitEventModel?> getEventById(String id);
  Future<MilestoneModel?> getMilestoneById(String id);
  Future<StreakRepairModel?> getStreakRepairById(String id);
  Future<void> clearAllLocalData();

  // ── App metadata (guest mode flag, preferences, etc.) ──
  // Used to persist lightweight key-value data across restarts
  // without a separate package — stored alongside ObjectBox data
  Future<String?> getMetadata(String key);
  Future<void> saveMetadata(String key, String value);
  Future<void> deleteMetadata(String key);
}
