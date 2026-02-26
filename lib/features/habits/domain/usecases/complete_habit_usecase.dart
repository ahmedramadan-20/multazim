import 'package:uuid/uuid.dart';
import '../entities/habit_event.dart';
import '../repositories/habit_repository.dart';

class CompleteHabitUseCase {
  final HabitRepository repository;

  CompleteHabitUseCase(this.repository);

  Future<void> call(
    String habitId,
    DateTime date, {
    int? countValue,
    String? note,
  }) async {
    // ── Check for existing event for this day to avoid duplicates ──
    final existingEvent = await repository.getEventByDate(habitId, date);

    final event = HabitEvent(
      id: existingEvent?.id ?? const Uuid().v4(),
      habitId: habitId,
      date: date,
      status: HabitEventStatus.completed,
      countValue: countValue,
      note: note,
      createdAt: existingEvent?.createdAt ?? DateTime.now(),
    );
    return repository.saveEvent(event);
  }
}
