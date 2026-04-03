import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

class DailyProgressSummary extends StatelessWidget {
  final double progress;
  final double totalCurrent;
  final double totalTarget;

  const DailyProgressSummary({
    super.key,
    required this.progress,
    required this.totalCurrent,
    required this.totalTarget,
  });

  String get _motivationalLabel {
    final pct = (progress * 100).toInt();
    if (pct == 0) return 'لنبدأ اليوم 💪';
    if (pct < 30) return 'بداية جيدة!';
    if (pct < 60) return 'استمر، أنت في المنتصف 🔥';
    if (pct < 100) return 'رائع، اقتربت من الهدف!';
    return 'أنجزت يومك كاملاً! 🎉';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isComplete = progress >= 1.0;
    final progressColor = isComplete ? AppColors.success : colorScheme.primary;
    final pct = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: progressColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: progressColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Motivational label ──────────
                Expanded(
                  child: Text(
                    _motivationalLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // ── Stats: X / Y وحدة ───────────
                Text(
                  '${totalCurrent.toInt()} / ${totalTarget.toInt()} وحدة',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),

                // ── Percentage pill ──────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Progress bar ─────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progress),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 7,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
    );
  }
}
