import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/services/streak_service.dart';
import 'habit_detail_state.dart';

class HabitDetailCubit extends Cubit<HabitDetailState> {
  final HabitRepository _repository;
  final StreakService _streakService;

  HabitDetailCubit({
    required HabitRepository repository,
    required StreakService streakService,
  }) : _repository = repository,
       _streakService = streakService,
       super(HabitDetailInitial());

  Future<void> load(String habitId) async {
    emit(HabitDetailLoading());
    try {
      final habit = await _repository.getHabitById(habitId);
      if (habit == null) {
        emit(const HabitDetailError('العادة غير موجودة'));
        return;
      }

      final events = await _repository.getEventsForHabit(habitId);
      final repairs = await _repository.getStreakRepairs(habitId);
      final milestones = await _repository.getMilestones(habitId);
      final streak = _streakService.calculateStreak(habit, events, repairs);

      // Sort events newest first
      final sorted = List.of(events)..sort((a, b) => b.date.compareTo(a.date));

      emit(
        HabitDetailLoaded(
          habit: habit,
          events: sorted,
          streak: streak,
          milestones: milestones,
        ),
      );
    } catch (e) {
      emit(HabitDetailError(e.toString()));
    }
  }
}
