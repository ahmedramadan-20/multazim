import '../../../habits/domain/entities/habit_event.dart';
import '../../../habits/domain/repositories/habit_repository.dart';

class GetHabitEventsForAnalyticsUseCase {
  final HabitRepository _repository;

  GetHabitEventsForAnalyticsUseCase(this._repository);

  Future<List<HabitEvent>> call(String habitId) =>
      _repository.getEventsForHabit(habitId);
}
