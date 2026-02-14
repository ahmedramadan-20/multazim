import 'package:multazim/core/data/objectbox_store.dart';
import 'package:multazim/core/error/failures.dart';
import 'package:multazim/objectbox.g.dart';
import 'package:multazim/features/analytics/domain/entities/daily_summary.dart';
import 'package:multazim/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:multazim/features/habits/data/models/habit_event_model.dart';
import 'package:multazim/features/habits/data/models/habit_model.dart';
import 'package:multazim/features/habits/domain/entities/habit_event.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final Box<HabitEventModel> _eventBox;
  final Box<HabitModel> _habitBox;

  AnalyticsRepositoryImpl(ObjectBoxStore store)
    : _eventBox = store.store.box<HabitEventModel>(),
      _habitBox = store.store.box<HabitModel>();

  @override
  Future<List<DailySummary>> getSummaries(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // 1. Fetch all events in range
      // Normalized to start of day for easier comparison
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
      ).add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

      final query = _eventBox
          .query(
            HabitEventModel_.date
                .greaterOrEqualDate(start)
                .and(HabitEventModel_.date.lessOrEqualDate(end)),
          )
          .build();
      final events = query.find();
      query.close();

      // 2. Fetch all habits to know what was strictly scheduled
      // For a truly accurate historical schedule, we'd need historical
      // schedule snapshots. For Phase 3, we'll assume current habits
      // apply reasonably well to the recent past, or only count
      // active habits.
      // Optimisation: Load all habits once and convert to entities
      final habitModels = _habitBox.getAll();
      final activeHabits = habitModels
          .map((m) => m.toEntity())
          .where((h) => h.isActive)
          .toList();

      // 3. Aggregate by Date
      final summaries = <DailySummary>[];
      var currentDate = start;

      // Loop through each day in the range
      while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
        // Events for this specific day
        final eventsForDay = events.where((e) {
          return e.date.year == currentDate.year &&
              e.date.month == currentDate.month &&
              e.date.day == currentDate.day;
        }).toList();

        // Calculate stats
        // Total Scheduled: This is tricky without historical snapshots.
        // We will approximate: Active habits that match the schedule for this day.
        int totalScheduled = 0;
        for (var habit in activeHabits) {
          if (habit.isScheduledOn(currentDate)) {
            totalScheduled++;
          }
        }

        // Correct Scheduled count: if we have events for a habit on this day,
        // it WAS scheduled (or at least acted upon).
        // Max(calculated_scheduled, actual_actions_count) might be safer?
        // Let's stick to the rule: "How many did I start out to do?"

        int totalCompleted = 0;
        int totalSkipped = 0;
        int totalFailed = 0;

        for (var event in eventsForDay) {
          final status = HabitEventStatus.values.firstWhere(
            (e) => e.name == event.statusName,
          );
          switch (status) {
            case HabitEventStatus.completed:
              totalCompleted++;
              break;
            case HabitEventStatus.skipped:
              totalSkipped++;
              break;
            case HabitEventStatus.failed:
              totalFailed++;
              break;
            case HabitEventStatus.missed:
              // Missed is usually calculated, not stored as an event
              // unless we run a cron job.
              break;
          }
        }

        // Avoid division by zero and clamp to 100%
        double rate = 0.0;
        if (totalScheduled > 0) {
          // If more actions were taken than scheduled (e.g. unscheduled habits),
          // we treat it as 100% rather than >100% for the trend logic.
          rate = (totalCompleted / totalScheduled).clamp(0.0, 1.0);
        }

        summaries.add(
          DailySummary(
            date: currentDate,
            totalScheduled: totalScheduled,
            totalCompleted: totalCompleted,
            totalSkipped: totalSkipped,
            totalFailed: totalFailed,
            completionRate: rate,
          ),
        );

        currentDate = currentDate.add(const Duration(days: 1));
      }

      return summaries;
    } catch (e) {
      // In a real app, log to Crashlytics
      throw LocalFailure('Failed to calculate analytics: $e');
    }
  }

  @override
  Future<Map<DateTime, double>> getHeatmapData(String habitId) async {
    try {
      final query = _eventBox
          .query(HabitEventModel_.habitId.equals(habitId))
          .build();
      final events = query.find();
      query.close();

      final data = <DateTime, double>{};

      for (var event in events) {
        final status = HabitEventStatus.values.firstWhere(
          (e) => e.name == event.statusName,
        );

        // Heatmap usually shows "Completed" as 1.0 (or value based intensity)
        if (status == HabitEventStatus.completed) {
          // Normalized date (strip time)
          final date = DateTime(
            event.date.year,
            event.date.month,
            event.date.day,
          );
          data[date] = 1.0; // Or partial credit if we had partial completion
        }
      }
      return data;
    } catch (e) {
      throw LocalFailure('Failed to generating heatmap: $e');
    }
  }

  @override
  Future<Map<int, double>> getDayOfWeekStats(String habitId) async {
    try {
      final query = _eventBox
          .query(HabitEventModel_.habitId.equals(habitId))
          .build();
      final events = query.find();
      query.close();

      // 1 = Monday, 7 = Sunday
      final completionsByDay = <int, int>{
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
        6: 0,
        7: 0,
      };
      final totalEventsByDay = <int, int>{
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
        6: 0,
        7: 0,
      };

      for (var event in events) {
        final day = event.date.weekday;
        final status = HabitEventStatus.values.firstWhere(
          (e) => e.name == event.statusName,
        );

        // Only counting attempts? Or total days active?
        // Simplest metric: Of the times I tried/logged, how often did I succeed?
        // Better metric: Success rate per weekday (Requires knowing how many Mondays existed since start)

        // Approach A: Success / Total Attempts (Logged Events)
        totalEventsByDay[day] = (totalEventsByDay[day] ?? 0) + 1;
        if (status == HabitEventStatus.completed) {
          completionsByDay[day] = (completionsByDay[day] ?? 0) + 1;
        }
      }

      final stats = <int, double>{};
      for (int i = 1; i <= 7; i++) {
        final total = totalEventsByDay[i] ?? 0;
        if (total == 0) {
          stats[i] = 0.0;
        } else {
          stats[i] = (completionsByDay[i] ?? 0) / total;
        }
      }
      return stats;
    } catch (e) {
      throw LocalFailure('Failed to calculate stats: $e');
    }
  }
}
