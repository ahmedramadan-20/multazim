import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../data/datasources/local/habit_local_datasource.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/habit_event_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';

/// Implements [HabitRepository] using a local-only data source.
///
/// Catches [LocalException] from the data source and wraps it into
/// [LocalFailure] so the domain/presentation layers never see raw
/// exceptions.
class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;

  HabitRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Habit>> getHabits() async {
    try {
      final models = await localDataSource.getHabits();
      return models.map((m) => m.toEntity()).toList();
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    try {
      final model = await localDataSource.getHabitById(id);
      return model?.toEntity();
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<void> createHabit(Habit habit) async {
    try {
      final model = HabitModel.fromEntity(habit);
      await localDataSource.saveHabit(model);
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    try {
      final model = HabitModel.fromEntity(habit);
      await localDataSource.saveHabit(model);
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      await localDataSource.deleteHabit(id);
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<void> saveEvent(HabitEvent event) async {
    try {
      final model = HabitEventModel.fromEntity(event);
      await localDataSource.saveEvent(model);
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<List<HabitEvent>> getEventsForHabit(String habitId) async {
    try {
      final models = await localDataSource.getEventsForHabit(habitId);
      return models.map((m) => m.toEntity()).toList();
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<List<HabitEvent>> getEventsForDate(DateTime date) async {
    try {
      final models = await localDataSource.getEventsForDate(date);
      return models.map((m) => m.toEntity()).toList();
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<HabitEvent?> getTodayEvent(String habitId) async {
    try {
      final model = await localDataSource.getTodayEvent(habitId);
      return model?.toEntity();
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }
}
