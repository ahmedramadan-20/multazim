import '../entities/habit.dart';
import '../entities/streak.dart';

/// Configuration for a streak algorithm, derived from
/// a habit's [StrictnessLevel].
class StreakConfig {
  /// Which algorithm to use.
  final StreakType type;

  /// Days allowed between completions without breaking
  /// the streak. Only meaningful for [StreakType.flexible].
  final int graceDays;

  /// Size of the rolling window in days.
  /// Only meaningful for [StreakType.consistency].
  final int windowSize;

  /// Minimum completions required within [windowSize].
  /// Only meaningful for [StreakType.consistency].
  final int minCompletions;

  const StreakConfig({
    required this.type,
    this.graceDays = 0,
    this.windowSize = 7,
    this.minCompletions = 4,
  });
}

/// Maps a habit's [StrictnessLevel] to the appropriate
/// [StreakConfig] that drives the streak calculation.
class StreakMapper {
  StreakMapper._();

  /// Returns the [StreakConfig] for the given [level].
  ///
  /// | StrictnessLevel | StreakType   | Grace | Window |
  /// |-----------------|-------------|-------|--------|
  /// | high            | perfect     | 0     | —      |
  /// | medium          | flexible    | 1     | —      |
  /// | low             | consistency | —     | 7 (4+) |
  static StreakConfig fromStrictness(StrictnessLevel level) {
    return switch (level) {
      StrictnessLevel.high => const StreakConfig(
        type: StreakType.perfect,
        graceDays: 0,
      ),
      StrictnessLevel.medium => const StreakConfig(
        type: StreakType.flexible,
        graceDays: 1,
      ),
      StrictnessLevel.low => const StreakConfig(
        type: StreakType.consistency,
        windowSize: 7,
        minCompletions: 4,
      ),
    };
  }
}
