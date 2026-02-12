import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../../domain/entities/streak.dart';
import '../../domain/services/streak_calculation_service.dart';
import '../../domain/usecases/get_habits_usecase.dart';
import '../../domain/usecases/create_habit_usecase.dart';
import '../../domain/usecases/complete_habit_usecase.dart';
import '../../domain/usecases/skip_habit_usecase.dart';
import '../../domain/usecases/delete_habit_usecase.dart';
import '../../domain/usecases/update_habit_usecase.dart';
import '../../domain/repositories/habit_repository.dart';

import 'habits_state.dart';

/// Manages the state of habits, today's events, and streaks.
///
/// ARCHITECTURAL NOTE (Tech Debt):
/// This Cubit directly accesses [HabitRepository] for
/// `getTodayEvent` and `getEventsForHabit`. Wrap these in
/// use cases when the app grows beyond Phase 2.
class HabitsCubit extends Cubit<HabitsState> {
  final GetHabitsUseCase _getHabits;
  final CreateHabitUseCase _createHabit;
  final CompleteHabitUseCase _completeHabit;
  final SkipHabitUseCase _skipHabit;
  final UpdateHabitUseCase _updateHabit;
  final DeleteHabitUseCase _deleteHabit;
  final HabitRepository _repository;
  final StreakCalculationService _streakService;

  HabitsCubit({
    required GetHabitsUseCase getHabits,
    required CreateHabitUseCase createHabit,
    required CompleteHabitUseCase completeHabit,
    required SkipHabitUseCase skipHabit,
    required UpdateHabitUseCase updateHabit,
    required DeleteHabitUseCase deleteHabit,
    required HabitRepository repository,
    required StreakCalculationService streakService,
  }) : _getHabits = getHabits,
       _createHabit = createHabit,
       _completeHabit = completeHabit,
       _skipHabit = skipHabit,
       _updateHabit = updateHabit,
       _deleteHabit = deleteHabit,
       _repository = repository,
       _streakService = streakService,
       super(HabitsInitial());

  Future<void> loadHabits() async {
    emit(HabitsLoading());
    try {
      final habits = await _getHabits();

      final todayEvents = <String, HabitEvent?>{};
      final streaks = <String, StreakState>{};

      for (final habit in habits) {
        // Today's event
        todayEvents[habit.id] = await _repository.getTodayEvent(habit.id);

        // Streak calculation
        final events = await _repository.getEventsForHabit(habit.id);
        streaks[habit.id] = _streakService.calculate(
          habit: habit,
          events: events,
        );
      }

      emit(
        HabitsLoaded(
          habits: habits,
          todayEvents: todayEvents,
          streaks: streaks,
        ),
      );
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

  Future<void> completeHabit(String habitId) async {
    try {
      await _completeHabit(habitId, DateTime.now());
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
