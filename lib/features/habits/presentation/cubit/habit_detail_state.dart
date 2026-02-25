import 'package:equatable/equatable.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../../domain/entities/streak.dart';
import '../../domain/entities/milestone.dart';

sealed class HabitDetailState extends Equatable {
  const HabitDetailState();
  @override
  List<Object?> get props => [];
}

class HabitDetailInitial extends HabitDetailState {}

class HabitDetailLoading extends HabitDetailState {}

class HabitDetailLoaded extends HabitDetailState {
  final Habit habit;
  final List<HabitEvent> events;
  final StreakState streak;
  final List<Milestone> milestones;

  const HabitDetailLoaded({
    required this.habit,
    required this.events,
    required this.streak,
    required this.milestones,
  });

  @override
  List<Object?> get props => [habit, events, streak, milestones];
}

class HabitDetailError extends HabitDetailState {
  final String message;
  const HabitDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
