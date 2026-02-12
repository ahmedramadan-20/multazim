import 'package:multazim/features/analytics/domain/entities/daily_summary.dart';

abstract class AnalyticsRepository {
  /// aggregated daily summaries for a specific date range
  Future<List<DailySummary>> getSummaries(DateTime startDate, DateTime endDate);

  /// heatmap data for a specific habit (Date -> Completion Rate 0.0-1.0)
  Future<Map<DateTime, double>> getHeatmapData(String habitId);

  /// day of week stats for a specific habit (Weekday 1-7 -> Completion Rate 0.0-1.0)
  Future<Map<int, double>> getDayOfWeekStats(String habitId);
}
