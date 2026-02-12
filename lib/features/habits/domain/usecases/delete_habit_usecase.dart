import '../repositories/habit_repository.dart';

class DeleteHabitUseCase {
  final HabitRepository repository;

  DeleteHabitUseCase(this.repository);

  Future<void> call(String habitId) async {
    return repository.deleteHabit(habitId);
  }
}
