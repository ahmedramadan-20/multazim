import '../entities/streak_repair.dart';
import '../repositories/habit_repository.dart';

class SaveStreakRepairUseCase {
  final HabitRepository repository;

  SaveStreakRepairUseCase(this.repository);

  Future<void> call(StreakRepair repair) async {
    return repository.saveStreakRepair(repair);
  }
}
