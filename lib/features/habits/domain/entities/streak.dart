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

class StreakState extends Equatable {
  /// Number of consecutive streak units (days or windows).
  final int current;

  /// Highest streak ever achieved for this habit.
  final int longest;

  /// Whether the streak is currently alive (not broken).
  final bool isActive;

  /// Date of the most recent completion event, if any.
  final DateTime? lastCompletedDate;

  const StreakState({
    required this.current,
    required this.longest,
    required this.isActive,
    this.lastCompletedDate,
  });

  /// A zero-state streak for habits with no events yet.
  const StreakState.empty()
    : current = 0,
      longest = 0,
      isActive = false,
      lastCompletedDate = null;

  @override
  List<Object?> get props => [current, longest, isActive, lastCompletedDate];
}
