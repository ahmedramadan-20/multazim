import '../entities/milestone.dart';
import '../repositories/habit_repository.dart';

class GetMilestonesUseCase {
  final HabitRepository repository;

  GetMilestonesUseCase(this.repository);

  Future<List<Milestone>> call(String habitId) async {
    return repository.getMilestones(habitId);
  }
}
