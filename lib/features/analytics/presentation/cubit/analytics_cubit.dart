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

  final GetHabitByIdForAnalyticsUseCase _getHabitById;
  final GetHabitEventsForAnalyticsUseCase _getHabitEvents;
  final GetHabitRepairsForAnalyticsUseCase _getHabitRepairs;
  final GetHabitMilestonesForAnalyticsUseCase _getHabitMilestones;

  final StreakService _streakService;
  final InsightGenerator _insightGenerator = InsightGenerator();

  StreamSubscription? _dataSubscription;
  DateTime? _startDate;
  DateTime? _endDate;

  // ── Cancellation token ──────────────────────────────
  // Each _updateState run gets a unique token. If a newer run starts
  // before the previous one finishes, the old one checks isClosed
  // or compares tokens before emitting — prevents out-of-order states.
  int _updateToken = 0;

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
            )
            // ── Debounce: wait 300ms after the last emission before processing.
            // combineLatest4 fires once per individual stream emit — a single
            // habit completion triggers habits + events streams back-to-back,
            // which would cause 2 concurrent DB queries without this debounce.
            .debounceTime(const Duration(milliseconds: 300))
            .listen((data) {
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
    // ── Cancellation token ───────────────────────────
    // Increment before the async gap. If another _updateState call
    // starts while this one awaits, the token will differ and this
    // stale call will skip its emit.
    final token = ++_updateToken;

    try {
      final now = DateTime.now();
      final endDate = _endDate ?? now;
      final startDate =
          _startDate ?? endDate.subtract(const Duration(days: 30));

      final summaries = await _repository.getSummaries(startDate, endDate);

      // Stale check — a newer update started while we were awaiting
      if (isClosed || token != _updateToken) return;

      // ── Snapshots ────────────────────────────────
      final eventsByHabit = <String, List<HabitEvent>>{};
      for (final e in allEvents) {
        (eventsByHabit[e.habitId] ??= []).add(e);
      }

      final repairsByHabit = <String, List<StreakRepair>>{};
      for (final r in allRepairs) {
        (repairsByHabit[r.habitId] ??= []).add(r);
      }

      final snapshots = <HabitAnalyticsSnapshot>[];
      for (final habit in habits.where((h) => h.isActive)) {
        final events = eventsByHabit[habit.id] ?? [];
        final repairs = repairsByHabit[habit.id] ?? [];
        final streak = _streakService.calculateStreak(habit, events, repairs);
        final dowStats = _calculateDowStats(events);

        final cutoff = now.subtract(const Duration(days: 30));
        final last30 = events.where((e) => e.date.isAfter(cutoff)).toList();
        final completionRate = last30.isEmpty
            ? 0.0
            : last30
                      .where((e) => e.status == HabitEventStatus.completed)
                      .length /
                  last30.length;

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

      // Pre-build heatmap map here — not in build() (Fix #5)
      final heatmapData = {for (var s in summaries) s.date: s.completionRate};

      // Final stale check before emitting
      if (isClosed || token != _updateToken) return;

      emit(
        AnalyticsLoaded(
          summaries: summaries,
          heatmapData: heatmapData,
          insights: insights,
          milestones: allMilestones,
        ),
      );
    } catch (e) {
      if (isClosed || token != _updateToken) return;
      emit(AnalyticsError(e.toString()));
    }
  }

  Map<int, double> _calculateDowStats(List<HabitEvent> events) {
    final completions = <int, int>{for (int i = 1; i <= 7; i++) i: 0};
    final totals = <int, int>{for (int i = 1; i <= 7; i++) i: 0};

    for (final event in events) {
      final day = event.date.weekday;
      totals[day] = totals[day]! + 1;
      if (event.status == HabitEventStatus.completed) {
        completions[day] = completions[day]! + 1;
      }
    }

    return {
      for (int i = 1; i <= 7; i++)
        i: totals[i] == 0 ? 0.0 : completions[i]! / totals[i]!,
    };
  }

  // ── Fix #3: loadAnalytics now actually triggers a refresh ────────────
  // Previously it only set the date fields but never called _updateState,
  // so date filtering was silently broken.
  Future<void> loadAnalytics([DateTime? start, DateTime? end]) async {
    _startDate = start;
    _endDate = end;
    // Cancel current debounced stream and force immediate refresh
    // by reading the latest stream values via the subscription.
    // Since the stream doesn't expose last values directly, we emit
    // loading and rely on the next combineLatest4 tick — which we
    // force by cancelling and re-subscribing.
    await _dataSubscription?.cancel();
    emit(AnalyticsLoading());
    _initReactivity();
  }

  Future<void> loadHabitDetails(String habitId) async {
    emit(AnalyticsLoading());
    try {
      final heatmap = await _repository.getHeatmapData(habitId);
      final stats = await _repository.getDayOfWeekStats(habitId);
      final habit = await _getHabitById(habitId);
      final insights = <Insight>[];
      final milestones = <Milestone>[];

      if (habit != null) {
        final events = await _getHabitEvents(habitId);
        final repairs = await _getHabitRepairs(habitId);
        final streak = _streakService.calculateStreak(habit, events, repairs);
        milestones.addAll(await _getHabitMilestones(habitId));

        final cutoff = DateTime.now().subtract(const Duration(days: 30));
        final last30 = events.where((e) => e.date.isAfter(cutoff)).toList();
        final completionRate = last30.isEmpty
            ? 0.0
            : last30
                      .where((e) => e.status == HabitEventStatus.completed)
                      .length /
                  last30.length;

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

      if (isClosed) return;

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
      if (isClosed) return;
      emit(AnalyticsError(e.toString()));
    }
  }
}
