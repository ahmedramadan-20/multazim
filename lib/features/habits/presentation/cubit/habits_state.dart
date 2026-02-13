import 'package:equatable/equatable.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../../domain/entities/streak.dart';
import '../../domain/entities/milestone.dart';

sealed class HabitsState extends Equatable {
  const HabitsState();

  @override
  List<Object?> get props => [];
}

final class HabitsInitial extends HabitsState {}

final class HabitsLoading extends HabitsState {}

final class HabitsLoaded extends HabitsState {
  final List<Habit> habits;

  /// Map habitId → today's event (if any) for O(1) lookup.
  final Map<String, HabitEvent?> todayEvents;

  /// Map habitId → current streak state.
  final Map<String, StreakState> streaks;

  /// Map habitId → {current completions, target} for the current week.
  final Map<String, ({int current, int target})> weeklyProgress;

  /// Map habitId → list of achieved milestones.
  final Map<String, List<Milestone>> milestones;

  const HabitsLoaded({
    required this.habits,
    required this.todayEvents,
    required this.streaks,
    required this.weeklyProgress,
    required this.milestones,
  });

  @override
  List<Object?> get props => [
    habits,
    todayEvents,
    streaks,
    weeklyProgress,
    milestones,
  ];
}

final class HabitsError extends HabitsState {
  final String message;

  const HabitsError(this.message);

  @override
  List<Object?> get props => [message];
}
