import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class CreateHabitUseCase {
  final HabitRepository repository;

  CreateHabitUseCase(this.repository);

  Future<void> call(Habit habit) async {
    return repository.createHabit(habit);
  }
}
