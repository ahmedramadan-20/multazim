import 'package:uuid/uuid.dart';
import '../entities/habit_event.dart';
import '../repositories/habit_repository.dart';

class SkipHabitUseCase {
  final HabitRepository repository;

  SkipHabitUseCase(this.repository);

  Future<void> call(String habitId, DateTime date) async {
    final event = HabitEvent(
      id: const Uuid().v4(),
      habitId: habitId,
      date: date,
      status: HabitEventStatus.skipped,
      createdAt: DateTime.now(),
    );
    return repository.saveEvent(event);
  }
}
