import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/repositories/habit_repository.dart';

class GetHabitsForAnalyticsUseCase {
  final HabitRepository _repository;

  GetHabitsForAnalyticsUseCase(this._repository);

  Future<List<Habit>> call() => _repository.getHabits();
}
