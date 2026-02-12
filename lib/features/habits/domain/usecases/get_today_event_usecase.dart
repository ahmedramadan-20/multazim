import '../entities/habit_event.dart';
import '../repositories/habit_repository.dart';

class GetTodayEventUseCase {
  final HabitRepository repository;

  GetTodayEventUseCase(this.repository);

  Future<HabitEvent?> call(String habitId) async {
    return repository.getTodayEvent(habitId);
  }
}
