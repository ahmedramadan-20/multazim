import '../entities/habit.dart';
import '../entities/habit_event.dart';
import '../entities/streak.dart';
import 'streak_mapper.dart';

/// Pure-Dart domain service that calculates the streak state
/// for a habit based on its events and strictness level.
///
/// Three algorithms are supported:
/// - **Perfect** (high): consecutive completed days, no misses.
/// - **Flexible** (medium): allows grace days between completions.
/// - **Consistency** (low): rolling 7-day window, ≥4 completions.
class StreakCalculationService {
  /// Calculates the [StreakState] for a [habit] given its
  /// historical [events].
  StreakState calculate({
    required Habit habit,
    required List<HabitEvent> events,
  }) {
    final config = StreakMapper.fromStrictness(habit.strictness);

    // Filter to completed events only, sorted newest-first
    final completed =
        events.where((e) => e.status == HabitEventStatus.completed).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    if (completed.isEmpty) {
      return StreakState.empty(config.type);
    }

    return switch (config.type) {
      StreakType.perfect => _calculatePerfect(completed, config),
      StreakType.flexible => _calculateFlexible(completed, config),
      StreakType.consistency => _calculateConsistency(completed, config, habit),
    };
  }

  /// **Perfect streak**: count consecutive days backwards from
  /// today. Any gap > 0 days breaks the streak.
  StreakState _calculatePerfect(
    List<HabitEvent> completed,
    StreakConfig config,
  ) {
    final today = _dateOnly(DateTime.now());
    int current = 0;
    int longest = 0;
    int tempStreak = 0;

    // Walk backwards from today
    var checkDate = today;
    int eventIdx = 0;

    // Allow today to be not-yet-completed (check yesterday too)
    final latestDate = _dateOnly(completed.first.date);
    if (latestDate != today) {
      // If the latest completion is yesterday, start from
      // yesterday
      final yesterday = today.subtract(const Duration(days: 1));
      if (latestDate == yesterday) {
        checkDate = yesterday;
      } else {
        // Streak is broken — latest completion is older
        return _buildState(current: 0, completed: completed, config: config);
      }
    }

    // Count consecutive days
    while (eventIdx < completed.length) {
      final eventDate = _dateOnly(completed[eventIdx].date);

      if (eventDate == checkDate) {
        tempStreak++;
        // Skip duplicate events on the same day
        while (eventIdx < completed.length &&
            _dateOnly(completed[eventIdx].date) == checkDate) {
          eventIdx++;
        }
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (eventDate.isBefore(checkDate)) {
        // Gap found — streak broken at this point
        break;
      } else {
        eventIdx++;
      }
    }

    current = tempStreak;
    longest = _findLongestPerfect(completed);
    if (current > longest) longest = current;

    return StreakState(
      currentStreak: current,
      longestStreak: longest,
      type: config.type,
      lastCompletedDate: completed.first.date,
      isActive: current > 0,
    );
  }

  /// **Flexible streak**: like perfect but tolerates up to
  /// [StreakConfig.graceDays] gap between completions.
  StreakState _calculateFlexible(
    List<HabitEvent> completed,
    StreakConfig config,
  ) {
    final today = _dateOnly(DateTime.now());
    int current = 0;

    final latestDate = _dateOnly(completed.first.date);
    final daysSinceLast = today.difference(latestDate).inDays;

    // If too many days have passed, streak is broken
    if (daysSinceLast > config.graceDays + 1) {
      return _buildState(current: 0, completed: completed, config: config);
    }

    // Count streak with grace tolerance
    current = 1; // The latest completion counts
    for (int i = 1; i < completed.length; i++) {
      final prev = _dateOnly(completed[i - 1].date);
      final curr = _dateOnly(completed[i].date);
      final gap = prev.difference(curr).inDays;

      if (gap <= config.graceDays + 1) {
        current++;
      } else {
        break; // Gap too large
      }
    }

    final longest = _findLongestFlexible(completed, config);

    return StreakState(
      currentStreak: current,
      longestStreak: current > longest ? current : longest,
      type: config.type,
      lastCompletedDate: completed.first.date,
      isActive: current > 0,
    );
  }

  /// **Consistency streak**: counts how many consecutive
  /// 7-day windows have ≥ [StreakConfig.minCompletions]
  /// completions, working backwards from the current window.
  StreakState _calculateConsistency(
    List<HabitEvent> completed,
    StreakConfig config,
    Habit habit,
  ) {
    final today = _dateOnly(DateTime.now());
    final windowSize = config.windowSize;
    final minRequired = config.minCompletions;

    int current = 0;
    int longest = 0;
    int tempStreak = 0;

    // Work backwards in windows of `windowSize` days
    var windowEnd = today;
    var windowStart = windowEnd.subtract(Duration(days: windowSize - 1));

    while (windowStart.isAfter(
          habit.startDate.subtract(Duration(days: windowSize)),
        ) ||
        windowStart == _dateOnly(habit.startDate)) {
      // Count completions in this window
      final count = completed.where((e) {
        final d = _dateOnly(e.date);
        return !d.isBefore(windowStart) && !d.isAfter(windowEnd);
      }).length;

      if (count >= minRequired) {
        tempStreak++;
      } else {
        if (tempStreak > longest) longest = tempStreak;
        if (current == 0 && tempStreak > 0) {
          current = tempStreak;
        } else if (current == 0 && tempStreak == 0) {
          // First window didn't meet threshold — streak is 0
          current = 0;
        }
        if (current > 0) break; // We found the current streak
        tempStreak = 0;
      }

      // Slide the window back
      windowEnd = windowStart.subtract(const Duration(days: 1));
      windowStart = windowEnd.subtract(Duration(days: windowSize - 1));
    }

    // Handle case where we never broke
    if (current == 0) current = tempStreak;
    if (tempStreak > longest) longest = tempStreak;
    if (current > longest) longest = current;

    return StreakState(
      currentStreak: current,
      longestStreak: longest,
      type: config.type,
      lastCompletedDate: completed.first.date,
      isActive: current > 0,
    );
  }

  // ─── Helpers ───────────────────────────────────────────

  /// Strips time component, keeping only year/month/day.
  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Finds the longest perfect streak in all events.
  int _findLongestPerfect(List<HabitEvent> completed) {
    if (completed.isEmpty) return 0;
    int longest = 1;
    int current = 1;

    for (int i = 1; i < completed.length; i++) {
      final prev = _dateOnly(completed[i - 1].date);
      final curr = _dateOnly(completed[i].date);
      final gap = prev.difference(curr).inDays;

      if (gap == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (gap == 0) {
        // Same day — skip duplicate
        continue;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  /// Finds the longest flexible streak in all events.
  int _findLongestFlexible(List<HabitEvent> completed, StreakConfig config) {
    if (completed.isEmpty) return 0;
    int longest = 1;
    int current = 1;
    for (int i = 1; i < completed.length; i++) {
      final prev = _dateOnly(completed[i - 1].date);
      final curr = _dateOnly(completed[i].date);
      final gap = prev.difference(curr).inDays;

      if (gap <= config.graceDays + 1 && gap > 0) {
        current++;
        if (current > longest) longest = current;
      } else if (gap == 0) {
        continue;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  /// Builds a [StreakState] when the current streak is known
  /// to be zero but we still need longest.
  StreakState _buildState({
    required int current,
    required List<HabitEvent> completed,
    required StreakConfig config,
  }) {
    final longest = config.type == StreakType.perfect
        ? _findLongestPerfect(completed)
        : _findLongestFlexible(completed, config);

    return StreakState(
      currentStreak: current,
      longestStreak: longest,
      type: config.type,
      lastCompletedDate: completed.isNotEmpty ? completed.first.date : null,
      isActive: current > 0,
    );
  }
}
