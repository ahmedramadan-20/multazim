import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../analytics/domain/entities/insight.dart';
import '../../../analytics/domain/entities/habit_analytics_snapshot.dart';
import '../../../analytics/domain/services/insight_generator.dart';
import '../../../analytics/domain/usecases/get_habits_for_analytics_usecase.dart';
import '../../../analytics/domain/usecases/get_habit_events_for_analytics_usecase.dart';
import '../../../analytics/domain/usecases/get_habit_repairs_for_analytics_usecase.dart';
import '../../../analytics/domain/usecases/get_habit_by_id_for_analytics_usecase.dart';
import '../../../analytics/domain/usecases/get_habit_milestones_for_analytics_usecase.dart';
import '../../../habits/domain/services/streak_service.dart';
import '../../../habits/domain/entities/milestone.dart';
import '../../../analytics/domain/repositories/analytics_repository.dart';
import 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository _repository;
  final GetHabitsForAnalyticsUseCase _getHabits;
  final GetHabitEventsForAnalyticsUseCase _getHabitEvents;
  final GetHabitRepairsForAnalyticsUseCase _getHabitRepairs;
  final GetHabitByIdForAnalyticsUseCase _getHabitById;
  final GetHabitMilestonesForAnalyticsUseCase _getHabitMilestones;
  final StreakService _streakService;
  final InsightGenerator _insightGenerator = InsightGenerator();

  AnalyticsCubit({
    required AnalyticsRepository repository,
    required GetHabitsForAnalyticsUseCase getHabits,
    required GetHabitEventsForAnalyticsUseCase getHabitEvents,
    required GetHabitRepairsForAnalyticsUseCase getHabitRepairs,
    required GetHabitByIdForAnalyticsUseCase getHabitById,
    required GetHabitMilestonesForAnalyticsUseCase getHabitMilestones,
    required StreakService streakService,
  }) : _repository = repository,
       _getHabits = getHabits,
       _getHabitEvents = getHabitEvents,
       _getHabitRepairs = getHabitRepairs,
       _getHabitById = getHabitById,
       _getHabitMilestones = getHabitMilestones,
       _streakService = streakService,
       super(AnalyticsInitial());

  Future<void> loadAnalytics([DateTime? start, DateTime? end]) async {
    emit(AnalyticsLoading());
    try {
      final endDate = end ?? DateTime.now();
      final startDate = start ?? endDate.subtract(const Duration(days: 30));

      final summaries = await _repository.getSummaries(startDate, endDate);
      final habits = await _getHabits(); // ← NOW USES USE CASE
      final snapshots = <HabitAnalyticsSnapshot>[];

      for (final habit in habits.where((h) => h.isActive)) {
        final events = await _getHabitEvents(habit.id); // ← USE CASE
        final repairs = await _getHabitRepairs(habit.id); // ← USE CASE
        final streak = _streakService.calculateStreak(habit, events, repairs);
        final dowStats = await _repository.getDayOfWeekStats(habit.id);

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
                      .where((e) => e.status.name == 'completed')
                      .length /
                  30;

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

      // Also need getAllMilestones use case — add it if it doesn't exist
      final allMilestones =
          <Milestone>[]; // TODO: Create GetAllMilestonesUseCase

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
                      .where((e) => e.status.name == 'completed')
                      .length /
                  30;

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
