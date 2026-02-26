import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class WatchHabitsUseCase {
  final HabitRepository repository;

  WatchHabitsUseCase(this.repository);

  Stream<List<Habit>> call() {
    return repository.watchHabits();
  }
}
