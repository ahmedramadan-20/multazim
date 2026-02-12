import '../entities/milestone.dart';
import '../repositories/habit_repository.dart';

class SaveMilestoneUseCase {
  final HabitRepository repository;

  SaveMilestoneUseCase(this.repository);

  Future<void> call(Milestone milestone) async {
    return repository.saveMilestone(milestone);
  }
}
