import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multazim/features/analytics/domain/entities/insight.dart';
import 'package:multazim/features/analytics/domain/entities/habit_analytics_snapshot.dart';
import 'package:multazim/features/analytics/domain/services/insight_generator.dart';
import 'package:multazim/features/habits/domain/repositories/habit_repository.dart';
import 'package:multazim/features/habits/domain/services/streak_service.dart';
import 'package:multazim/features/habits/domain/entities/milestone.dart';
import 'package:multazim/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:multazim/features/analytics/presentation/cubit/analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository _repository;
  final HabitRepository _habitRepository;
  final StreakService _streakService;
  final InsightGenerator _insightGenerator = InsightGenerator();

  AnalyticsCubit({
    required AnalyticsRepository repository,
    required HabitRepository habitRepository,
    required StreakService streakService,
  }) : _repository = repository,
       _habitRepository = habitRepository,
       _streakService = streakService,
       super(AnalyticsInitial());

  Future<void> loadAnalytics([DateTime? start, DateTime? end]) async {
    emit(AnalyticsLoading());
    try {
      final endDate = end ?? DateTime.now();
      final startDate = start ?? endDate.subtract(const Duration(days: 30));

      // 1. Fetch Global Summaries
      final summaries = await _repository.getSummaries(startDate, endDate);

      // 2. Build Analytics Snapshots for Insights
      final habits = await _habitRepository.getHabits();
      final snapshots = <HabitAnalyticsSnapshot>[];

      for (final habit in habits.where((h) => h.isActive)) {
        final events = await _habitRepository.getEventsForHabit(habit.id);
        final repairs = await _habitRepository.getStreakRepairs(habit.id);

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

      // 3. Generate Insights
      final insights = _insightGenerator.generate(
        summaries: summaries,
        habitStats: snapshots,
      );

      // 4. Fetch All Milestones for the global view
      final allMilestones = await _habitRepository.getAllMilestones();

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

      // Generate insights for this specific habit
      final habit = await _habitRepository.getHabitById(habitId);
      final insights = <Insight>[];
      final milestones = <Milestone>[];

      if (habit != null) {
        final events = await _habitRepository.getEventsForHabit(habitId);
        final repairs = await _habitRepository.getStreakRepairs(habitId);
        final streak = _streakService.calculateStreak(habit, events, repairs);
        milestones.addAll(await _habitRepository.getMilestones(habitId));

        // Approx 30-day rate
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
