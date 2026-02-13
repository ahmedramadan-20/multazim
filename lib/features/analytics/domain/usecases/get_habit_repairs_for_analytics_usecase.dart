import '../../../habits/domain/entities/streak_repair.dart';
import '../../../habits/domain/repositories/habit_repository.dart';

class GetHabitRepairsForAnalyticsUseCase {
  final HabitRepository _repository;

  GetHabitRepairsForAnalyticsUseCase(this._repository);

  Future<List<StreakRepair>> call(String habitId) =>
      _repository.getStreakRepairs(habitId);
}
