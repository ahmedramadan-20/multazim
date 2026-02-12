import 'package:equatable/equatable.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../../domain/entities/streak.dart';

abstract class HabitsState extends Equatable {
  const HabitsState();

  @override
  List<Object?> get props => [];
}

class HabitsInitial extends HabitsState {}

class HabitsLoading extends HabitsState {}

class HabitsLoaded extends HabitsState {
  final List<Habit> habits;

  /// Map habitId → today's event (if any) for O(1) lookup.
  final Map<String, HabitEvent?> todayEvents;

  /// Map habitId → current streak state.
  final Map<String, StreakState> streaks;

  const HabitsLoaded({
    required this.habits,
    required this.todayEvents,
    required this.streaks,
  });

  @override
  List<Object?> get props => [habits, todayEvents, streaks];
}

class HabitsError extends HabitsState {
  final String message;

  const HabitsError(this.message);

  @override
  List<Object?> get props => [message];
}
