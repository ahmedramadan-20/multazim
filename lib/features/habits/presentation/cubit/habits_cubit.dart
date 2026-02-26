import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../../domain/entities/streak.dart';
import '../../domain/entities/streak_repair.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/services/streak_service.dart';
import '../../domain/services/weekly_progress_service.dart';
import '../../domain/services/streak_recovery_service.dart';
import '../../domain/usecases/watch_habits_usecase.dart';
import '../../domain/usecases/create_habit_usecase.dart';
import '../../domain/usecases/complete_habit_usecase.dart';
import '../../domain/usecases/skip_habit_usecase.dart';
import '../../domain/usecases/delete_habit_usecase.dart';
import '../../domain/usecases/update_habit_usecase.dart';
import '../../domain/usecases/get_streak_repairs_usecase.dart';
import '../../domain/usecases/watch_all_events_usecase.dart';
import '../../domain/usecases/watch_all_streak_repairs_usecase.dart';
import '../../domain/usecases/watch_all_milestones_usecase.dart';
import '../../domain/usecases/save_streak_repair_usecase.dart';
import '../../../../core/services/notification_service.dart';
import 'habits_state.dart';

class HabitsCubit extends Cubit<HabitsState> {
  final WatchHabitsUseCase _watchHabits;
  final WatchAllEventsUseCase _watchAllEvents;
  final WatchAllStreakRepairsUseCase _watchAllStreakRepairs;
  final WatchAllMilestonesUseCase _watchAllMilestones;
  final GetStreakRepairsUseCase _getStreakRepairs;
  final CreateHabitUseCase _createHabit;
  final CompleteHabitUseCase _completeHabit;
  final SkipHabitUseCase _skipHabit;
  final UpdateHabitUseCase _updateHabit;
  final DeleteHabitUseCase _deleteHabit;
  final SaveStreakRepairUseCase _saveStreakRepair;
  final StreakService _streakService;
  final WeeklyProgressService _weeklyProgressService;
  final StreakRecoveryService _recoveryService;

  StreamSubscription? _dataSubscription;

  // Track if we've done first-load reschedule to avoid repeating on every update
  bool _hasRescheduled = false;

  HabitsCubit({
    required WatchHabitsUseCase watchHabits,
    required WatchAllEventsUseCase watchAllEvents,
    required WatchAllStreakRepairsUseCase watchAllStreakRepairs,
    required WatchAllMilestonesUseCase watchAllMilestones,
    required GetStreakRepairsUseCase getStreakRepairs,
    required CreateHabitUseCase createHabit,
    required CompleteHabitUseCase completeHabit,
    required SkipHabitUseCase skipHabit,
    required UpdateHabitUseCase updateHabit,
    required DeleteHabitUseCase deleteHabit,
    required SaveStreakRepairUseCase saveStreakRepair,
    required StreakService streakService,
    required WeeklyProgressService weeklyProgressService,
    required StreakRecoveryService recoveryService,
  }) : _watchHabits = watchHabits,
       _watchAllEvents = watchAllEvents,
       _watchAllStreakRepairs = watchAllStreakRepairs,
       _watchAllMilestones = watchAllMilestones,
       _getStreakRepairs = getStreakRepairs,
       _createHabit = createHabit,
       _completeHabit = completeHabit,
       _skipHabit = skipHabit,
       _updateHabit = updateHabit,
       _deleteHabit = deleteHabit,
       _saveStreakRepair = saveStreakRepair,
       _streakService = streakService,
       _weeklyProgressService = weeklyProgressService,
       _recoveryService = recoveryService,
       super(HabitsInitial()) {
    _initReactivity();
  }

  void _initReactivity() {
    _dataSubscription =
        Rx.combineLatest4(
          _watchHabits(),
          _watchAllEvents(),
          _watchAllStreakRepairs(),
          _watchAllMilestones(),
          (habits, events, repairs, milestones) =>
              (habits, events, repairs, milestones),
        ).listen((data) {
          _updateState(data.$1, data.$2, data.$3, data.$4);
        });
  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    return super.close();
  }

