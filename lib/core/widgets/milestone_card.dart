import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MilestoneCard extends StatelessWidget {
  final dynamic milestone;
  final bool isArabic;

  const MilestoneCard({
    super.key,
    required this.milestone,
    this.isArabic = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            isArabic
                ? '${milestone.streakValue} يوم'
                : '${milestone.streakValue} Days',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Text(
            DateFormat(
              'd MMM',
              isArabic ? 'ar' : 'en',
            ).format(milestone.achievedAt),
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
