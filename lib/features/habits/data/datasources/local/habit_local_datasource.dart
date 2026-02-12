import '../../models/habit_model.dart';
import '../../models/habit_event_model.dart';

abstract class HabitLocalDataSource {
  Future<List<HabitModel>> getHabits();
  Future<HabitModel?> getHabitById(String id);
  Future<void> saveHabit(HabitModel habit);
  Future<void> deleteHabit(String id);

  Future<void> saveEvent(HabitEventModel event);
  Future<List<HabitEventModel>> getEventsForHabit(String habitId);
  Future<List<HabitEventModel>> getEventsForDate(DateTime date);
  Future<HabitEventModel?> getTodayEvent(String habitId);
}
