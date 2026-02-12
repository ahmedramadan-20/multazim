import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multazim/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:multazim/features/analytics/presentation/cubit/analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsCubit({required AnalyticsRepository repository})
    : _repository = repository,
      super(AnalyticsInitial());

  Future<void> loadAnalytics([DateTime? start, DateTime? end]) async {
    emit(AnalyticsLoading());
    try {
      // Default to last 30 days if not specified
      final endDate = end ?? DateTime.now();
      final startDate = start ?? endDate.subtract(const Duration(days: 30));

      final summaries = await _repository.getSummaries(startDate, endDate);

      // For Phase 3 dashboard, we might not load habit-specific data immediately
      // or we pick a "top habit" to show?
      // The requested Dashboard has "Overview" stats.
      // Heatmap likely needs a specific habit ID, or global "activity"?
      // If global activity, we need a method for that in repo.
      // Assuming Overview Dashboard shows aggregate daily stats.

      emit(AnalyticsLoaded(summaries: summaries));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> loadHabitDetails(String habitId) async {
    emit(AnalyticsLoading());
    try {
      // We also need summaries for the trend chart?

      // Note: Re-using getSummaries might return global summaries, not habit specific.
      // We might need getHabitSummaries(habitId) in repo if we want trend for ONE habit.
      // For now, let's just load the heatmaps and stats.

      final heatmap = await _repository.getHeatmapData(habitId);
      final stats = await _repository.getDayOfWeekStats(habitId);

      // We preserve existing summaries if we have them? Or just emit what we have.
      // Ideally we'd separate "OverviewCubit" and "HabitDetailCubit" or have generic state.
      // For simplicity, we emit what this call fetched.

      emit(
        AnalyticsLoaded(
          summaries: [], // Placeholder or separate loaded state needed?
          heatmapData: heatmap,
          dayOfWeekStats: stats,
        ),
      );
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}
