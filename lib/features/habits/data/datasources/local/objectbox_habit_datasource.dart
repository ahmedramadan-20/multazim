import '../../../../../objectbox.g.dart';
import '../../../../../core/data/objectbox_store.dart';
import '../../../../../core/error/exceptions.dart';
import '../../models/habit_model.dart';
import '../../models/habit_event_model.dart';
import '../../models/streak_repair_model.dart';
import '../../models/milestone_model.dart';
import 'habit_local_datasource.dart';
import '../../../../../core/utils/date_utils.dart';

/// ObjectBox implementation of [HabitLocalDataSource].
///
/// All methods wrap ObjectBox operations in try-catch and throw
/// [LocalException] on failure, as required by Clean Architecture.
class ObjectBoxHabitDataSource implements HabitLocalDataSource {
  final Box<HabitModel> _habitBox;
  final Box<HabitEventModel> _eventBox;
  final Box<StreakRepairModel> _repairBox;
  final Box<MilestoneModel> _milestoneBox;

  ObjectBoxHabitDataSource(ObjectBoxStore store)
    : _habitBox = store.store.box<HabitModel>(),
      _eventBox = store.store.box<HabitEventModel>(),
      _repairBox = store.store.box<StreakRepairModel>(),
      _milestoneBox = store.store.box<MilestoneModel>();

  @override
  Future<List<HabitModel>> getHabits() async {
    try {
      return _habitBox.getAll();
    } catch (e) {
      throw LocalException('Failed to load habits: $e');
    }
  }

  @override
  Future<HabitModel?> getHabitById(String id) async {
    try {
      final query = _habitBox.query(HabitModel_.id.equals(id)).build();
      final result = query.findFirst();
      query.close();
      return result;
    } catch (e) {
      throw LocalException('Failed to get habit $id: $e');
    }
  }

  @override
  Future<void> saveHabit(HabitModel habit) async {
    try {
      final existing = await getHabitById(habit.id);
      if (existing != null) {
        habit.dbId = existing.dbId;
      }
      _habitBox.put(habit);
    } catch (e) {
      if (e is LocalException) rethrow;
      throw LocalException('Failed to save habit: $e');
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      final habit = await getHabitById(id);
      if (habit != null) {
        _habitBox.remove(habit.dbId);
      }
    } catch (e) {
      if (e is LocalException) rethrow;
      throw LocalException('Failed to delete habit $id: $e');
    }
  }

  @override
  Future<void> saveEvent(HabitEventModel event) async {
    try {
      final existingQuery = _eventBox
          .query(HabitEventModel_.id.equals(event.id))
          .build();
      final existing = existingQuery.findFirst();
      existingQuery.close();

      if (existing != null) {
        event.dbId = existing.dbId;
      }
      _eventBox.put(event);
    } catch (e) {
      if (e is LocalException) rethrow;
      throw LocalException('Failed to save event: $e');
    }
  }

  @override
  Future<List<HabitEventModel>> getEventsForHabit(String habitId) async {
    try {
      final query = _eventBox
          .query(HabitEventModel_.habitId.equals(habitId))
          .order(HabitEventModel_.date)
          .build();
      final results = query.find();
      query.close();
      return results;
    } catch (e) {
      throw LocalException('Failed to get events for habit $habitId: $e');
    }
  }

  @override
  Future<List<HabitEventModel>> getEventsForDate(DateTime date) async {
    try {
      final start = date.startOfDay.millisecondsSinceEpoch;
      final end = date.endOfDay.millisecondsSinceEpoch;

      final query = _eventBox
          .query(HabitEventModel_.date.between(start, end))
          .build();
      final results = query.find();
      query.close();
      return results;
    } catch (e) {
      throw LocalException('Failed to get events for date $date: $e');
    }
  }

  @override
  Future<HabitEventModel?> getTodayEvent(String habitId) async {
    try {
      final now = DateTime.now();
      final start = now.startOfDay.millisecondsSinceEpoch;
      final end = now.endOfDay.millisecondsSinceEpoch;

      final query = _eventBox
          .query(
            HabitEventModel_.habitId
                .equals(habitId)
                .and(HabitEventModel_.date.between(start, end)),
          )
          .build();
      final result = query.findFirst();
      query.close();
      return result;
    } catch (e) {
      throw LocalException('Failed to get today event for habit $habitId: $e');
    }
  }

  @override
  Future<void> saveStreakRepair(StreakRepairModel repair) async {
    try {
      _repairBox.put(repair);
    } catch (e) {
      throw LocalException('Failed to save streak repair: $e');
    }
  }

  @override
  Future<List<StreakRepairModel>> getStreakRepairs(String habitId) async {
    try {
      final query = _repairBox
          .query(StreakRepairModel_.habitId.equals(habitId))
          .order(StreakRepairModel_.date, flags: Order.descending)
          .build();
      final results = query.find();
      query.close();
      return results;
    } catch (e) {
      throw LocalException('Failed to get repairs for habit $habitId: $e');
    }
  }

  @override
  Future<void> saveMilestone(MilestoneModel milestone) async {
    try {
      _milestoneBox.put(milestone);
    } catch (e) {
      throw LocalException('Failed to save milestone: $e');
    }
  }

  @override
  Future<List<MilestoneModel>> getMilestones(String habitId) async {
    try {
      final query = _milestoneBox
          .query(MilestoneModel_.habitId.equals(habitId))
          .order(MilestoneModel_.achievedAt, flags: Order.descending)
          .build();
      final results = query.find();
      query.close();
      return results;
    } catch (e) {
      throw LocalException('Failed to get milestones for habit $habitId: $e');
    }
  }

  @override
  Future<List<MilestoneModel>> getAllMilestones() async {
    try {
      return _milestoneBox.getAll();
    } catch (e) {
      throw LocalException('Failed to get all milestones: $e');
    }
  }
}
