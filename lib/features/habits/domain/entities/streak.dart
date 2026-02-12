import 'package:equatable/equatable.dart';

/// The type of streak algorithm applied to a habit, determined
/// by the habit's [StrictnessLevel] via [StreakMapper].
enum StreakType {
  /// Every scheduled day must be completed. One miss = reset.
  perfect,

  /// Allows a configurable number of grace days between
  /// completions without breaking the streak.
  flexible,

  /// Rolling-window approach: streak increments for each
  /// window where the minimum completion threshold is met.
  consistency,
}

/// Immutable snapshot of a habit's current streak state.
class StreakState extends Equatable {
  /// Number of consecutive streak units (days or windows).
  final int currentStreak;

  /// Highest streak ever achieved for this habit.
  final int longestStreak;

  /// Algorithm used to compute this streak.
  final StreakType type;

  /// Date of the most recent completion event, if any.
  final DateTime? lastCompletedDate;

  /// Whether the streak is currently alive (not broken).
  final bool isActive;

  const StreakState({
    required this.currentStreak,
    required this.longestStreak,
    required this.type,
    this.lastCompletedDate,
    required this.isActive,
  });

  /// A zero-state streak for habits with no events yet.
  const StreakState.empty(this.type)
    : currentStreak = 0,
      longestStreak = 0,
      lastCompletedDate = null,
      isActive = false;

  @override
  List<Object?> get props => [
    currentStreak,
    longestStreak,
    type,
    lastCompletedDate,
    isActive,
  ];
}
