import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:multazim/features/analytics/domain/entities/daily_summary.dart';
import '../../../../core/theme/app_colors.dart';

class StatisticsGrid extends StatefulWidget {
  final List<DailySummary> summaries;

  const StatisticsGrid({super.key, required this.summaries});

  @override
  State<StatisticsGrid> createState() => _StatisticsGridState();
}

class _StatisticsGridState extends State<StatisticsGrid> {
  late double _avgRate;
  late int _totalPerfectDays;
  late String _bestDayStr;
  late int _currentPerfectStreak;
  late bool _hasData;

  @override
  void initState() {
    super.initState();
    _calculateStats();
  }

  @override
  void didUpdateWidget(covariant StatisticsGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.summaries != oldWidget.summaries) {
      _calculateStats();
    }
  }

  void _calculateStats() {
    if (widget.summaries.isEmpty) {
      _hasData = false;
      _avgRate = 0;
      _totalPerfectDays = 0;
      _bestDayStr = '-';
      _currentPerfectStreak = 0;
      return;
    }

    final activeSummaries = widget.summaries
        .where((s) => s.totalScheduled > 0)
        .toList();

    if (activeSummaries.isEmpty) {
      _hasData = false;
      _avgRate = 0;
      _totalPerfectDays = 0;
      _bestDayStr = '-';
      _currentPerfectStreak = 0;
      return;
    }

    _hasData = true;

    // 1. Average completion rate — active days only
    final totalRate = activeSummaries.fold(
      0.0,
      (sum, s) => sum + s.completionRate,
    );
    _avgRate = totalRate / activeSummaries.length;

    // 2. Perfect days count
    _totalPerfectDays = activeSummaries.where((s) => s.isPerfectDay).length;

    // 3. Best weekday
    final perfectDaysByWeekday = <int, int>{};
    for (final s in activeSummaries) {
      if (s.isPerfectDay) {
        final wd = s.date.weekday;
        perfectDaysByWeekday[wd] = (perfectDaysByWeekday[wd] ?? 0) + 1;
      }
    }

    int? bestWeekday;
    int maxCount = -1;
    perfectDaysByWeekday.forEach((day, count) {
      if (count > maxCount) {
        maxCount = count;
        bestWeekday = day;
      }
    });

    _bestDayStr = bestWeekday != null ? _weekdayName(bestWeekday!) : '-';

    // 4. Perfect streak — walk backwards, skip today if in-progress
    final sorted = List.of(activeSummaries)
      ..sort((a, b) => b.date.compareTo(a.date));

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    _currentPerfectStreak = 0;
    for (final s in sorted) {
      final isToday = DateTime(
        s.date.year,
        s.date.month,
        s.date.day,
      ).isAtSameMomentAs(today);
      // Today is still in progress — don't break streak if incomplete
      if (isToday && !s.isPerfectDay) continue;

      if (s.isPerfectDay) {
        _currentPerfectStreak++;
      } else {
        break;
      }
    }
  }

  String _weekdayName(int weekday) {
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    if (weekday >= 1 && weekday <= 7) return days[weekday - 1];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasData) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              title: 'الإنجاز',
              value: '${(_avgRate * 100).toStringAsFixed(1)}%',
              icon: Icons.pie_chart,
              color: colorScheme.primary,
            ).animate().fadeIn(delay: 0.ms).slideX(begin: -0.1, end: 0),
            _StatCard(
              title: 'أيام مثالية',
              value: '$_totalPerfectDays',
              icon: Icons.star,
              color: AppColors.warning,
            ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0),
            _StatCard(
              title: 'الأفضل',
              value: _bestDayStr,
              icon: Icons.calendar_today,
              color: AppColors.success,
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
            _StatCard(
              title: 'تتابع مثالي',
              value: '$_currentPerfectStreak',
              icon: Icons.local_fire_department,
              color: AppColors.accent,
            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────
// STAT CARD
// ─────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
