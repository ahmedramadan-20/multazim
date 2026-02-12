import 'package:flutter/material.dart';
import 'package:multazim/features/analytics/domain/entities/daily_summary.dart';

class StatisticsGrid extends StatelessWidget {
  final List<DailySummary> summaries;

  const StatisticsGrid({super.key, required this.summaries});

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return const SizedBox.shrink();
    }

    // 1. Calculate Average Completion Rate
    final totalRate = summaries.fold(0.0, (sum, s) => sum + s.completionRate);
    final avgRate = totalRate / summaries.length;

    // 2. Calculate Best Day (Active)
    // Map<Weekday, Count> of perfect days
    final perfectDaysByWeekday = <int, int>{};
    int totalPerfectDays = 0;

    for (var s in summaries) {
      if (s.isPerfectDay) {
        totalPerfectDays++;
        final wd = s.date.weekday;
        perfectDaysByWeekday[wd] = (perfectDaysByWeekday[wd] ?? 0) + 1;
      }
    }

    // Find weekday with max perfect days
    int? bestWeekday;
    int maxCount = -1;
    perfectDaysByWeekday.forEach((day, count) {
      if (count > maxCount) {
        maxCount = count;
        bestWeekday = day;
      }
    });

    final bestDayStr = bestWeekday != null ? _weekdayName(bestWeekday!) : '-';

    // 3. Current Streak (Global) ??
    // This is hard to calculate from Aggregate summaries without knowing strictly if *all* habits were done.
    // 'isPerfectDay' streak?
    int currentPerfectStreak = 0;
    // Walk backwards from today/last entry
    final sorted = List.of(summaries)..sort((a, b) => b.date.compareTo(a.date));
    for (var s in sorted) {
      if (s.isPerfectDay) {
        currentPerfectStreak++;
      } else {
        break;
      }
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'معدل الإنجاز',
          value: '${(avgRate * 100).toStringAsFixed(1)}%',
          icon: Icons.pie_chart,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'أيام مثالية',
          value: '$totalPerfectDays',
          icon: Icons.star,
          color: Colors.amber,
        ),
        _StatCard(
          title: 'أفضل يوم',
          value: bestDayStr,
          icon: Icons.calendar_today,
          color: Colors.green,
        ),
        _StatCard(
          title: 'تتابع مثالي',
          value: '$currentPerfectStreak',
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
      ],
    );
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
}

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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
