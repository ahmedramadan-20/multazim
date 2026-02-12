import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multazim/core/di/injection_container.dart';
import 'package:multazim/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:multazim/features/analytics/presentation/cubit/analytics_state.dart';
import 'package:multazim/features/analytics/presentation/widgets/heatmap_calendar.dart';

class HabitDetailAnalyticsPage extends StatelessWidget {
  final String habitId;

  const HabitDetailAnalyticsPage({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AnalyticsCubit>()..loadHabitDetails(habitId),
      child: const _HabitAnalyticsView(),
    );
  }
}

class _HabitAnalyticsView extends StatelessWidget {
  const _HabitAnalyticsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Performance')),
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnalyticsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is AnalyticsLoaded) {
            // For detail page, we need heatmap and maybe summaries if available?
            // Our cubit's loadHabitDetails emits heatmapData and dayOfWeekStats.
            // It assumes empty summaries for now.

            final heatmapData = state.heatmapData ?? {};
            // dayOfWeekStats unused in current widgets but available for future

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (heatmapData.isNotEmpty)
                    HeatmapCalendar(data: heatmapData, endDate: DateTime.now()),
                  const SizedBox(height: 32),
                  // Add more detail widgets here
                  const Center(child: Text("More statistics coming soon...")),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
