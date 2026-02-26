import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/analytics_cubit.dart';
import '../cubit/analytics_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'heatmap_calendar.dart';
import 'insight_card.dart';
import '../../../../core/widgets/milestone_card.dart';

class HabitAnalyticsView extends StatelessWidget {
  const HabitAnalyticsView({super.key});

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
            final heatmapData = state.heatmapData ?? {};

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
                    ...state.insights.asMap().entries.map(
                      (entry) => InsightCard(insight: entry.value)
                          .animate(delay: (entry.key * 100).ms)
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.1, end: 0),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (heatmapData.isNotEmpty) ...[
                    Card(
                          elevation: 0,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'خريطة الالتزام',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                ),
                                const SizedBox(height: 16),
                                HeatmapCalendar(
                                  data: heatmapData,
                                  endDate: DateTime.now(),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate(delay: 400.ms)
                        .fadeIn()
                        .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1, 1),
                        ),
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
                          return MilestoneCard(milestone: milestone)
                              .animate(delay: (index * 150).ms)
                              .fadeIn()
                              .slideX(begin: 0.2, end: 0);
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
