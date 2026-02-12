import 'package:equatable/equatable.dart';

enum InsightType { streakMilestone, warning, trend, general }

enum InsightScope { global, habitSpecific }

enum InsightPriority { low, medium, high }

class Insight extends Equatable {
  final String title;
  final String message;
  final InsightType type;
  final InsightScope scope;
  final InsightPriority priority;
  final String? relatedHabitId;

  const Insight({
    required this.title,
    required this.message,
    required this.type,
    required this.scope,
    this.priority = InsightPriority.medium,
    this.relatedHabitId,
  });

  @override
  List<Object?> get props => [
    title,
    message,
    type,
    scope,
    priority,
    relatedHabitId,
  ];
}
