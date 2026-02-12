import 'package:uuid/uuid.dart';
import '../entities/milestone.dart';

/// Service to detect and generate milestones based on streak milestones.
class MilestoneGenerator {
  /// Possible milestone thresholds in days.
  static const List<int> thresholds = [7, 30, 100, 365];

  /// Checks if a streak reaching [newStreak] from [oldStreak] triggers a new milestone.
  ///
  /// Returns a [Milestone] if a threshold was crossed, otherwise null.
  Milestone? checkMilestone(
    String habitId,
    int oldStreak,
    int newStreak,
    DateTime now,
  ) {
    for (final threshold in thresholds) {
      if (oldStreak < threshold && newStreak >= threshold) {
        return Milestone(
          id: const Uuid().v4(),
          habitId: habitId,
          title: _getMilestoneTitle(threshold),
          days: threshold,
          reachedDate: now,
        );
      }
    }
    return null;
  }

  String _getMilestoneTitle(int days) {
    return switch (days) {
      7 => 'أسبوع من الالتزام',
      30 => 'شهر من الإنجاز',
      100 => '١٠٠ يوم من العطاء',
      365 => 'سنة من التغيير',
      _ => '$days يوم من الالتزام',
    };
  }
}
