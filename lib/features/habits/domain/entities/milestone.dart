import 'package:equatable/equatable.dart';

/// Represents a factual milestone achievement in a habit's lifecycle
/// (e.g. streak reached 7, 30, 100 days).
class Milestone extends Equatable {
  final String id;

  /// FK to habit
  final String habitId;

  /// Logical identifier: 'streak_7', 'streak_30', 'streak_100'
  final String type;

  /// Actual streak value reached
  final int streakValue;

  /// When the milestone was achieved
  final DateTime achievedAt;

  /// Creation timestamp (for sync & ordering)
  final DateTime createdAt;

  const Milestone({
    required this.id,
    required this.habitId,
    required this.type,
    required this.streakValue,
    required this.achievedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    habitId,
    type,
    streakValue,
    achievedAt,
    createdAt,
  ];
}
