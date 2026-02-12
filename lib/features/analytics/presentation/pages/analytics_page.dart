import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multazim/core/di/injection_container.dart';
import 'package:multazim/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:multazim/features/analytics/presentation/cubit/analytics_state.dart';
import 'package:multazim/features/analytics/presentation/widgets/completion_trend_chart.dart';
import 'package:multazim/features/analytics/presentation/widgets/heatmap_calendar.dart';
import 'package:multazim/features/analytics/presentation/widgets/statistics_grid.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AnalyticsCubit>()..loadAnalytics(),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnalyticsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is AnalyticsLoaded) {
            final summaries = state.summaries;

            // Derive global heatmap data from summaries
            final heatmapData = {
              for (var s in summaries) s.date: s.completionRate,
            };

            return RefreshIndicator(
              onRefresh: () => context.read<AnalyticsCubit>().loadAnalytics(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatisticsGrid(summaries: summaries),
                    const SizedBox(height: 32),
                    CompletionTrendChart(summaries: summaries),
                    const SizedBox(height: 32),
                    HeatmapCalendar(data: heatmapData, endDate: DateTime.now()),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
