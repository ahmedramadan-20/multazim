import '../entities/habit_event.dart';
import '../repositories/habit_repository.dart';

class GetEventsForHabitUseCase {
  final HabitRepository repository;

  GetEventsForHabitUseCase(this.repository);

  Future<List<HabitEvent>> call(String habitId) async {
    return repository.getEventsForHabit(habitId);
  }
}
