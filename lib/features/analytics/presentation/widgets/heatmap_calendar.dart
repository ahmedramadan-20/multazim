import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeatmapCalendar extends StatelessWidget {
  final Map<DateTime, double> data;
  final DateTime endDate;
  final int daysToShow;

  const HeatmapCalendar({
    super.key,
    required this.data,
    required this.endDate,
    this.daysToShow = 91, // ~3 months (13 weeks)
  });

  @override
  Widget build(BuildContext context) {
    // Generate dates
    final dates = <DateTime>[];
    for (int i = daysToShow - 1; i >= 0; i--) {
      final date = endDate.subtract(Duration(days: i));
      dates.add(DateTime(date.year, date.month, date.day));
    }

    // Grid: 7 rows (Mon-Sun), N columns
    // We want columns to represent weeks. Use column-major order if possible,
    // or just standard GridView with horizontal scroll?
    // GitHub style is horizontal scrolling, columns = weeks.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('خريطة الالتزام', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        SizedBox(
          height: 140, // Enough for 7 squares + spacing + labels
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 days per column
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final date = dates[index];
              final value = data[date] ?? 0.0;
              return _HeatmapCell(date: date, value: value);
            },
          ),
        ),
      ],
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  final DateTime date;
  final double value;

  const _HeatmapCell({required this.date, required this.value});

  @override
  Widget build(BuildContext context) {
    // Color intensity
    final color = value > 0
        ? Colors.green.withOpacity((0.2 + (value * 0.8)).clamp(0.0, 1.0))
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    return Tooltip(
      message: '${DateFormat.yMMMEd().format(date)}: ${(value * 100).toInt()}%',
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
