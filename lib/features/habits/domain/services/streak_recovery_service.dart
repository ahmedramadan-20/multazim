import '../entities/streak_repair.dart';

/// Service to manage streak recovery rules and prevent abuse.
class StreakRecoveryService {
  /// Maximum number of repairs allowed in a rolling 7-day window.
  static const int maxRepairsPerWeek = 1;

  /// Whether a new repair can be applied for the given [habitId].
  bool canRepair(
    String habitId,
    List<StreakRepair> existingRepairs,
    DateTime now,
  ) {
    // Check if there's already a repair for this habit in the last 7 days
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final recentRepairs = existingRepairs
        .where((r) => r.habitId == habitId && r.date.isAfter(sevenDaysAgo))
        .toList();

    return recentRepairs.length < maxRepairsPerWeek;
  }

  /// Finds the ideal date to repair if a streak was just broken.
  ///
  /// Usually this is the day before the first missing day.
  DateTime? suggestRepairDate(DateTime lastCompleted, DateTime now) {
    final diff = now.difference(lastCompleted).inDays;
    if (diff <= 1) return null; // Not broken or just today missing

    // Repair the first missing day
    return lastCompleted.add(const Duration(days: 1));
  }
}
