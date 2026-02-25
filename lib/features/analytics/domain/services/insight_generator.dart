import '../entities/daily_summary.dart';
import '../entities/habit_analytics_snapshot.dart';
import '../entities/insight.dart';

class InsightGenerator {
  static const int _maxWarnings = 2; // never spam more than 2 warnings

  List<Insight> generate({
    required List<DailySummary> summaries,
    required List<HabitAnalyticsSnapshot> habitStats,
  }) {
    final insights = <Insight>[];

    // ── Global insights ───────────────────────────
    final trend = _globalTrend(summaries);
    if (trend != null) insights.add(trend);

    final rate = _globalCompletionRate(summaries);
    if (rate != null) insights.add(rate);

    // ── Per-habit insights ────────────────────────
    final warnings = <Insight>[];

    for (final stats in habitStats) {
      final streak = _streakMilestone(stats);
      if (streak != null) insights.add(streak);

      final warning = _failurePattern(stats);
      if (warning != null) warnings.add(warning);
    }

    // Only add the worst warnings — never spam one per habit
    warnings.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    insights.addAll(warnings.take(_maxWarnings));

    // Sort: high priority first
    insights.sort((a, b) => b.priority.index.compareTo(a.priority.index));

    return insights;
  }

  // ─────────────────────────────────────────────────
  // GLOBAL TREND
  // ─────────────────────────────────────────────────

  Insight? _globalTrend(List<DailySummary> summaries) {
    if (summaries.length < 14) return null;

    final sorted = List.of(summaries)..sort((a, b) => b.date.compareTo(a.date));
    final last7 = sorted.take(7).toList();
    final prev7 = sorted.skip(7).take(7).toList();

    final last7Rate =
        last7.map((e) => e.completionRate).reduce((a, b) => a + b) / 7;
    final prev7Rate =
        prev7.map((e) => e.completionRate).reduce((a, b) => a + b) / 7;

    final diff = last7Rate - prev7Rate;

    if (diff > 0.1) {
      final percent = (diff * 100).toStringAsFixed(0);
      return Insight(
        title: 'في تحسن! 📈',
        message:
            'أنت أكثر التزاماً بنسبة $percent% هذا الأسبوع مقارنة بالأسبوع الماضي. استمر!',
        type: InsightType.trend,
        scope: InsightScope.global,
        priority: InsightPriority.medium,
      );
    }

    if (diff < -0.15) {
      final percent = (diff.abs() * 100).toStringAsFixed(0);
      return Insight(
        title: 'انتبه! 📉',
        message:
            'التزامك انخفض بنسبة $percent% هذا الأسبوع. حاول العودة للمسار الصحيح.',
        type: InsightType.warning,
        scope: InsightScope.global,
        priority: InsightPriority.medium,
      );
    }

    return null;
  }

  // ─────────────────────────────────────────────────
  // GLOBAL COMPLETION RATE SUMMARY
  // ─────────────────────────────────────────────────

  Insight? _globalCompletionRate(List<DailySummary> summaries) {
    if (summaries.length < 7) return null;

    final sorted = List.of(summaries)..sort((a, b) => b.date.compareTo(a.date));
    final last7 = sorted.take(7).toList();
    final rate = last7.map((e) => e.completionRate).reduce((a, b) => a + b) / 7;
    final percent = (rate * 100).round();

    if (percent >= 80) {
      return Insight(
        title: 'أسبوع رائع! 🌟',
        message:
            'أكملت $percent% من عاداتك هذا الأسبوع. أنت على المسار الصحيح!',
        type: InsightType.general,
        scope: InsightScope.global,
        priority: InsightPriority.low,
      );
    }

    if (percent < 40 && percent > 0) {
      return Insight(
        title: 'هناك مجال للتحسن',
        message:
            'أكملت $percent% فقط من عاداتك هذا الأسبوع. ابدأ بعادة واحدة صغيرة اليوم.',
        type: InsightType.general,
        scope: InsightScope.global,
        priority: InsightPriority.low,
      );
    }

    return null;
  }

  // ─────────────────────────────────────────────────
  // STREAK MILESTONES
  // ─────────────────────────────────────────────────

  Insight? _streakMilestone(HabitAnalyticsSnapshot stats) {
    final streak = stats.streak;

    // One day away from breaking personal record
    if (streak.current > 0 &&
        streak.longest > 3 &&
        streak.current == streak.longest - 1) {
      return Insight(
        title: 'تنبيه رقم قياسي! 🔥',
        message:
            "يوم واحد فقط يفصلك عن كسر رقمك القياسي في '${stats.habitName}'!",
        type: InsightType.streakMilestone,
        scope: InsightScope.habitSpecific,
        priority: InsightPriority.high,
        relatedHabitId: stats.habitId,
      );
    }

    // Just hit a milestone number
    final milestones = [7, 14, 21, 30, 50, 100];
    if (milestones.contains(streak.current)) {
      return Insight(
        title: 'إنجاز جديد! 🏆',
        message:
            "وصلت إلى ${streak.current} يوماً متواصلاً في '${stats.habitName}'! رائع جداً!",
        type: InsightType.streakMilestone,
        scope: InsightScope.habitSpecific,
        priority: InsightPriority.high,
        relatedHabitId: stats.habitId,
      );
    }

    return null;
  }

  // ─────────────────────────────────────────────────
  // FAILURE PATTERN — strict thresholds
  // ─────────────────────────────────────────────────

  Insight? _failurePattern(HabitAnalyticsSnapshot stats) {
    if (stats.dayOfWeekCompletionRates.isEmpty) return null;

    // Need meaningful data — at least 4 weeks means each day should
    // have been attempted ~4 times. We use rate < 0.35 as the threshold
    // (failed more than 65% of the time on that day) AND the rate must
    // be significantly worse than the habit's average rate.
    final avgRate = stats.completionRateLast30Days;

    int? worstDay;
    double lowestRate = 1.0;

    stats.dayOfWeekCompletionRates.forEach((day, rate) {
      if (rate < lowestRate) {
        lowestRate = rate;
        worstDay = day;
      }
    });

    // Only fire if:
    // 1. Worst day rate is below 35%
    // 2. It's significantly worse than overall average (at least 30% gap)
    // 3. Overall average is decent (>40%) — otherwise the whole habit is struggling, not just one day
    final isSignificantPattern =
        worstDay != null &&
        lowestRate < 0.35 &&
        (avgRate - lowestRate) > 0.30 &&
        avgRate > 0.40;

    if (!isSignificantPattern) return null;

    final dayName = _dayName(worstDay!);
    return Insight(
      title: 'نمط أسبوعي ⚠️',
      message:
          "تواجه صعوبة في '${stats.habitName}' يوم $dayName باستمرار. جرب تغيير وقت تنفيذها ذلك اليوم.",
      type: InsightType.warning,
      scope: InsightScope.habitSpecific,
      priority: InsightPriority.medium,
      relatedHabitId: stats.habitId,
    );
  }

  String _dayName(int weekday) {
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
