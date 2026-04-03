enum ExportFormat { csv, excel, json }

enum ExportDateRange { last7Days, last30Days, last90Days, allTime, custom }

class ExportConfig {
  final ExportFormat format;
  final ExportDateRange dateRange;
  final DateTime? customStart;
  final DateTime? customEnd;
  final String? habitId; // null = all habits

  const ExportConfig({
    required this.format,
    required this.dateRange,
    this.customStart,
    this.customEnd,
    this.habitId,
  });

  DateTime get resolvedStart {
    if (dateRange == ExportDateRange.custom && customStart != null) {
      return customStart!;
    }
    final now = DateTime.now();
    return switch (dateRange) {
      ExportDateRange.last7Days => now.subtract(const Duration(days: 7)),
      ExportDateRange.last30Days => now.subtract(const Duration(days: 30)),
      ExportDateRange.last90Days => now.subtract(const Duration(days: 90)),
      ExportDateRange.allTime => DateTime(2020),
      ExportDateRange.custom => customStart ?? DateTime(2020),
    };
  }

  DateTime get resolvedEnd => customEnd ?? DateTime.now();
}
