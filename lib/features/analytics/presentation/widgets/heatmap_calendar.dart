import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

/// Heatmap calendar showing daily completion rates.
///
/// Converted to [StatefulWidget] to:
/// 1. Cache the date list (avoid creating ~91 DateTime objects per frame).
/// 2. Only play staggered entry animations once (not on every rebuild).
class HeatmapCalendar extends StatefulWidget {
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
  State<HeatmapCalendar> createState() => _HeatmapCalendarState();
}

class _HeatmapCalendarState extends State<HeatmapCalendar> {
  late List<DateTime?> _paddedDates;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _buildDates();
  }

  @override
  void didUpdateWidget(covariant HeatmapCalendar old) {
    super.didUpdateWidget(old);
    if (widget.endDate != old.endDate || widget.daysToShow != old.daysToShow) {
      _buildDates();
    }
  }

  void _buildDates() {
    final dates = <DateTime?>[];
    for (int i = widget.daysToShow - 1; i >= 0; i--) {
      final d = widget.endDate.subtract(Duration(days: i));
      dates.add(DateTime(d.year, d.month, d.day));
    }

    final firstWeekday = dates.first!.weekday % 7;
    _paddedDates = <DateTime?>[...List.filled(firstWeekday, null), ...dates];
  }

  @override
  Widget build(BuildContext context) {
    // Mark animated after the first frame completes.
    if (!_hasAnimated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _hasAnimated = true;
      });
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekday labels — Sunday first (Arabic convention)
        SizedBox(
          height: 140,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ح',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ), // Sunday
              Text(
                'ن',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ), // Monday
              Text(
                'ث',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ), // Tuesday
              Text(
                'ر',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ), // Wednesday
              Text(
                'خ',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ), // Thursday
              Text(
                'ج',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ), // Friday
              Text(
                'س',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
              itemCount: _paddedDates.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final date = _paddedDates[index];
                if (date == null) {
                  // Empty padding cell
                  return const SizedBox.shrink();
                }
                final value = widget.data[date] ?? 0.0;
                final cell = _HeatmapCell(date: date, value: value);

                if (!_hasAnimated) {
                  return cell
                      .animate(delay: (index * 5).ms)
                      .fadeIn(duration: 300.ms)
                      .scale(begin: const Offset(0.5, 0.5));
                }
                return cell;
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
    final primary = Theme.of(context).colorScheme.primary;
    final color = value > 0
        ? primary.withValues(alpha: (0.2 + (value * 0.8)).clamp(0.0, 1.0))
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
