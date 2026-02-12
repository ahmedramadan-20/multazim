import 'package:uuid/uuid.dart';
import '../entities/habit_event.dart';
import '../repositories/habit_repository.dart';

class CompleteHabitUseCase {
  final HabitRepository repository;

  CompleteHabitUseCase(this.repository);

  Future<void> call(String habitId, DateTime date) async {
    final event = HabitEvent(
      id: const Uuid().v4(),
      habitId: habitId,
      date: date,
      status: HabitEventStatus.completed,
      createdAt: DateTime.now(),
    );
    return repository.saveEvent(event);
  }
}
