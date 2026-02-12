import 'package:equatable/equatable.dart';

class DailySummary extends Equatable {
  final DateTime date;
  final int totalScheduled;
  final int totalCompleted;
  final int totalSkipped;
  final int totalFailed;
  final double completionRate;

  const DailySummary({
    required this.date,
    required this.totalScheduled,
    required this.totalCompleted,
    required this.totalSkipped,
    required this.totalFailed,
    required this.completionRate,
  });

  /// Computed property: inconsistent/missed habits (scheduled but no action)
  int get totalMissed =>
      totalScheduled - totalCompleted - totalSkipped - totalFailed;

  /// Computed property: is this a perfect day? (100% completion)
  bool get isPerfectDay =>
      totalCompleted == totalScheduled && totalScheduled > 0;

  @override
  List<Object?> get props => [
    date,
    totalScheduled,
    totalCompleted,
    totalSkipped,
    totalFailed,
    completionRate,
  ];
}
