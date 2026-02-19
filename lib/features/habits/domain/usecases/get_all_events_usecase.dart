import '../entities/habit_event.dart';
import '../repositories/habit_repository.dart';

/// Fetches all events for all habits in a single query.
///
/// Used to batch-load data instead of per-habit queries.
class GetAllEventsUseCase {
  final HabitRepository repository;

  GetAllEventsUseCase(this.repository);

  Future<List<HabitEvent>> call() async {
    return repository.getAllEvents();
  }
}
