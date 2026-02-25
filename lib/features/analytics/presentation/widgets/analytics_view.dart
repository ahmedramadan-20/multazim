import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/analytics_cubit.dart';
import '../cubit/analytics_state.dart';
import 'completion_trend_chart.dart';
import 'heatmap_calendar.dart';
import 'statistics_grid.dart';
import 'insight_card.dart';
import 'section_card.dart';
import '../../../../core/widgets/milestone_card.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التحليلات'), centerTitle: true),
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AnalyticsError) {
            return Center(child: Text('خطأ: ${state.message}'));
          }
          if (state is AnalyticsLoaded) {
            final summaries = state.summaries;
            final heatmapData = {
              for (var s in summaries) s.date: s.completionRate,
            };

            return RefreshIndicator(
              onRefresh: () => context.read<AnalyticsCubit>().loadAnalytics(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Statistics Grid (always first) ──
                    StatisticsGrid(summaries: summaries),
                    const SizedBox(height: 24),

                    // ── 2. Completion Trend Chart ───────────
                    SectionCard(
                      title: 'اتجاه الإنجاز',
                      child: CompletionTrendChart(summaries: summaries),
                    ),
                    const SizedBox(height: 16),

                    // ── 3. Heatmap ──────────────────────────
                    SectionCard(
                      title: 'خريطة الالتزام',
                      child: HeatmapCalendar(
                        data: heatmapData,
                        endDate: DateTime.now(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── 4. Milestones ───────────────────────
                    if (state.milestones.isNotEmpty) ...[
                      Text(
                        'الإنجازات',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.milestones.length,
                          itemBuilder: (context, index) {
                            final milestone = state.milestones[index];
                            return MilestoneCard(milestone: milestone);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── 5. Insights (bottom — contextual) ──
                    if (state.insights.isNotEmpty) ...[
                      Text(
                        'رؤى وملاحظات',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...state.insights.map(
                        (insight) => InsightCard(insight: insight),
                      ),
                    ],

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
