import '../entities/milestone.dart';
import '../repositories/habit_repository.dart';

class GetAllMilestonesUseCase {
  final HabitRepository repository;
  const GetAllMilestonesUseCase(this.repository);

  Future<List<Milestone>> call() => repository.getAllMilestones();
}
