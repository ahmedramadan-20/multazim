import '../entities/streak_repair.dart';
import '../repositories/habit_repository.dart';

class WatchAllStreakRepairsUseCase {
  final HabitRepository repository;

  WatchAllStreakRepairsUseCase(this.repository);

  Stream<List<StreakRepair>> call() {
    return repository.watchAllStreakRepairs();
  }
}
