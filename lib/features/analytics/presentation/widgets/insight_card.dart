import 'package:flutter/material.dart';
import '../../domain/entities/insight.dart';

class InsightCard extends StatelessWidget {
  final Insight insight;

  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: _getBackgroundColor(colorScheme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _getBorderColor(colorScheme), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getIconColor(colorScheme).withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIcon(),
                color: _getIconColor(colorScheme),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    return switch (insight.type) {
      InsightType.streakMilestone => Icons.workspace_premium,
      InsightType.warning => Icons.warning_amber_rounded,
      InsightType.trend => Icons.trending_up_rounded,
      InsightType.general => Icons.lightbulb_outline_rounded,
    };
  }

  Color _getIconColor(ColorScheme colorScheme) {
    return switch (insight.type) {
      InsightType.streakMilestone => Colors.orange,
      InsightType.warning => colorScheme.error,
      InsightType.trend => Colors.blue,
      InsightType.general => Colors.purple,
    };
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    if (insight.priority == InsightPriority.high) {
      return _getIconColor(colorScheme).withAlpha(15);
    }
    return colorScheme.surfaceContainerHighest.withAlpha(50);
  }

  Color _getBorderColor(ColorScheme colorScheme) {
    if (insight.priority == InsightPriority.high) {
      return _getIconColor(colorScheme).withAlpha(50);
    }
    return colorScheme.outlineVariant.withAlpha(100);
  }
}
