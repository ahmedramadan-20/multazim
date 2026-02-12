import '../entities/daily_summary.dart';
import '../entities/habit_analytics_snapshot.dart';
import '../entities/insight.dart';

class InsightGenerator {
  /// Generates a list of insights based on global and per-habit data.
  List<Insight> generate({
    required List<DailySummary> summaries,
    required List<HabitAnalyticsSnapshot> habitStats,
  }) {
    final insights = <Insight>[];

    // 1. Global Insights
    final globalTrend = _generateGlobalTrendInsight(summaries);
    if (globalTrend != null) insights.add(globalTrend);

    // 2. Habit-Specific Insights
    for (final stats in habitStats) {
      // Streak Milestones
      final streakInsight = _generateStreakMilestoneInsight(stats);
      if (streakInsight != null) insights.add(streakInsight);

      // Warning Patterns (Worst Day)
      final failurePattern = _generateFailurePatternInsight(stats);
      if (failurePattern != null) insights.add(failurePattern);
    }

    // Sort by priority (High first)
    insights.sort((a, b) => b.priority.index.compareTo(a.priority.index));

    return insights;
  }

  Insight? _generateGlobalTrendInsight(List<DailySummary> summaries) {
    if (summaries.length < 14) return null;

    final last7Days = summaries.reversed.take(7).toList();
    final previous7Days = summaries.reversed.skip(7).take(7).toList();

    if (last7Days.isEmpty || previous7Days.isEmpty) return null;

    final last7Rate =
        last7Days.map((e) => e.completionRate).reduce((a, b) => a + b) / 7;
    final prev7Rate =
        previous7Days.map((e) => e.completionRate).reduce((a, b) => a + b) / 7;

    if (last7Rate > prev7Rate + 0.1) {
      final percent = ((last7Rate - prev7Rate) * 100).toStringAsFixed(0);
      return Insight(
        title: 'في تحسن!',
        message:
            'أنت أكثر التزاماً بنسبة $percent% هذا الأسبوع مقارنة بالأسبوع الماضي. استمر!',
        type: InsightType.trend,
        scope: InsightScope.global,
        priority: InsightPriority.medium,
      );
    }

    return null;
  }

  Insight? _generateStreakMilestoneInsight(HabitAnalyticsSnapshot stats) {
    final streak = stats.streak;

    // Rule: 1 day away from longest streak
    if (streak.current > 0 &&
        streak.longest > 2 &&
        streak.current == streak.longest - 1) {
      return Insight(
        title: 'تنبيه رقم قياسي!',
        message:
            "أنت على بعد يوم واحد فقط من معادلة أطول سلسلة نجاح لـ '${stats.habitName}'!",
        type: InsightType.streakMilestone,
        scope: InsightScope.habitSpecific,
        priority: InsightPriority.high,
        relatedHabitId: stats.habitId,
      );
    }

    if (streak.current == streak.longest && streak.current > 0) {
      return Insight(
        title: 'رقم قياسي جديد!',
        message:
            "لقد حطمت رقمك القياسي لـ '${stats.habitName}'! أنت الآن في اليوم ${streak.current}!",
        type: InsightType.streakMilestone,
        scope: InsightScope.habitSpecific,
        priority: InsightPriority.high,
        relatedHabitId: stats.habitId,
      );
    }

    return null;
  }

  Insight? _generateFailurePatternInsight(HabitAnalyticsSnapshot stats) {
    if (stats.dayOfWeekCompletionRates.isEmpty) return null;

    // Find the worst day (lowest completion rate)
    // Only if total scheduled for that day is significant?
    // Repository doesn't give counts for DOW yet, just rates.
    // We assume the rate is meaningful.

    int? worstDay;
    double lowestRate = 1.0;

    stats.dayOfWeekCompletionRates.forEach((day, rate) {
      if (rate < lowestRate) {
        lowestRate = rate;
        worstDay = day;
      }
    });

    // If the worst day has < 50% completion
    if (worstDay != null && lowestRate < 0.5) {
      final dayName = _getDayName(worstDay!);
      return Insight(
        title: 'تم اكتشاف نمط',
        message:
            "غالباً ما تواجه صعوبة في '${stats.habitName}' يوم $dayName. حاول الاستعداد للأمر في الليلة السابقة!",
        type: InsightType.warning,
        scope: InsightScope.habitSpecific,
        priority: InsightPriority.medium,
        relatedHabitId: stats.habitId,
      );
    }

    return null;
  }

  String _getDayName(int weekday) {
    return switch (weekday) {
      1 => 'الاثنين',
      2 => 'الثلاثاء',
      3 => 'الأربعاء',
      4 => 'الخميس',
      5 => 'الجمعة',
      6 => 'السبت',
      7 => 'الأحد',
      _ => '',
    };
  }
}
