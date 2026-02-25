import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/habit_event.dart';

class HabitMiniCalendar extends StatelessWidget {
  final List<HabitEvent> events;
  final Color habitColor;

  const HabitMiniCalendar({
    super.key,
    required this.events,
    required this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final eventMap = {
      for (final e in events)
        DateTime(e.date.year, e.date.month, e.date.day): e.status,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final date = today.subtract(Duration(days: 29 - index));
        final key = DateTime(date.year, date.month, date.day);
        final status = eventMap[key];

        Color cellColor;
        if (status == HabitEventStatus.completed) {
          cellColor = habitColor;
        } else if (status == HabitEventStatus.skipped) {
          cellColor = Colors.orange[300]!;
        } else if (status == HabitEventStatus.failed ||
            status == HabitEventStatus.missed) {
          cellColor = Colors.red[300]!;
        } else {
          cellColor = colorScheme.surfaceContainerHighest;
        }

        final isToday = DateUtils.isSameDay(date, today);

        return Tooltip(
          message: DateFormat('d MMM', 'ar').format(date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: BorderRadius.circular(4),
              border: isToday ? Border.all(color: habitColor, width: 2) : null,
            ),
          ),
        );
      },
    );
  }
}
