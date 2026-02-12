import 'package:equatable/equatable.dart';
import 'package:multazim/features/analytics/domain/entities/daily_summary.dart';
import 'package:multazim/features/analytics/domain/entities/insight.dart';
import 'package:multazim/features/habits/domain/entities/milestone.dart';

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
  final List<Insight> insights;
  final List<Milestone> milestones;

  const AnalyticsLoaded({
    required this.summaries,
    this.heatmapData,
    this.dayOfWeekStats,
    this.insights = const [],
    this.milestones = const [],
  });

  @override
  List<Object?> get props => [
    summaries,
    heatmapData,
    dayOfWeekStats,
    insights,
    milestones,
  ];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
