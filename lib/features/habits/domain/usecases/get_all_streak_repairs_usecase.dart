import '../entities/streak_repair.dart';
import '../repositories/habit_repository.dart';

/// Fetches all streak repairs for all habits in a single
/// query.
///
/// Used to batch-load data instead of per-habit queries.
class GetAllStreakRepairsUseCase {
  final HabitRepository repository;

  GetAllStreakRepairsUseCase(this.repository);

  Future<List<StreakRepair>> call() async {
    return repository.getAllStreakRepairs();
  }
}
