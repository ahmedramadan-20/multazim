import 'package:equatable/equatable.dart';
import '../../../../features/habits/domain/entities/streak.dart';

class HabitAnalyticsSnapshot extends Equatable {
  final String habitId;
  final String habitName;
  final StreakState streak;
  final Map<int, double> dayOfWeekCompletionRates; // 1-7 -> 0.0-1.0
  final double completionRateLast30Days;

  const HabitAnalyticsSnapshot({
    required this.habitId,
    required this.habitName,
    required this.streak,
    required this.dayOfWeekCompletionRates,
    required this.completionRateLast30Days,
  });

  @override
  List<Object?> get props => [
    habitId,
    habitName,
    streak,
    dayOfWeekCompletionRates,
    completionRateLast30Days,
  ];
}
