import '../../models/habit_model.dart';
import '../../models/habit_event_model.dart';
import '../../models/milestone_model.dart';
import '../../models/streak_repair_model.dart';

abstract class HabitRemoteDataSource {
  // Auth
  Future<String> getCurrentUserId();
  Future<bool> isAuthenticated();

  // Habits
  Future<void> syncHabit(HabitModel habit);
  Future<void> syncHabitsBatch(List<HabitModel> habits);
  Future<List<HabitModel>> fetchHabits();
  Future<void> deleteHabitRemote(String habitId);

  // Events
  Future<void> syncEvent(HabitEventModel event);
  Future<void> syncEventsBatch(List<HabitEventModel> events);
  Future<List<HabitEventModel>> fetchEvents(String habitId);
  Future<List<HabitEventModel>> fetchAllEvents();

  // Milestones
  Future<void> syncMilestone(MilestoneModel milestone);
  Future<void> syncMilestonesBatch(List<MilestoneModel> milestones);
  Future<List<MilestoneModel>> fetchMilestones(String habitId);
  Future<List<MilestoneModel>> fetchAllMilestones();

  // Streak Repairs
  Future<void> syncStreakRepair(StreakRepairModel repair);
  Future<void> syncStreakRepairsBatch(List<StreakRepairModel> repairs);
  Future<List<StreakRepairModel>> fetchStreakRepairs(String habitId);
  Future<List<StreakRepairModel>> fetchAllStreakRepairs();
}
