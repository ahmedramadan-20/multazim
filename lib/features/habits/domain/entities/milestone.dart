import 'package:equatable/equatable.dart';

/// Represents achieved streak milestones (e.g., 7, 30, 100 days).
class Milestone extends Equatable {
  final String id;
  final String habitId;
  final String title;
  final int days;
  final DateTime reachedDate;

  const Milestone({
    required this.id,
    required this.habitId,
    required this.title,
    required this.days,
    required this.reachedDate,
  });

  @override
  List<Object?> get props => [id, habitId, title, days, reachedDate];
}
