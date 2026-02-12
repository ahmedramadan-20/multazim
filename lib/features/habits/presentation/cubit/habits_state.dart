import 'package:equatable/equatable.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';

abstract class HabitsState extends Equatable {
  const HabitsState();

  @override
  List<Object?> get props => [];
}

class HabitsInitial extends HabitsState {}

class HabitsLoading extends HabitsState {}

class HabitsLoaded extends HabitsState {
  final List<Habit> habits;
  // Map habitId -> today's event (if any)
  // This allows O(1) lookup to see if a habit is completed today
  final Map<String, HabitEvent?> todayEvents;

  const HabitsLoaded({required this.habits, required this.todayEvents});

  @override
  List<Object?> get props => [habits, todayEvents];
}

class HabitsError extends HabitsState {
  final String message;

  const HabitsError(this.message);

  @override
  List<Object?> get props => [message];
}
