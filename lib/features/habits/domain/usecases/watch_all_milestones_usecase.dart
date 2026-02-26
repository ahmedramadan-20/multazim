import '../entities/milestone.dart';
import '../repositories/habit_repository.dart';

class WatchAllMilestonesUseCase {
  final HabitRepository repository;

  WatchAllMilestonesUseCase(this.repository);

  Stream<List<Milestone>> call() {
    return repository.watchAllMilestones();
  }
}
