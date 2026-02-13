import '../../../habits/domain/entities/milestone.dart';
import '../../../habits/domain/repositories/habit_repository.dart';

class GetHabitMilestonesForAnalyticsUseCase {
  final HabitRepository _repository;

  GetHabitMilestonesForAnalyticsUseCase(this._repository);

  Future<List<Milestone>> call(String habitId) =>
      _repository.getMilestones(habitId);
}
