import 'dart:developer' as developer;
import '../../../habits/data/datasources/local/habit_local_datasource.dart';
import '../../../habits/data/datasources/remote/habit_remote_datasource.dart';

class SyncService {
  final HabitLocalDataSource localDataSource;
  final HabitRemoteDataSource remoteDataSource;

  SyncService({required this.localDataSource, required this.remoteDataSource});

  // ─────────────────────────────────────────────────
  // FULL PULL — called after login on a new device
  // Pulls everything from Supabase and merges into
  // local ObjectBox. Safe to call multiple times.
  // ─────────────────────────────────────────────────

  Future<void> pullAndMerge() async {
    try {
      await _mergeHabits();
      await _mergeEvents();
      await _mergeMilestones();
      await _mergeStreakRepairs();
      developer.log('Sync complete', name: 'multazim.sync');
    } catch (e) {
      developer.log('Sync failed: $e', name: 'multazim.sync', level: 1000);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────
  // HABITS
  // ─────────────────────────────────────────────────

  Future<void> _mergeHabits() async {
    final remoteHabits = await remoteDataSource.fetchHabits();

    for (final remote in remoteHabits) {
      final local = await localDataSource.getHabitById(remote.id);

      if (local == null) {
        // New habit from remote — insert locally
        await localDataSource.saveHabit(remote);
      } else if (remote.version > local.version) {
        // Remote is newer — overwrite local
        // Preserve the ObjectBox dbId so it updates rather than inserts
        remote.dbId = local.dbId;
        await localDataSource.saveHabit(remote);
      }
      // local.version >= remote.version → local wins, do nothing
    }
  }

  // ─────────────────────────────────────────────────
  // EVENTS
  // ─────────────────────────────────────────────────

  Future<void> _mergeEvents() async {
    final remoteEvents = await remoteDataSource.fetchAllEvents();

    for (final remote in remoteEvents) {
      final local = await localDataSource.getEventById(remote.id);

      if (local == null) {
        await localDataSource.saveEvent(remote);
      }
      // Events are immutable once created — no conflict resolution needed
    }
  }

  // ─────────────────────────────────────────────────
  // MILESTONES
  // ─────────────────────────────────────────────────

  Future<void> _mergeMilestones() async {
    final remoteMilestones = await remoteDataSource.fetchAllMilestones();

    for (final remote in remoteMilestones) {
      final local = await localDataSource.getMilestoneById(remote.id);
      if (local == null) {
        await localDataSource.saveMilestone(remote);
      }
    }
  }

  // ─────────────────────────────────────────────────
  // STREAK REPAIRS
  // ─────────────────────────────────────────────────

  Future<void> _mergeStreakRepairs() async {
    final remoteRepairs = await remoteDataSource.fetchAllStreakRepairs();

    for (final remote in remoteRepairs) {
      final local = await localDataSource.getStreakRepairById(remote.id);
      if (local == null) {
        await localDataSource.saveStreakRepair(remote);
      }
    }
  }
}
