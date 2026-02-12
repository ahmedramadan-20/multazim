import '../entities/streak_repair.dart';
import '../repositories/habit_repository.dart';

class GetStreakRepairsUseCase {
  final HabitRepository repository;

  GetStreakRepairsUseCase(this.repository);

  Future<List<StreakRepair>> call(String habitId) async {
    return repository.getStreakRepairs(habitId);
  }
}
