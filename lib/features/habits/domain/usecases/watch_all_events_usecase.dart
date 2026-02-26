import '../entities/habit_event.dart';
import '../repositories/habit_repository.dart';

class WatchAllEventsUseCase {
  final HabitRepository repository;

  WatchAllEventsUseCase(this.repository);

  Stream<List<HabitEvent>> call() {
    return repository.watchAllEvents();
  }
}
