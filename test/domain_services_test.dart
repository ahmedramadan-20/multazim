import 'package:flutter_test/flutter_test.dart';
import 'package:multazim/features/analytics/domain/entities/daily_summary.dart';
import 'package:multazim/features/analytics/domain/entities/habit_analytics_snapshot.dart';
import 'package:multazim/features/analytics/domain/entities/insight.dart';
import 'package:multazim/features/analytics/domain/services/insight_generator.dart';
import 'package:multazim/features/habits/domain/entities/habit.dart';
import 'package:multazim/features/habits/domain/entities/habit_event.dart';
import 'package:multazim/features/habits/domain/entities/streak.dart';
import 'package:multazim/features/habits/domain/entities/streak_repair.dart';
import 'package:multazim/features/habits/domain/services/streak_calculation_service.dart';
import 'package:multazim/features/habits/domain/services/streak_service.dart';
import 'package:multazim/features/habits/domain/services/streak_recovery_service.dart';
import 'package:multazim/features/habits/domain/services/weekly_progress_service.dart';

// ─────────────────────────────────────────────────
// TEST HELPERS
// ─────────────────────────────────────────────────

/// Returns a date relative to today. e.g. daysAgo(0) = today
DateTime daysAgo(int days) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).subtract(Duration(days: days));
}

/// Creates a completed HabitEvent for the given habit on the given date
HabitEvent completedEvent(String habitId, DateTime date, {String? id}) {
  return HabitEvent(
    id: id ?? '${habitId}_${date.millisecondsSinceEpoch}',
    habitId: habitId,
    date: date,
    status: HabitEventStatus.completed,
    createdAt: date,
  );
}

/// Creates a skipped HabitEvent
HabitEvent skippedEvent(String habitId, DateTime date) {
  return HabitEvent(
    id: '${habitId}_skip_${date.millisecondsSinceEpoch}',
    habitId: habitId,
    date: date,
    status: HabitEventStatus.skipped,
    createdAt: date,
  );
}

/// Creates a minimal Habit with given strictness
Habit makeHabit({
  String id = 'h1',
  StrictnessLevel strictness = StrictnessLevel.high,
  DateTime? startDate,
}) {
  return Habit(
    id: id,
    name: 'Test Habit',
    icon: '📝',
    color: '0xFF4F46E5',
    category: HabitCategory.other,
    schedule: const HabitSchedule.daily(),
    goal: const HabitGoal.binary(),
    difficulty: 3,
    strictness: strictness,
    startDate: startDate ?? daysAgo(60),
    createdAt: daysAgo(60),
  );
}

/// Creates a DailySummary with given completionRate
DailySummary makeSummary(DateTime date, double completionRate) {
  final total = 5;
  final completed = (completionRate * total).round();
  return DailySummary(
    date: date,
    totalScheduled: total,
    totalCompleted: completed,
    totalSkipped: 0,
    totalFailed: total - completed,
    completionRate: completionRate,
  );
}

// ─────────────────────────────────────────────────
// STREAK CALCULATION SERVICE TESTS
// ─────────────────────────────────────────────────

