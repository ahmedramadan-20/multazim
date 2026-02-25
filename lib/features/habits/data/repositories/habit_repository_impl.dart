import 'package:multazim/features/habits/data/datasources/remote/habit_remote_datasource.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../../domain/entities/streak_repair.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../data/datasources/local/habit_local_datasource.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/habit_event_model.dart';
import '../../data/models/streak_repair_model.dart';
import '../../data/models/milestone_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import 'dart:developer' as developer;

/// Implements [HabitRepository] using a local-only data source.
class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;
  final HabitRemoteDataSource remoteDataSource;

  HabitRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

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

      // Phase 2: Remote Sync
      await _syncHabitRemote(model);
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    try {
      final model = HabitModel.fromEntity(habit);
      await localDataSource.saveHabit(model);

      // Phase 2: Remote Sync
      await _syncHabitRemote(model);
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      await localDataSource.deleteHabit(id);

      // Phase 2: Remote Sync
      await _deleteHabitRemote(id);
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<void> saveEvent(HabitEvent event) async {
    try {
      final model = HabitEventModel.fromEntity(event);
      await localDataSource.saveEvent(model);

      // Phase 2: Remote Sync
      await _syncEventRemote(model);
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

  @override
  Future<void> saveStreakRepair(StreakRepair repair) async {
    try {
      final model = StreakRepairModel.fromEntity(repair);
      await localDataSource.saveStreakRepair(model);

      // Phase 2: Remote Sync
      await _syncStreakRepairRemote(model);
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<List<StreakRepair>> getStreakRepairs(String habitId) async {
    try {
      final models = await localDataSource.getStreakRepairs(habitId);
      return models.map((m) => m.toEntity()).toList();
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<void> saveMilestone(Milestone milestone) async {
    try {
      final model = MilestoneModel.fromEntity(milestone);
      await localDataSource.saveMilestone(model);

      // Phase 2: Remote Sync
      await _syncMilestoneRemote(model);
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<List<Milestone>> getMilestones(String habitId) async {
    try {
      final models = await localDataSource.getMilestones(habitId);
      return models.map((m) => m.toEntity()).toList();
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<List<Milestone>> getAllMilestones() async {
    try {
      final models = await localDataSource.getAllMilestones();
      return models.map((m) => m.toEntity()).toList();
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<List<HabitEvent>> getAllEvents() async {
    try {
      final models = await localDataSource.getAllEvents();
      return models.map((m) => m.toEntity()).toList();
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<List<StreakRepair>> getAllStreakRepairs() async {
    try {
      final models = await localDataSource.getAllStreakRepairs();
      return models.map((m) => m.toEntity()).toList();
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  // ─────────────────────────────────────────────────
  // PRIVATE SYNC HELPERS (Phase 2)
  // ─────────────────────────────────────────────────

  Future<void> _syncHabitRemote(HabitModel model) async {
    if (!await remoteDataSource.isAuthenticated()) return;
    try {
      await remoteDataSource.syncHabit(model);
    } catch (e) {
      _logSyncError('Habit', model.id, e);
    }
  }

  Future<void> _deleteHabitRemote(String id) async {
    if (!await remoteDataSource.isAuthenticated()) return;
    try {
      await remoteDataSource.deleteHabitRemote(id);
    } catch (e) {
      _logSyncError('Delete Habit', id, e);
    }
  }

  Future<void> _syncEventRemote(HabitEventModel model) async {
    if (!await remoteDataSource.isAuthenticated()) return;
    try {
      await remoteDataSource.syncEvent(model);
    } catch (e) {
      _logSyncError('Event', model.id, e);
    }
  }

  Future<void> _syncMilestoneRemote(MilestoneModel model) async {
    if (!await remoteDataSource.isAuthenticated()) return;
    try {
      await remoteDataSource.syncMilestone(model);
    } catch (e) {
      _logSyncError('Milestone', model.id, e);
    }
  }

  Future<void> _syncStreakRepairRemote(StreakRepairModel model) async {
    if (!await remoteDataSource.isAuthenticated()) return;
    try {
      await remoteDataSource.syncStreakRepair(model);
    } catch (e) {
      _logSyncError('StreakRepair', model.id, e);
    }
  }

  void _logSyncError(String type, String id, dynamic error) {
    developer.log(
      'Failed to sync $type: $id',
      name: 'multazim.sync',
      error: error,
      level: 1000,
    );
  }
}