  void _updateState(
    List<Habit> habits,
    List<HabitEvent> allEvents,
    List<StreakRepair> allRepairs,
    List<Milestone> allMilestones,
  ) {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(
        const Duration(hours: 23, minutes: 59, seconds: 59),
      );

      final eventsByHabit = <String, List<HabitEvent>>{};
      for (final e in allEvents) {
        (eventsByHabit[e.habitId] ??= []).add(e);
      }

      final repairsByHabit = <String, List<StreakRepair>>{};
      for (final r in allRepairs) {
        (repairsByHabit[r.habitId] ??= []).add(r);
      }

      final milestonesByHabit = <String, List<Milestone>>{};
      for (final m in allMilestones) {
        (milestonesByHabit[m.habitId] ??= []).add(m);
      }

      final todayEvents = <String, HabitEvent?>{};
      final streaks = <String, StreakState>{};
      final weeklyProgress = <String, ({int current, int target})>{};
      final milestones = <String, List<Milestone>>{};

      for (final habit in habits) {
        final events = eventsByHabit[habit.id] ?? [];
        final repairs = repairsByHabit[habit.id] ?? [];

        todayEvents[habit.id] =
            (events
                    .where(
                      (e) =>
                          e.habitId == habit.id &&
                          !e.date.isBefore(todayStart) &&
                          !e.date.isAfter(todayEnd),
                    )
                    .toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
                .firstOrNull;

        streaks[habit.id] = _streakService.calculateStreak(
          habit,
          events,
          repairs,
        );

        weeklyProgress[habit.id] = _weeklyProgressService.getProgress(
          habit,
          events,
          now,
        );

        milestones[habit.id] = milestonesByHabit[habit.id] ?? [];
      }

      emit(
        HabitsLoaded(
          habits: habits,
          todayEvents: todayEvents,
          streaks: streaks,
          weeklyProgress: weeklyProgress,
          milestones: milestones,
        ),
      );

      // Reschedule all notifications once on first data load
      // (restores notifications after device reboot)
      if (!_hasRescheduled) {
        _hasRescheduled = true;
        NotificationService.instance.rescheduleAll(habits);
      }
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  // Kept as public API to avoid breaking call sites — no-op since
  // reactivity handles all updates automatically via streams
  Future<void> loadHabits() async {}

  // ─────────────────────────────────────────────────
  // COMPLETE
  // ─────────────────────────────────────────────────

  Future<void> completeHabit(String habitId, {int? countValue}) async {
    if (state is! HabitsLoaded) return;
    try {
      await _completeHabit(habitId, DateTime.now(), countValue: countValue);
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────────
  // SKIP
  // ─────────────────────────────────────────────────

  Future<void> skipHabit(String habitId) async {
    try {
      await _skipHabit(habitId, DateTime.now());
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────────

  Future<void> createHabit(Habit habit) async {
    try {
      await _createHabit(habit);
      // Schedule reminder if the user set one
      await NotificationService.instance.scheduleHabitReminder(habit);
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────────

  Future<void> updateHabit(Habit habit) async {
    try {
      await _updateHabit(habit);
      // Reschedule — this cancels the old notification and sets a new one
      // (or cancels if reminderTime was removed)
      await NotificationService.instance.scheduleHabitReminder(habit);
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────────

  Future<void> deleteHabit(String habitId) async {
    try {
      await _deleteHabit(habitId);
      // Cancel any scheduled notification for this habit
      await NotificationService.instance.cancelHabitReminder(habitId);
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────────
  // STREAK REPAIR
  // ─────────────────────────────────────────────────

  Future<void> repairStreak(String habitId, String reason) async {
    final currentState = state;
    if (currentState is! HabitsLoaded) return;

    try {
      final repairs = await _getStreakRepairs(habitId);
      final now = DateTime.now();

      if (!_recoveryService.canRepair(habitId, repairs, now)) {
        throw Exception('عذراً، يمكنك إصلاح السلسلة مرة واحدة فقط في الأسبوع');
      }

      final streak = currentState.streaks[habitId];
      if (streak == null || streak.lastCompletedDate == null) {
        throw Exception('لا يوجد تاريخ إكمال سابق للإصلاح');
      }

      final repairDate = _recoveryService.suggestRepairDate(
        streak.lastCompletedDate!,
        now,
      );

      if (repairDate == null) {
        throw Exception('السلسلة غير مكسورة حالياً');
      }

      final repair = StreakRepair(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        habitId: habitId,
        date: repairDate,
        reason: reason,
        createdAt: DateTime.now(),
      );

      await _saveStreakRepair(repair);
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }
}
