import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multazim/core/di/injection_container.dart';
import 'package:multazim/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:multazim/features/analytics/presentation/cubit/analytics_state.dart';
import 'package:multazim/features/analytics/presentation/widgets/heatmap_calendar.dart';
import 'package:multazim/features/analytics/presentation/widgets/insight_card.dart';
import 'package:intl/intl.dart';

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
      appBar: AppBar(title: const Text('أداء العادة')),
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
                  if (state.insights.isNotEmpty) ...[
                    Text(
                      'الرؤى والتحليلات',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...state.insights.map(
                      (insight) => InsightCard(insight: insight),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (heatmapData.isNotEmpty) ...[
                    Text(
                      'خريطة النشاط',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    HeatmapCalendar(data: heatmapData, endDate: DateTime.now()),
                    const SizedBox(height: 32),
                  ],

                  if (state.milestones.isNotEmpty) ...[
                    Text(
                      'الإنجازات والمحطات',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.milestones.length,
                        itemBuilder: (context, index) {
                          final milestone = state.milestones[index];
                          return Card(
                            margin: const EdgeInsets.only(left: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '🏆',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'سلسلة ${milestone.days} أيام',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'MMM d',
                                      'ar',
                                    ).format(milestone.reachedDate),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
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
