import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/habit_event.dart';
import '../../../../core/theme/app_colors.dart';

class HabitEventTile extends StatelessWidget {
  final HabitEvent event;
  final Color habitColor;

  static final _dayFormatter = DateFormat('d', 'ar');
  static final _monthFormatter = DateFormat('MMM', 'ar');

  const HabitEventTile({
    super.key,
    required this.event,
    required this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (event.status) {
      case HabitEventStatus.completed:
        statusColor = habitColor;
        statusIcon = Icons.check_circle;
        statusLabel = 'مكتمل';
      case HabitEventStatus.skipped:
        statusColor = AppColors.warning;
        statusIcon = Icons.skip_next;
        statusLabel = 'متخطى';
      case HabitEventStatus.failed:
        statusColor = colorScheme.error;
        statusIcon = Icons.cancel;
        statusLabel = 'فشل';
      case HabitEventStatus.missed:
        statusColor = colorScheme.error.withValues(alpha: 0.8);
        statusIcon = Icons.remove_circle_outline;
        statusLabel = 'فائت';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Date column
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Text(
                  _dayFormatter.format(event.date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _monthFormatter.format(event.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),

          // Timeline line
          Column(
            children: [
              Container(width: 1, height: 8, color: colorScheme.outlineVariant),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 1, height: 8, color: colorScheme.outlineVariant),
            ],
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                            fontSize: 13,
                          ),
                        ),
                        if (event.note != null && event.note!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            event.note!,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (event.failReason != null &&
                            event.failReason!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'السبب: ${event.failReason}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (event.countValue != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'القيمة: ${event.countValue}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
