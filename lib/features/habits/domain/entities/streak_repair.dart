import 'package:equatable/equatable.dart';

/// Represents a streak override record.
/// NOTE: This does NOT mutate historical events. It is a separate override layer.
class StreakRepair extends Equatable {
  final String id;
  final String habitId;
  final DateTime date;
  final String reason;
  final DateTime createdAt;

  const StreakRepair({
    required this.id,
    required this.habitId,
    required this.date,
    required this.reason,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, habitId, date, reason, createdAt];
}
