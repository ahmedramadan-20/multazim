import '../entities/habit.dart';
import '../entities/habit_event.dart';

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
}
