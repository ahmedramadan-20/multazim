import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/error/exceptions.dart';
import '../../models/habit_model.dart';
import '../../models/habit_event_model.dart';
import '../../models/milestone_model.dart';
import '../../models/streak_repair_model.dart';
import 'habit_remote_datasource.dart';

class SupabaseHabitDataSource implements HabitRemoteDataSource {
  final SupabaseClient _client;

  SupabaseHabitDataSource(this._client);

  @override
  Future<String> getCurrentUserId() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const RemoteException('User not authenticated');
    }
    return user.id;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _client.auth.currentUser != null;
  }

  // ─────────────────────────────────────────────────
  // HABITS
  // ─────────────────────────────────────────────────

  @override
  Future<void> syncHabit(HabitModel habit) async {
    await syncHabitsBatch([habit]);
  }

  @override
  Future<void> syncHabitsBatch(List<HabitModel> habits) async {
    if (habits.isEmpty) return;
    try {
      final userId = await getCurrentUserId();
      final updatedAt = DateTime.now().toUtc().toIso8601String();

      final dataList = habits.map((habit) {
        return {
          'id': habit.id,
          'user_id': userId,
          'name': habit.name,
          'icon': habit.icon,
          'color': habit.color,
          'category': habit.categoryName,
          'schedule_type': habit.scheduleType,
          'schedule_data': habit.scheduleJson,
          'goal_type': habit.goalType,
          'goal_data': habit.goalJson,
          'strictness': habit.strictnessName,
          'difficulty': habit.difficulty,
          'start_date': habit.startDate.toIso8601String(),
          'end_date': habit.endDate?.toIso8601String(),
          'is_active': habit.isActive,
          'created_at': habit.createdAt.toIso8601String(),
          'updated_at': updatedAt,
          'version': habit.version,
        };
      }).toList();

      await _client.from('habits').upsert(dataList);
    } catch (e) {
      throw RemoteException('Failed to sync habits batch: $e');
    }
  }

  @override
  Future<List<HabitModel>> fetchHabits() async {
    try {
      final userId = await getCurrentUserId();

      final response = await _client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => _habitFromJson(json)).toList();
    } catch (e) {
      throw RemoteException('Failed to fetch habits: $e');
    }
  }

  @override
  Future<void> deleteHabitRemote(String habitId) async {
    try {
      final userId = await getCurrentUserId();

      await _client
          .from('habits')
          .delete()
          .eq('id', habitId)
          .eq('user_id', userId);
    } catch (e) {
      throw RemoteException('Failed to delete habit: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // EVENTS
  // ─────────────────────────────────────────────────

  @override
  Future<void> syncEvent(HabitEventModel event) async {
    await syncEventsBatch([event]);
  }

  @override
  Future<void> syncEventsBatch(List<HabitEventModel> events) async {
    if (events.isEmpty) return;
    try {
      final userId = await getCurrentUserId();

      final dataList = events.map((event) {
        return {
          'id': event.id,
          'user_id': userId,
          'habit_id': event.habitId,
          'date': event.date.toIso8601String().split('T')[0],
          'status': event.statusName,
          'count_value': event.countValue,
          'note': event.note,
          'fail_reason': event.failReason,
          'created_at': event.createdAt.toIso8601String(),
        };
      }).toList();

      await _client.from('habit_events').upsert(dataList);
    } catch (e) {
      throw RemoteException('Failed to sync events batch: $e');
    }
  }

  @override
  Future<List<HabitEventModel>> fetchEvents(String habitId) async {
    try {
      final userId = await getCurrentUserId();

      final response = await _client
          .from('habit_events')
          .select()
          .eq('user_id', userId)
          .eq('habit_id', habitId)
          .order('date', ascending: false);

      return (response as List).map((json) => _eventFromJson(json)).toList();
    } catch (e) {
      throw RemoteException('Failed to fetch events: $e');
    }
  }

  @override
  Future<List<HabitEventModel>> fetchAllEvents() async {
    try {
      final userId = await getCurrentUserId();

      final response = await _client
          .from('habit_events')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      return (response as List).map((json) => _eventFromJson(json)).toList();
    } catch (e) {
      throw RemoteException('Failed to fetch all events: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // MILESTONES
  // ─────────────────────────────────────────────────

  @override
  Future<void> syncMilestone(MilestoneModel milestone) async {
    await syncMilestonesBatch([milestone]);
  }

  @override
  Future<void> syncMilestonesBatch(List<MilestoneModel> milestones) async {
    if (milestones.isEmpty) return;
    try {
      final userId = await getCurrentUserId();

      final dataList = milestones.map((milestone) {
        return {
          'id': milestone.id,
          'user_id': userId,
          'habit_id': milestone.habitId,
          'type': milestone.type,
          'achieved_at': milestone.achievedAt.toIso8601String(),
          'streak_value': milestone.streakValue,
          'created_at': milestone.createdAt.toIso8601String(),
        };
      }).toList();

      await _client.from('milestones').upsert(dataList);
    } catch (e) {
      throw RemoteException('Failed to sync milestones batch: $e');
    }
  }

  @override
  Future<List<MilestoneModel>> fetchMilestones(String habitId) async {
    try {
      final userId = await getCurrentUserId();

      final response = await _client
          .from('milestones')
          .select()
          .eq('user_id', userId)
          .eq('habit_id', habitId)
          .order('achieved_at', ascending: false);

      return (response as List)
          .map((json) => _milestoneFromJson(json))
          .toList();
    } catch (e) {
      throw RemoteException('Failed to fetch milestones: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // STREAK REPAIRS
  // ─────────────────────────────────────────────────

  @override
  Future<void> syncStreakRepair(StreakRepairModel repair) async {
    await syncStreakRepairsBatch([repair]);
  }

  @override
  Future<void> syncStreakRepairsBatch(List<StreakRepairModel> repairs) async {
    if (repairs.isEmpty) return;
    try {
      final userId = await getCurrentUserId();

      final dataList = repairs.map((repair) {
        return {
          'id': repair.id,
          'user_id': userId,
          'habit_id': repair.habitId,
          'date': repair.date.toIso8601String().split('T')[0],
          'reason': repair.reason,
          'created_at': repair.createdAt.toIso8601String(),
        };
      }).toList();

      await _client.from('streak_repairs').upsert(dataList);
    } catch (e) {
      throw RemoteException('Failed to sync streak repairs batch: $e');
    }
  }

  @override
  Future<List<StreakRepairModel>> fetchStreakRepairs(String habitId) async {
    try {
      final userId = await getCurrentUserId();

      final response = await _client
          .from('streak_repairs')
          .select()
          .eq('user_id', userId)
          .eq('habit_id', habitId)
          .order('date', ascending: false);

      return (response as List).map((json) => _repairFromJson(json)).toList();
    } catch (e) {
      throw RemoteException('Failed to fetch streak repairs: $e');
    }
  }

  @override
  Future<List<MilestoneModel>> fetchAllMilestones() async {
    try {
      final userId = await getCurrentUserId();

      final response = await _client
          .from('milestones')
          .select()
          .eq('user_id', userId)
          .order('achieved_at', ascending: false);

      return (response as List)
          .map((json) => _milestoneFromJson(json))
          .toList();
    } catch (e) {
      throw RemoteException('Failed to fetch all milestones: $e');
    }
  }

  @override
  Future<List<StreakRepairModel>> fetchAllStreakRepairs() async {
    try {
      final userId = await getCurrentUserId();

      final response = await _client
          .from('streak_repairs')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      return (response as List).map((json) => _repairFromJson(json)).toList();
    } catch (e) {
      throw RemoteException('Failed to fetch all streak repairs: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // JSON CONVERTERS (Supabase → Model)
  // ─────────────────────────────────────────────────

  HabitModel _habitFromJson(Map<String, dynamic> json) {
    return HabitModel()
      ..id = json['id']
      ..name = json['name']
      ..icon = json['icon']
      ..color = json['color']
      ..categoryName = json['category']
      ..scheduleType = json['schedule_type']
      ..scheduleJson = json['schedule_data']
      ..goalType = json['goal_type']
      ..goalJson = json['goal_data']
      ..strictnessName = json['strictness']
      ..difficulty = json['difficulty']
      ..startDate = DateTime.parse(json['start_date'])
      ..endDate = json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null
      ..isActive = json['is_active']
      ..createdAt = DateTime.parse(json['created_at'])
      ..version = json['version'] ?? 1;
  }

  HabitEventModel _eventFromJson(Map<String, dynamic> json) {
    return HabitEventModel()
      ..id = json['id']
      ..habitId = json['habit_id']
      ..date = _parseLocalDate(json['date'])
      ..statusName = json['status']
      ..countValue = json['count_value']
      ..note = json['note']
      ..failReason = json['fail_reason']
      ..createdAt = DateTime.parse(json['created_at']);
  }

  MilestoneModel _milestoneFromJson(Map<String, dynamic> json) {
    return MilestoneModel()
      ..id = json['id']
      ..habitId = json['habit_id']
      ..type = json['type']
      ..achievedAt = DateTime.parse(json['achieved_at'])
      ..streakValue = json['streak_value']
      ..createdAt = DateTime.parse(json['created_at']);
  }

  StreakRepairModel _repairFromJson(Map<String, dynamic> json) {
    return StreakRepairModel()
      ..id = json['id']
      ..habitId = json['habit_id']
      ..date = _parseLocalDate(json['date'])
      ..reason = json['reason']
      ..createdAt = DateTime.parse(json['created_at']);
  }

  /// Safely parses a date-only string (e.g. "2024-01-15") into
  /// a local DateTime at midnight, consistent with how ObjectBox
  /// stores and how isScheduledOn() / analytics compare dates.
  DateTime _parseLocalDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]), // year
      int.parse(parts[1]), // month
      int.parse(parts[2]), // day
    );
  }
}
