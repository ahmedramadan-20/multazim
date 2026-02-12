import 'package:equatable/equatable.dart';

enum HabitEventStatus {
  completed, // ✅ done
  skipped, // ⏭  user chose to skip
  failed, // ❌ marked as failed
  missed, // ⚠️  auto-detected: scheduled but no action
}

class HabitEvent extends Equatable {
  final String id;
  final String habitId;
  final DateTime date;
  final HabitEventStatus status;
  final int? countValue; // for count-based habits
  final String? note; // long-press note
  final String? failReason; // why did this fail?
  final DateTime createdAt;

  const HabitEvent({
    required this.id,
    required this.habitId,
    required this.date,
    required this.status,
    this.countValue,
    this.note,
    this.failReason,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    habitId,
    date,
    status,
    countValue,
    note,
    failReason,
    createdAt,
  ];
}
