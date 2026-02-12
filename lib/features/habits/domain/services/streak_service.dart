import '../entities/habit.dart';
import '../entities/habit_event.dart';
import '../entities/streak.dart';
import '../entities/streak_repair.dart';
import 'streak_calculation_service.dart';

/// Orchestrator service that determines the final streak state by
/// combining habit events with repair overrides.
class StreakService {
  final StreakCalculationService _calculationService;

  StreakService(this._calculationService);

  /// Calculates the final streak state for a habit, considering both
  /// actual completion events and streak repairs (overrides).
  StreakState calculateStreak(
    Habit habit,
    List<HabitEvent> events,
    List<StreakRepair> repairs,
  ) {
    // Convert repairs into "synthetic" completion events to bridge gaps
    final syntheticEvents = repairs
        .map(
          (r) => HabitEvent(
            id: r.id,
            habitId: r.habitId,
            date: r.date,
            createdAt: r.date, // Add mandatory createdAt
            status: HabitEventStatus.completed,
          ),
        )
        .toList();

    // Merge actual events with synthetic ones
    final allEvents = [...events, ...syntheticEvents];

    // Delegate to calculation service
    return _calculationService.calculate(habit: habit, events: allEvents);
  }
}
