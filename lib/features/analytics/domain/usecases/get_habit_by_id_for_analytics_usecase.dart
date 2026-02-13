import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/repositories/habit_repository.dart';

class GetHabitByIdForAnalyticsUseCase {
  final HabitRepository _repository;

  GetHabitByIdForAnalyticsUseCase(this._repository);

  Future<Habit?> call(String habitId) => _repository.getHabitById(habitId);
}
