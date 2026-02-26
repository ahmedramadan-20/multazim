import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:multazim/features/habits/domain/usecases/watch_habits_usecase.dart';
import 'package:multazim/features/habits/domain/usecases/watch_all_events_usecase.dart';
import 'package:multazim/features/habits/domain/usecases/watch_all_milestones_usecase.dart';
import 'package:multazim/features/habits/domain/usecases/watch_all_streak_repairs_usecase.dart';
import '../../../analytics/domain/entities/insight.dart';
import '../../../analytics/domain/entities/habit_analytics_snapshot.dart';
import '../../../analytics/domain/services/insight_generator.dart';
import '../../../analytics/domain/usecases/get_habit_by_id_for_analytics_usecase.dart';
import '../../../analytics/domain/usecases/get_habit_events_for_analytics_usecase.dart';
import '../../../analytics/domain/usecases/get_habit_milestones_for_analytics_usecase.dart';
import '../../../analytics/domain/usecases/get_habit_repairs_for_analytics_usecase.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_event.dart';
import '../../../habits/domain/entities/streak_repair.dart';
import '../../../habits/domain/services/streak_service.dart';
import '../../../habits/domain/entities/milestone.dart';
import '../../../analytics/domain/repositories/analytics_repository.dart';
import 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository _repository;
  final WatchHabitsUseCase _watchHabits;
  final WatchAllEventsUseCase _watchAllEvents;
  final WatchAllStreakRepairsUseCase _watchAllStreakRepairs;
  final WatchAllMilestonesUseCase _watchAllMilestones;

  // Keep these for loadHabitDetails (specific habit queries)
  final GetHabitByIdForAnalyticsUseCase _getHabitById;
  final GetHabitEventsForAnalyticsUseCase _getHabitEvents;
  final GetHabitRepairsForAnalyticsUseCase _getHabitRepairs;
  final GetHabitMilestonesForAnalyticsUseCase _getHabitMilestones;

  final StreakService _streakService;
  final InsightGenerator _insightGenerator = InsightGenerator();

  StreamSubscription? _dataSubscription;
  DateTime? _startDate;
  DateTime? _endDate;

  AnalyticsCubit({
    required AnalyticsRepository repository,
    required WatchHabitsUseCase watchHabits,
    required WatchAllEventsUseCase watchAllEvents,
    required WatchAllStreakRepairsUseCase watchAllStreakRepairs,
    required WatchAllMilestonesUseCase watchAllMilestones,
    required GetHabitByIdForAnalyticsUseCase getHabitById,
    required GetHabitEventsForAnalyticsUseCase getHabitEvents,
    required GetHabitRepairsForAnalyticsUseCase getHabitRepairs,
    required GetHabitMilestonesForAnalyticsUseCase getHabitMilestones,
    required StreakService streakService,
  }) : _repository = repository,
       _watchHabits = watchHabits,
       _watchAllEvents = watchAllEvents,
       _watchAllStreakRepairs = watchAllStreakRepairs,
       _watchAllMilestones = watchAllMilestones,
       _getHabitById = getHabitById,
       _getHabitEvents = getHabitEvents,
       _getHabitRepairs = getHabitRepairs,
       _getHabitMilestones = getHabitMilestones,
       _streakService = streakService,
       super(AnalyticsInitial()) {
    _initReactivity();
  }

  void _initReactivity() {
    _dataSubscription =
        Rx.combineLatest4(
          _watchHabits(),
          _watchAllEvents(),
          _watchAllStreakRepairs(),
          _watchAllMilestones(),
          (habits, events, repairs, milestones) =>
              (habits, events, repairs, milestones),
        ).listen((data) {
          _updateState(data.$1, data.$2, data.$3, data.$4);
        });
  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    return super.close();
  }

  Future<void> _updateState(
    List<Habit> habits,
    List<HabitEvent> allEvents,
    List<StreakRepair> allRepairs,
    List<Milestone> allMilestones,
  ) async {
    try {
      final now = DateTime.now();
      final endDate = _endDate ?? now;
      final startDate =
          _startDate ?? endDate.subtract(const Duration(days: 30));

      // 1. Summaries (Still from repo for complex date logic, but repo could be optimized)
      // Note: Repository still uses async queries, but we only call it ONCE here instead of N times.
      final summaries = await _repository.getSummaries(startDate, endDate);

      // 2. Snapshots
      final snapshots = <HabitAnalyticsSnapshot>[];
      final eventsByHabit = <String, List<HabitEvent>>{};
      for (final e in allEvents) {
        (eventsByHabit[e.habitId] ??= []).add(e);
      }

      final repairsByHabit = <String, List<StreakRepair>>{};
      for (final r in allRepairs) {
        (repairsByHabit[r.habitId] ??= []).add(r);
      }

      for (final habit in habits.where((h) => h.isActive)) {
        final events = eventsByHabit[habit.id] ?? [];
        final repairs = repairsByHabit[habit.id] ?? [];
        final streak = _streakService.calculateStreak(habit, events, repairs);

        // Day of week stats - repository still does independent query,
        // but we can calculate it in-memory now!
        final dowStats = _calculateDowStats(events);

        final last30DaysEvents = events
            .where(
              (e) => e.date.isAfter(now.subtract(const Duration(days: 30))),
            )
            .toList();

        final attempts = last30DaysEvents.length;
        final completionRate = attempts == 0
            ? 0.0
            : last30DaysEvents
                      .where((e) => e.status == HabitEventStatus.completed)
                      .length /
                  attempts;

        snapshots.add(
          HabitAnalyticsSnapshot(
            habitId: habit.id,
            habitName: habit.name,
            streak: streak,
            dayOfWeekCompletionRates: dowStats,
            completionRateLast30Days: completionRate,
          ),
        );
      }

      final insights = _insightGenerator.generate(
        summaries: summaries,
        habitStats: snapshots,
      );

      emit(
        AnalyticsLoaded(
          summaries: summaries,
          insights: insights,
          milestones: allMilestones,
        ),
      );
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Map<int, double> _calculateDowStats(List<HabitEvent> events) {
    final completionsByDay = <int, int>{for (int i = 1; i <= 7; i++) i: 0};
    final totalEventsByDay = <int, int>{for (int i = 1; i <= 7; i++) i: 0};

    for (var event in events) {
      final day = event.date.weekday;
      totalEventsByDay[day] = totalEventsByDay[day]! + 1;
      if (event.status == HabitEventStatus.completed) {
        completionsByDay[day] = completionsByDay[day]! + 1;
      }
    }

    return {
      for (int i = 1; i <= 7; i++)
        i: totalEventsByDay[i] == 0
            ? 0.0
            : completionsByDay[i]! / totalEventsByDay[i]!,
    };
  }

  Future<void> loadAnalytics([DateTime? start, DateTime? end]) async {
    _startDate = start;
    _endDate = end;
    // Manual trigger - doesn't need to fetch anything, just relies on streams
    // But we might want to emit loading if we're forcing a refresh
  }

  Future<void> loadHabitDetails(String habitId) async {
    emit(AnalyticsLoading());
    try {
      final heatmap = await _repository.getHeatmapData(habitId);
      final stats = await _repository.getDayOfWeekStats(habitId);
      final habit = await _getHabitById(habitId); // ← USE CASE
      final insights = <Insight>[];
      final milestones = <Milestone>[];

      if (habit != null) {
        final events = await _getHabitEvents(habitId); // ← USE CASE
        final repairs = await _getHabitRepairs(habitId); // ← USE CASE
        final streak = _streakService.calculateStreak(habit, events, repairs);
        milestones.addAll(await _getHabitMilestones(habitId)); // ← USE CASE

        final last30DaysEvents = events
            .where(
              (e) => e.date.isAfter(
                DateTime.now().subtract(const Duration(days: 30)),
              ),
            )
            .toList();
        final completionRate = last30DaysEvents.isEmpty
            ? 0.0
            : last30DaysEvents
                      .where((e) => e.status == HabitEventStatus.completed)
                      .length /
                  last30DaysEvents.length;

        final snapshot = HabitAnalyticsSnapshot(
          habitId: habitId,
          habitName: habit.name,
          streak: streak,
          dayOfWeekCompletionRates: stats,
          completionRateLast30Days: completionRate,
        );

        insights.addAll(
          _insightGenerator.generate(summaries: [], habitStats: [snapshot]),
        );
      }

      emit(
        AnalyticsLoaded(
          summaries: [],
          heatmapData: heatmap,
          dayOfWeekStats: stats,
          insights: insights,
          milestones: milestones,
        ),
      );
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}
