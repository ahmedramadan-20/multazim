import 'package:flutter_test/flutter_test.dart';
import 'package:multazim/features/analytics/domain/entities/daily_summary.dart';

void main() {
  group('DailySummary', () {
    test('calculates totalMissed correctly', () {
      final summary = DailySummary(
        date: DateTime.now(),
        totalScheduled: 5,
        totalCompleted: 2,
        totalSkipped: 1,
        totalFailed: 1,
        completionRate: 0.4,
      );

      // 5 - 2 - 1 - 1 = 1 missed
      expect(summary.totalMissed, 1);
    });

    test('isPerfectDay returns true only for 100% completion', () {
      final perfect = DailySummary(
        date: DateTime.now(),
        totalScheduled: 5,
        totalCompleted: 5,
        totalSkipped: 0,
        totalFailed: 0,
        completionRate: 1.0,
      );
      expect(perfect.isPerfectDay, true);

      final imperfect = DailySummary(
        date: DateTime.now(),
        totalScheduled: 5,
        totalCompleted: 4,
        totalSkipped: 0,
        totalFailed: 1,
        completionRate: 0.8,
      );
      expect(imperfect.isPerfectDay, false);
    });

    test('isPerfectDay returns false if totalScheduled is 0', () {
      final empty = DailySummary(
        date: DateTime.now(),
        totalScheduled: 0,
        totalCompleted: 0,
        totalSkipped: 0,
        totalFailed: 0,
        completionRate: 0.0,
      );
      expect(empty.isPerfectDay, false);
    });
  });
}
