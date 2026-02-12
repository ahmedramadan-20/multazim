import 'package:equatable/equatable.dart';
import 'package:multazim/features/analytics/domain/entities/daily_summary.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final List<DailySummary> summaries;
  final Map<DateTime, double>? heatmapData;
  final Map<int, double>? dayOfWeekStats;

  const AnalyticsLoaded({
    required this.summaries,
    this.heatmapData,
    this.dayOfWeekStats,
  });

  @override
  List<Object?> get props => [summaries, heatmapData, dayOfWeekStats];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
