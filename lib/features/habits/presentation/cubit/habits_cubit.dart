import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../../domain/usecases/get_habits_usecase.dart';
import '../../domain/usecases/create_habit_usecase.dart';
import '../../domain/usecases/complete_habit_usecase.dart';
import '../../domain/usecases/skip_habit_usecase.dart';
import '../../domain/usecases/delete_habit_usecase.dart';
import '../../domain/usecases/update_habit_usecase.dart';
import '../../domain/repositories/habit_repository.dart';

import 'habits_state.dart';

/// Manages the state of habits and today's events.
///
/// ARCHITECTURAL NOTE (Tech Debt):
/// This Cubit directly accesses [HabitRepository.getTodayEvent] instead of
/// going through a use case. This is a pragmatic Phase 1 choice to avoid a
/// trivial wrapper use case.
///
/// TODO(phase-2): Create `GetTodayEventsUseCase` to remove this coupling.
class HabitsCubit extends Cubit<HabitsState> {
  final GetHabitsUseCase _getHabits;
  final CreateHabitUseCase _createHabit;
  final CompleteHabitUseCase _completeHabit;
  final SkipHabitUseCase _skipHabit;
  final UpdateHabitUseCase _updateHabit;
  final DeleteHabitUseCase _deleteHabit;
  final HabitRepository _repository; // Direct access for today's events lookup

  HabitsCubit({
    required GetHabitsUseCase getHabits,
    required CreateHabitUseCase createHabit,
    required CompleteHabitUseCase completeHabit,
    required SkipHabitUseCase skipHabit,
    required UpdateHabitUseCase updateHabit,
    required DeleteHabitUseCase deleteHabit,
    required HabitRepository repository,
  }) : _getHabits = getHabits,
       _createHabit = createHabit,
       _completeHabit = completeHabit,
       _skipHabit = skipHabit,
       _updateHabit = updateHabit,
       _deleteHabit = deleteHabit,
       _repository = repository,
       super(HabitsInitial());

  Future<void> loadHabits() async {
    emit(HabitsLoading());
    try {
      final habits = await _getHabits();

      // Fetch today's status for each habit
      final todayEvents = <String, HabitEvent?>{};
      for (final habit in habits) {
        final event = await _repository.getTodayEvent(habit.id);
        todayEvents[habit.id] = event;
      }

      emit(HabitsLoaded(habits: habits, todayEvents: todayEvents));
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