void main() {
  final calc = StreakCalculationService();

  group('StreakCalculationService — Perfect (high strictness)', () {
    test('empty events returns empty streak', () {
      final habit = makeHabit(strictness: StrictnessLevel.high);
      final result = calc.calculate(habit: habit, events: []);
      expect(result.current, 0);
      expect(result.longest, 0);
      expect(result.isActive, false);
    });

    test('single completion today gives streak of 1', () {
      final habit = makeHabit(strictness: StrictnessLevel.high);
      final result = calc.calculate(
        habit: habit,
        events: [completedEvent('h1', daysAgo(0))],
      );
      expect(result.current, 1);
      expect(result.isActive, true);
    });

    test('3 consecutive days gives streak of 3', () {
      final habit = makeHabit(strictness: StrictnessLevel.high);
      final result = calc.calculate(
        habit: habit,
        events: [
          completedEvent('h1', daysAgo(0)),
          completedEvent('h1', daysAgo(1)),
          completedEvent('h1', daysAgo(2)),
        ],
      );
      expect(result.current, 3);
      expect(result.isActive, true);
    });

    test('gap of 1 day breaks perfect streak', () {
      final habit = makeHabit(strictness: StrictnessLevel.high);
      final result = calc.calculate(
        habit: habit,
        events: [
          completedEvent('h1', daysAgo(0)),
          // daysAgo(1) missing — gap!
          completedEvent('h1', daysAgo(2)),
          completedEvent('h1', daysAgo(3)),
        ],
      );
      expect(result.current, 1); // only today counts
      expect(result.longest, 2); // daysAgo(2) + daysAgo(3)
    });

    test('completed yesterday (not today) still counts as active', () {
      final habit = makeHabit(strictness: StrictnessLevel.high);
      final result = calc.calculate(
        habit: habit,
        events: [
          completedEvent('h1', daysAgo(1)),
          completedEvent('h1', daysAgo(2)),
          completedEvent('h1', daysAgo(3)),
        ],
      );
      expect(result.current, 3);
      expect(result.isActive, true);
    });

    test('completion 2 days ago breaks streak (not yesterday or today)', () {
      final habit = makeHabit(strictness: StrictnessLevel.high);
      final result = calc.calculate(
        habit: habit,
        events: [completedEvent('h1', daysAgo(2))],
      );
      expect(result.current, 0);
      expect(result.isActive, false);
    });

    test('duplicate events on same day only count once', () {
      final habit = makeHabit(strictness: StrictnessLevel.high);
      final result = calc.calculate(
        habit: habit,
        events: [
          completedEvent('h1', daysAgo(0), id: 'e1'),
          completedEvent('h1', daysAgo(0), id: 'e2'), // duplicate same day
          completedEvent('h1', daysAgo(1)),
        ],
      );
      expect(result.current, 2);
    });

    test('longest is preserved even when current streak is broken', () {
      final habit = makeHabit(strictness: StrictnessLevel.high);
      final result = calc.calculate(
        habit: habit,
        events: [
          // Old 5-day streak
          completedEvent('h1', daysAgo(10)),
          completedEvent('h1', daysAgo(11)),
          completedEvent('h1', daysAgo(12)),
          completedEvent('h1', daysAgo(13)),
          completedEvent('h1', daysAgo(14)),
          // Gap — then 1 day today
          completedEvent('h1', daysAgo(0)),
        ],
      );
      expect(result.current, 1);
      expect(result.longest, 5);
    });

    test('skipped events are ignored in streak calculation', () {
      final habit = makeHabit(strictness: StrictnessLevel.high);
      final result = calc.calculate(
        habit: habit,
        events: [
          completedEvent('h1', daysAgo(0)),
          skippedEvent('h1', daysAgo(1)), // skipped should not count
          completedEvent('h1', daysAgo(2)),
        ],
      );
      // skipped on day 1 breaks the perfect streak
      expect(result.current, 1);
    });
  });

  // ─────────────────────────────────────────────────

  group('StreakCalculationService — Flexible (medium strictness)', () {
    test('1 grace day — missing one day does not break streak', () {
      final habit = makeHabit(strictness: StrictnessLevel.medium);
      final result = calc.calculate(
        habit: habit,
        events: [
          completedEvent('h1', daysAgo(0)),
          // daysAgo(1) missing — within grace
          completedEvent('h1', daysAgo(2)),
          completedEvent('h1', daysAgo(3)),
        ],
      );
      expect(result.current, 3);
      expect(result.isActive, true);
    });

    test('2 consecutive missing days breaks flexible streak (grace=1)', () {
      final habit = makeHabit(strictness: StrictnessLevel.medium);
      final result = calc.calculate(
        habit: habit,
        events: [
          completedEvent('h1', daysAgo(0)),
          // daysAgo(1) and daysAgo(2) both missing — exceeds grace
          completedEvent('h1', daysAgo(3)),
        ],
      );
      expect(result.current, 1);
    });

    test('streak broken if latest event is 3+ days ago', () {
      final habit = makeHabit(strictness: StrictnessLevel.medium);
      final result = calc.calculate(
        habit: habit,
        events: [completedEvent('h1', daysAgo(3))],
      );
      expect(result.current, 0);
      expect(result.isActive, false);
    });

    test('yesterday completion still active with grace=1', () {
      final habit = makeHabit(strictness: StrictnessLevel.medium);
      final result = calc.calculate(
        habit: habit,
        events: [
          completedEvent('h1', daysAgo(1)),
          completedEvent('h1', daysAgo(2)),
        ],
      );
      expect(result.current, 2);
      expect(result.isActive, true);
    });
  });

  // ─────────────────────────────────────────────────

  group('StreakCalculationService — Consistency (low strictness)', () {
    test('4+ completions in 7 days gives streak of 1', () {
      final habit = makeHabit(strictness: StrictnessLevel.low);
      final result = calc.calculate(
        habit: habit,
        events: [
          completedEvent('h1', daysAgo(0)),
          completedEvent('h1', daysAgo(1)),
          completedEvent('h1', daysAgo(3)),
          completedEvent('h1', daysAgo(5)),
        ],
      );
      expect(result.current, greaterThanOrEqualTo(1));
      expect(result.isActive, true);
    });

    test('fewer than 4 completions in window gives 0 streak', () {
      final habit = makeHabit(strictness: StrictnessLevel.low);
      final result = calc.calculate(
        habit: habit,
        events: [
          completedEvent('h1', daysAgo(0)),
          completedEvent('h1', daysAgo(2)),
          completedEvent('h1', daysAgo(5)),
          // only 3 — below threshold
        ],
      );
      expect(result.current, 0);
    });

    test('empty events returns 0', () {
      final habit = makeHabit(strictness: StrictnessLevel.low);
      final result = calc.calculate(habit: habit, events: []);
      expect(result.current, 0);
      expect(result.isActive, false);
    });
  });

  // ─────────────────────────────────────────────────
  // STREAK SERVICE TESTS (with repairs)
  // ─────────────────────────────────────────────────

  group('StreakService — streak repairs', () {
    final service = StreakService(StreakCalculationService());

    test('repair bridges a gap and preserves streak', () {
      final habit = makeHabit(strictness: StrictnessLevel.high);

      // Without repair: today + daysAgo(2) → streak=1 (gap at daysAgo(1))
      // With repair on daysAgo(1): streak should be 3
      final repair = StreakRepair(
        id: 'r1',
        habitId: 'h1',
        date: daysAgo(1),
        reason: 'مرضت',
        createdAt: DateTime.now(),
      );

      final result = service.calculateStreak(
        habit,
        [completedEvent('h1', daysAgo(0)), completedEvent('h1', daysAgo(2))],
        [repair],
      );

      expect(result.current, 3);
      expect(result.isActive, true);
    });

    test('no repairs — same as direct calculation', () {
      final habit = makeHabit(strictness: StrictnessLevel.high);
      final events = [
        completedEvent('h1', daysAgo(0)),
        completedEvent('h1', daysAgo(1)),
      ];

      final withRepairs = service.calculateStreak(habit, events, []);
      final direct = StreakCalculationService().calculate(
        habit: habit,
        events: events,
      );

      expect(withRepairs.current, direct.current);
      expect(withRepairs.longest, direct.longest);
    });

    test('repair for different habit does not affect this habit', () {
      final habit = makeHabit(id: 'h1', strictness: StrictnessLevel.high);

      final repair = StreakRepair(
        id: 'r1',
        habitId: 'h2', // different habit
        date: daysAgo(1),
        reason: 'test',
        createdAt: DateTime.now(),
      );

      final result = service.calculateStreak(
        habit,
        [
          completedEvent('h1', daysAgo(0)),
          completedEvent('h1', daysAgo(2)), // gap at daysAgo(1)
        ],
        [repair],
      );

      // Gap is NOT bridged because repair belongs to another habit
      expect(result.current, 1);
      expect(result.longest, 1);
      expect(result.isActive, true);
    });
  });

  // ─────────────────────────────────────────────────
  // STREAK RECOVERY SERVICE TESTS
  // ─────────────────────────────────────────────────

  group('StreakRecoveryService', () {
    final service = StreakRecoveryService();
    const habitId = 'h1';

    group('canRepair', () {
      test('can repair when no previous repairs', () {
        expect(service.canRepair(habitId, [], DateTime.now()), true);
      });

      test('cannot repair if already repaired within 7 days', () {
        final repairs = [
          StreakRepair(
            id: 'r1',
            habitId: habitId,
            date: daysAgo(3),
            reason: 'test',
            createdAt: daysAgo(3),
          ),
        ];
        expect(service.canRepair(habitId, repairs, DateTime.now()), false);
      });

      test('can repair if last repair was more than 7 days ago', () {
        final repairs = [
          StreakRepair(
            id: 'r1',
            habitId: habitId,
            date: daysAgo(8),
            reason: 'test',
            createdAt: daysAgo(8),
          ),
        ];
        expect(service.canRepair(habitId, repairs, DateTime.now()), true);
      });

      test('repair for different habit does not block this habit', () {
        final repairs = [
          StreakRepair(
            id: 'r1',
            habitId: 'h2', // different habit
            date: daysAgo(1),
            reason: 'test',
            createdAt: daysAgo(1),
          ),
        ];
        expect(service.canRepair(habitId, repairs, DateTime.now()), true);
      });

      test('repair 6 days ago is still within window (cannot repair)', () {
        // canRepair uses isAfter(sevenDaysAgo) — exactly 7 days is NOT after,
        // so daysAgo(7) is considered outside the window.
        // Use daysAgo(6) to reliably test the within-window case.
        final now = DateTime.now();
        final repairs = [
          StreakRepair(
            id: 'r1',
            habitId: habitId,
            date: daysAgo(6),
            reason: 'test',
            createdAt: daysAgo(6),
          ),
        ];
        expect(service.canRepair(habitId, repairs, now), false);
      });
    });

    group('suggestRepairDate', () {
      test('returns null if streak not broken (diff <= 1)', () {
        final now = DateTime.now();
        final lastCompleted = daysAgo(1);
        expect(service.suggestRepairDate(lastCompleted, now), null);
      });

      test('returns null if completed today', () {
        final now = DateTime.now();
        expect(service.suggestRepairDate(now, now), null);
      });

      test('returns day after lastCompleted if gap is 2 days', () {
        final now = DateTime.now();
        final lastCompleted = daysAgo(2);
        final result = service.suggestRepairDate(lastCompleted, now);
        final expected = DateTime(
          lastCompleted.year,
          lastCompleted.month,
          lastCompleted.day + 1,
        );
        expect(result?.day, expected.day);
        expect(result?.month, expected.month);
      });

      test('suggests first missing day for large gap', () {
        final now = DateTime.now();
        final lastCompleted = daysAgo(5);
        final result = service.suggestRepairDate(lastCompleted, now);
        // Should suggest the day after lastCompleted
        expect(
          result,
          DateTime(
            lastCompleted.year,
            lastCompleted.month,
            lastCompleted.day,
          ).add(const Duration(days: 1)),
        );
      });
    });
  });

  // ─────────────────────────────────────────────────
  // WEEKLY PROGRESS SERVICE TESTS
  // ─────────────────────────────────────────────────

  group('WeeklyProgressService', () {
    final service = WeeklyProgressService();

    test('daily habit — target is 7', () {
      final habit = makeHabit();
      final progress = service.getProgress(habit, [], DateTime.now());
      expect(progress.target, 7);
    });

    test('timesPerWeek habit — target matches schedule', () {
      final habit = Habit(
        id: 'h1',
        name: 'test',
        icon: '📝',
        color: '0xFF000000',
        category: HabitCategory.other,
        schedule: const HabitSchedule.timesPerWeek(3),
        goal: const HabitGoal.binary(),
        difficulty: 1,
        strictness: StrictnessLevel.medium,
        startDate: daysAgo(30),
        createdAt: daysAgo(30),
      );
      final progress = service.getProgress(habit, [], DateTime.now());
      expect(progress.target, 3);
    });

    test('customDays habit — target matches number of days', () {
      final habit = Habit(
        id: 'h1',
        name: 'test',
        icon: '📝',
        color: '0xFF000000',
        category: HabitCategory.other,
        schedule: const HabitSchedule.custom([1, 3, 5]), // Mon, Wed, Fri
        goal: const HabitGoal.binary(),
        difficulty: 1,
        strictness: StrictnessLevel.medium,
        startDate: daysAgo(30),
        createdAt: daysAgo(30),
      );
      final progress = service.getProgress(habit, [], DateTime.now());
      expect(progress.target, 3);
    });

    test('no events in week — current is 0', () {
      final habit = makeHabit();
      final progress = service.getProgress(habit, [], DateTime.now());
      expect(progress.current, 0);
    });

    test('completed event today counts toward current week', () {
      final habit = makeHabit();
      final events = [completedEvent('h1', daysAgo(0))];
      final progress = service.getProgress(habit, events, DateTime.now());
      expect(progress.current, 1);
    });

    test('skipped events do not count toward progress', () {
      final habit = makeHabit();
      final events = [
        completedEvent('h1', daysAgo(0)),
        skippedEvent('h1', daysAgo(1)),
      ];
      final progress = service.getProgress(habit, events, DateTime.now());
      expect(progress.current, 1); // only completed counts
    });

    test('duplicate events on same day count as 1', () {
      final habit = makeHabit();
      final events = [
        completedEvent('h1', daysAgo(0), id: 'e1'),
        completedEvent('h1', daysAgo(0), id: 'e2'),
      ];
      final progress = service.getProgress(habit, events, DateTime.now());
      expect(progress.current, 1);
    });

    test('events from other habits are not counted', () {
      final habit = makeHabit(id: 'h1');
      final events = [
        completedEvent('h2', daysAgo(0)), // different habit
      ];
      final progress = service.getProgress(habit, events, DateTime.now());
      expect(progress.current, 0);
    });

    test('events from previous week do not count', () {
      final habit = makeHabit();
      // Find start of current week and go before it
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final lastWeek = startOfWeek.subtract(const Duration(days: 1));

      final events = [completedEvent('h1', lastWeek)];
      final progress = service.getProgress(habit, events, now);
      expect(progress.current, 0);
    });
  });

  // ─────────────────────────────────────────────────
  // INSIGHT GENERATOR TESTS
  // ─────────────────────────────────────────────────

  group('InsightGenerator', () {
    final generator = InsightGenerator();

    // ── Global Trend ─────────────────────────────

    group('_globalTrend', () {
      test('returns null if fewer than 14 summaries', () {
        final summaries = List.generate(
          13,
          (i) => makeSummary(daysAgo(i), 0.8),
        );
        final insights = generator.generate(
          summaries: summaries,
          habitStats: [],
        );
        final trends = insights
            .where((i) => i.type == InsightType.trend)
            .toList();
        expect(trends, isEmpty);
      });

      test('positive trend insight when last 7 days > prev 7 by 10%+', () {
        final summaries = [
          // Last 7 days — high completion
          ...List.generate(7, (i) => makeSummary(daysAgo(i), 0.9)),
          // Prev 7 days — low completion
          ...List.generate(7, (i) => makeSummary(daysAgo(i + 7), 0.5)),
        ];
        final insights = generator.generate(
          summaries: summaries,
          habitStats: [],
        );
        final trends = insights
            .where((i) => i.type == InsightType.trend)
            .toList();
        expect(trends, isNotEmpty);
        expect(trends.first.title, contains('تحسن'));
      });

      test('warning trend when last 7 days < prev 7 by 15%+', () {
        final summaries = [
          // Last 7 days — low
          ...List.generate(7, (i) => makeSummary(daysAgo(i), 0.3)),
          // Prev 7 days — high
          ...List.generate(7, (i) => makeSummary(daysAgo(i + 7), 0.8)),
        ];
        final insights = generator.generate(
          summaries: summaries,
          habitStats: [],
        );
        final warnings = insights
            .where(
              (i) =>
                  i.type == InsightType.warning &&
                  i.scope == InsightScope.global,
            )
            .toList();
        expect(warnings, isNotEmpty);
      });

      test('no trend insight if difference is small (< 10%)', () {
        final summaries = [
          ...List.generate(7, (i) => makeSummary(daysAgo(i), 0.75)),
          ...List.generate(7, (i) => makeSummary(daysAgo(i + 7), 0.70)),
        ];
        final insights = generator.generate(
          summaries: summaries,
          habitStats: [],
        );
        final trends = insights
            .where((i) => i.type == InsightType.trend)
            .toList();
        expect(trends, isEmpty);
      });
    });

    // ── Global Completion Rate ────────────────────

    group('_globalCompletionRate', () {
      test('returns null if fewer than 7 summaries', () {
        final summaries = List.generate(6, (i) => makeSummary(daysAgo(i), 0.9));
        final insights = generator.generate(
          summaries: summaries,
          habitStats: [],
        );
        expect(insights, isEmpty);
      });

      test('positive summary when rate >= 80%', () {
        final summaries = List.generate(
          7,
          (i) => makeSummary(daysAgo(i), 0.85),
        );
        final insights = generator.generate(
          summaries: summaries,
          habitStats: [],
        );
        final generals = insights
            .where((i) => i.type == InsightType.general)
            .toList();
        expect(generals, isNotEmpty);
        expect(generals.first.title, contains('رائع'));
      });

      test('encouragement summary when rate < 40%', () {
        final summaries = List.generate(7, (i) => makeSummary(daysAgo(i), 0.3));
        final insights = generator.generate(
          summaries: summaries,
          habitStats: [],
        );
        final generals = insights
            .where((i) => i.type == InsightType.general)
            .toList();
        expect(generals, isNotEmpty);
        expect(
          generals.first.message,
          contains('ابدأ'),
        ); // matches 'ابدأ بعادة واحدة صغيرة اليوم'
      });

      test('no summary for 0% rate (all zeros ignored)', () {
        final summaries = List.generate(7, (i) => makeSummary(daysAgo(i), 0.0));
        final insights = generator.generate(
          summaries: summaries,
          habitStats: [],
        );
        final generals = insights
            .where(
              (i) =>
                  i.type == InsightType.general &&
                  i.scope == InsightScope.global,
            )
            .toList();
        expect(generals, isEmpty);
      });
    });

    // ── Streak Milestones ─────────────────────────

    group('_streakMilestone', () {
      HabitAnalyticsSnapshot makeSnapshot({
        required int currentStreak,
        required int longestStreak,
        String habitId = 'h1',
        String habitName = 'Test',
      }) {
        return HabitAnalyticsSnapshot(
          habitId: habitId,
          habitName: habitName,
          streak: StreakState(
            current: currentStreak,
            longest: longestStreak,
            isActive: currentStreak > 0,
          ),
          completionRateLast30Days: 0.7,
          dayOfWeekCompletionRates: const {},
        );
      }

      test('milestone insight for streak of 7', () {
        final snapshot = makeSnapshot(currentStreak: 7, longestStreak: 10);
        final insights = generator.generate(
          summaries: [],
          habitStats: [snapshot],
        );
        final milestones = insights
            .where((i) => i.type == InsightType.streakMilestone)
            .toList();
        expect(milestones, isNotEmpty);
        expect(milestones.first.message, contains('7'));
      });

      test('milestone insight for streaks 14, 21, 30, 50, 100', () {
        for (final milestone in [14, 21, 30, 50, 100]) {
          final snapshot = makeSnapshot(
            currentStreak: milestone,
            longestStreak: milestone,
          );
          final insights = generator.generate(
            summaries: [],
            habitStats: [snapshot],
          );
          final milestones = insights
              .where((i) => i.type == InsightType.streakMilestone)
              .toList();
          expect(
            milestones,
            isNotEmpty,
            reason: 'Expected milestone for $milestone days',
          );
        }
      });

      test('personal record warning when 1 day from breaking record', () {
        final snapshot = makeSnapshot(currentStreak: 9, longestStreak: 10);
        final insights = generator.generate(
          summaries: [],
          habitStats: [snapshot],
        );
        final milestones = insights
            .where((i) => i.type == InsightType.streakMilestone)
            .toList();
        expect(milestones, isNotEmpty);
        expect(milestones.first.title, contains('رقم قياسي'));
      });

      test('no milestone for non-milestone streak (e.g. 8)', () {
        final snapshot = makeSnapshot(currentStreak: 8, longestStreak: 20);
        final insights = generator.generate(
          summaries: [],
          habitStats: [snapshot],
        );
        final milestones = insights
            .where((i) => i.type == InsightType.streakMilestone)
            .toList();
        expect(milestones, isEmpty);
      });
    });

    // ── Failure Pattern ───────────────────────────

    group('_failurePattern', () {
      HabitAnalyticsSnapshot makePatternSnapshot({
        required Map<int, double> dayRates,
        double avgRate = 0.7,
      }) {
        return HabitAnalyticsSnapshot(
          habitId: 'h1',
          habitName: 'Test',
          streak: const StreakState(current: 5, longest: 5, isActive: true),
          completionRateLast30Days: avgRate,
          dayOfWeekCompletionRates: dayRates,
        );
      }

      test('warning when one day is significantly worse than average', () {
        final snapshot = makePatternSnapshot(
          dayRates: {
            1: 0.8, 2: 0.8, 3: 0.8, 4: 0.8, 5: 0.8,
            6: 0.8, 7: 0.2, // Sunday is very bad
          },
          avgRate: 0.75,
        );
        final insights = generator.generate(
          summaries: [],
          habitStats: [snapshot],
        );
        final warnings = insights
            .where(
              (i) =>
                  i.type == InsightType.warning &&
                  i.scope == InsightScope.habitSpecific,
            )
            .toList();
        expect(warnings, isNotEmpty);
      });

      test(
        'no warning when all days are similarly bad (whole habit struggling)',
        () {
          final snapshot = makePatternSnapshot(
            dayRates: {1: 0.2, 2: 0.2, 3: 0.2, 4: 0.2, 5: 0.2, 6: 0.2, 7: 0.2},
            avgRate: 0.2, // overall low — not just one day
          );
          final insights = generator.generate(
            summaries: [],
            habitStats: [snapshot],
          );
          final warnings = insights
              .where(
                (i) =>
                    i.type == InsightType.warning &&
                    i.scope == InsightScope.habitSpecific,
              )
              .toList();
          expect(warnings, isEmpty);
        },
      );

      test('no warning when empty dayOfWeekCompletionRates', () {
        final snapshot = makePatternSnapshot(dayRates: {});
        final insights = generator.generate(
          summaries: [],
          habitStats: [snapshot],
        );
        final warnings = insights
            .where(
              (i) =>
                  i.type == InsightType.warning &&
                  i.scope == InsightScope.habitSpecific,
            )
            .toList();
        expect(warnings, isEmpty);
      });
    });

    // ── Max Warnings Cap ─────────────────────────

    group('max warnings cap', () {
      test('never generates more than 2 habit-specific warnings', () {
        // Create 5 habits all with bad Sunday patterns
        final snapshots = List.generate(5, (i) {
          return HabitAnalyticsSnapshot(
            habitId: 'h$i',
            habitName: 'Habit $i',
            streak: const StreakState(current: 5, longest: 5, isActive: true),
            completionRateLast30Days: 0.7,
            dayOfWeekCompletionRates: {
              1: 0.8,
              2: 0.8,
              3: 0.8,
              4: 0.8,
              5: 0.8,
              6: 0.8,
              7: 0.1,
            },
          );
        });

        final insights = generator.generate(
          summaries: [],
          habitStats: snapshots,
        );
        final warnings = insights
            .where(
              (i) =>
                  i.type == InsightType.warning &&
                  i.scope == InsightScope.habitSpecific,
            )
            .toList();
        expect(warnings.length, lessThanOrEqualTo(2));
      });
    });

    // ── Priority Ordering ────────────────────────

    test('high priority insights appear before low priority', () {
      final summaries = List.generate(7, (i) => makeSummary(daysAgo(i), 0.85));
      final snapshot = HabitAnalyticsSnapshot(
        habitId: 'h1',
        habitName: 'Test',
        streak: const StreakState(current: 7, longest: 10, isActive: true),
        completionRateLast30Days: 0.8,
        dayOfWeekCompletionRates: const {},
      );

      final insights = generator.generate(
        summaries: summaries,
        habitStats: [snapshot],
      );

      for (int i = 1; i < insights.length; i++) {
        expect(
          insights[i - 1].priority.index,
          greaterThanOrEqualTo(insights[i].priority.index),
          reason: 'Insights should be sorted high priority first',
        );
      }
    });
  });
}
