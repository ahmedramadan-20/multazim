import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../../domain/entities/streak.dart';
import '../../domain/entities/streak_repair.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/services/streak_service.dart';
import '../../domain/services/weekly_progress_service.dart';
import '../../domain/services/milestone_generator.dart';
import '../../domain/services/streak_recovery_service.dart';
import '../../domain/usecases/get_habits_usecase.dart';
import '../../domain/usecases/create_habit_usecase.dart';
import '../../domain/usecases/complete_habit_usecase.dart';
import '../../domain/usecases/skip_habit_usecase.dart';
import '../../domain/usecases/delete_habit_usecase.dart';
import '../../domain/usecases/update_habit_usecase.dart';
import '../../domain/usecases/get_today_event_usecase.dart';
import '../../domain/usecases/get_events_for_habit_usecase.dart';
import '../../domain/usecases/get_streak_repairs_usecase.dart';
import '../../domain/usecases/get_milestones_usecase.dart';
import '../../domain/usecases/save_milestone_usecase.dart';
import '../../domain/usecases/save_streak_repair_usecase.dart';
import 'habits_state.dart';

class HabitsCubit extends Cubit<HabitsState> {
  final GetHabitsUseCase _getHabits;
  final CreateHabitUseCase _createHabit;
  final CompleteHabitUseCase _completeHabit;
  final SkipHabitUseCase _skipHabit;
  final UpdateHabitUseCase _updateHabit;
  final DeleteHabitUseCase _deleteHabit;
  final GetTodayEventUseCase _getTodayEvent;
  final GetEventsForHabitUseCase _getEventsForHabit;
  final GetStreakRepairsUseCase _getStreakRepairs;
  final GetMilestonesUseCase _getMilestones;
  final SaveMilestoneUseCase _saveMilestone;
  final SaveStreakRepairUseCase _saveStreakRepair;
  final StreakService _streakService;
  final WeeklyProgressService _weeklyProgressService;
  final MilestoneGenerator _milestoneGenerator;
  final StreakRecoveryService _recoveryService;

  HabitsCubit({
    required GetHabitsUseCase getHabits,
    required CreateHabitUseCase createHabit,
    required CompleteHabitUseCase completeHabit,
    required SkipHabitUseCase skipHabit,
    required UpdateHabitUseCase updateHabit,
    required DeleteHabitUseCase deleteHabit,
    required GetTodayEventUseCase getTodayEvent,
    required GetEventsForHabitUseCase getEventsForHabit,
    required GetStreakRepairsUseCase getStreakRepairs,
    required GetMilestonesUseCase getMilestones,
    required SaveMilestoneUseCase saveMilestone,
    required SaveStreakRepairUseCase saveStreakRepair,
    required StreakService streakService,
    required WeeklyProgressService weeklyProgressService,
    required MilestoneGenerator milestoneGenerator,
    required StreakRecoveryService recoveryService,
  }) : _getHabits = getHabits,
       _createHabit = createHabit,
       _completeHabit = completeHabit,
       _skipHabit = skipHabit,
       _updateHabit = updateHabit,
       _deleteHabit = deleteHabit,
       _getTodayEvent = getTodayEvent,
       _getEventsForHabit = getEventsForHabit,
       _getStreakRepairs = getStreakRepairs,
       _getMilestones = getMilestones,
       _saveMilestone = saveMilestone,
       _saveStreakRepair = saveStreakRepair,
       _streakService = streakService,
       _weeklyProgressService = weeklyProgressService,
       _milestoneGenerator = milestoneGenerator,
       _recoveryService = recoveryService,
       super(HabitsInitial());

  Future<void> loadHabits() async {
    emit(HabitsLoading());
    try {
      final habits = await _getHabits();
      final now = DateTime.now();

      final todayEvents = <String, HabitEvent?>{};
      final streaks = <String, StreakState>{};
      final weeklyProgress = <String, ({int current, int target})>{};
      final milestones = <String, List<Milestone>>{};

      for (final habit in habits) {
        // Today's event
        todayEvents[habit.id] = await _getTodayEvent(habit.id);

        // Fetch events and repairs for streak/progress calculation
        final events = await _getEventsForHabit(habit.id);
        final repairs = await _getStreakRepairs(habit.id);

        // Streak calculation
        streaks[habit.id] = _streakService.calculateStreak(
          habit,
          events,
          repairs,
        );

        // Weekly progress
        weeklyProgress[habit.id] = _weeklyProgressService.getProgress(
          habit,
          events,
          now,
        );

        // Milestones
        milestones[habit.id] = await _getMilestones(habit.id);
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
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> completeHabit(String habitId) async {
    final currentState = state;
    if (currentState is! HabitsLoaded) return;

    try {
      final oldStreak = currentState.streaks[habitId]?.current ?? 0;

      await _completeHabit(habitId, DateTime.now());

      // Reload to get updated data
      await loadHabits();

      // Check for new milestones
      final newState = state;
      if (newState is HabitsLoaded) {
        final newStreakState = newState.streaks[habitId];
        if (newStreakState != null) {
          final milestone = _milestoneGenerator.checkMilestone(
            habitId,
            oldStreak,
            newStreakState.current,
            DateTime.now(),
          );

          if (milestone != null) {
            await _saveMilestone(milestone);
            // Refresh to show newly added milestone
            await loadHabits();
          }
        }
      }
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

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
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> createHabit(Habit habit) async {
    try {
      await _createHabit(habit);
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> skipHabit(String habitId) async {
    try {
      await _skipHabit(habitId, DateTime.now());
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _updateHabit(habit);
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _deleteHabit(habitId);
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }
}
