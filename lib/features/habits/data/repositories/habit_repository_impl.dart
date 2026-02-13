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
      _syncHabitRemote(model);
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
      _syncHabitRemote(model);
    } on LocalException catch (e) {
      throw LocalFailure(e.message);
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      await localDataSource.deleteHabit(id);

      // Phase 2: Remote Sync
      _deleteHabitRemote(id);
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
      _syncEventRemote(model);
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
      _syncStreakRepairRemote(model);
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
      _syncMilestoneRemote(model);
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

  // ─────────────────────────────────────────────────
  // PRIVATE SYNC HELPERS (Phase 2)
  // ─────────────────────────────────────────────────

  void _syncHabitRemote(HabitModel model) {
    remoteDataSource.syncHabit(model).catchError((e) {
      developer.log(
        'Failed to sync Habit: ${model.id}',
        name: 'multazim.sync',
        error: e,
        level: 1000,
      );
    });
  }

  void _deleteHabitRemote(String id) {
    remoteDataSource.deleteHabitRemote(id).catchError((e) {
      developer.log(
        'Failed to delete Habit remote: $id',
        name: 'multazim.sync',
        error: e,
        level: 1000,
      );
    });
  }

  void _syncEventRemote(HabitEventModel model) {
    remoteDataSource.syncEvent(model).catchError((e) {
      developer.log(
        'Failed to sync Event: ${model.id}',
        name: 'multazim.sync',
        error: e,
        level: 1000,
      );
    });
  }

  void _syncMilestoneRemote(MilestoneModel model) {
    remoteDataSource.syncMilestone(model).catchError((e) {
      developer.log(
        'Failed to sync Milestone: ${model.id}',
        name: 'multazim.sync',
        error: e,
        level: 1000,
      );
    });
  }

  void _syncStreakRepairRemote(StreakRepairModel model) {
    remoteDataSource.syncStreakRepair(model).catchError((e) {
      developer.log(
        'Failed to sync StreakRepair: ${model.id}',
        name: 'multazim.sync',
        error: e,
        level: 1000,
      );
    });
  }
}
