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
    this.daysToShow = 91,
  });

  @override
  Widget build(BuildContext context) {
    // Build date list oldest → newest
    final dates = <DateTime?>[];
    for (int i = daysToShow - 1; i >= 0; i--) {
      final d = endDate.subtract(Duration(days: i));
      dates.add(DateTime(d.year, d.month, d.day));
    }

    // ─────────────────────────────────────────────────
    // FIX: Pad the start so the first date lands on
    // the correct weekday row.
    // Row order: Sunday(0), Monday(1)...Saturday(6)
    // DateTime.weekday: Mon=1 … Sun=7
    // Convert to 0-based Sunday-first: Sun=0, Mon=1...Sat=6
    // ─────────────────────────────────────────────────
    final firstDate = dates.first!;
    final firstWeekday = firstDate.weekday % 7; // Sun=0, Mon=1...Sat=6
    final paddedDates = <DateTime?>[
      ...List.filled(firstWeekday, null), // empty cells before first date
      ...dates,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekday labels — Sunday first (Arabic convention)
        const SizedBox(
          height: 140,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ح',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ), // Sunday
              Text(
                'ن',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ), // Monday
              Text(
                'ث',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ), // Tuesday
              Text(
                'ر',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ), // Wednesday
              Text(
                'خ',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ), // Thursday
              Text(
                'ج',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ), // Friday
              Text(
                'س',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ), // Saturday
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 140,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: paddedDates.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final date = paddedDates[index];
                if (date == null) {
                  // Empty padding cell
                  return const SizedBox.shrink();
                }
                final value = data[date] ?? 0.0;
                return _HeatmapCell(date: date, value: value);
              },
            ),
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
    final color = value > 0
        ? Colors.green.withValues(alpha: (0.2 + (value * 0.8)).clamp(0.0, 1.0))
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
