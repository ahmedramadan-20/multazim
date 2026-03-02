import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/milestone_card.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../cubit/habit_detail_cubit.dart';
import '../cubit/habit_detail_state.dart';
import '../helpers/habit_translation_helper.dart';
import 'habit_card.dart';
import 'habit_info_chip.dart';
import 'habit_stat_card.dart';
import 'habit_legend_dot.dart';
import 'habit_mini_calendar.dart';
import 'habit_event_tile.dart';
import '../../../../core/theme/app_colors.dart';

class HabitDetailView extends StatelessWidget {
  const HabitDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitDetailCubit, HabitDetailState>(
      builder: (context, state) {
        if (state is HabitDetailLoading || state is HabitDetailInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is HabitDetailError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.message)),
          );
        }

        if (state is! HabitDetailLoaded) return const SizedBox.shrink();

        final habit = state.habit;
        final events = state.events;
        final streak = state.streak;
        final milestones = state.milestones;
        final habitColor = HabitCard.parseHabitColor(habit.color);
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ── Colored SliverAppBar ───────────
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: habitColor,
                foregroundColor: colorScheme.onPrimary,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () =>
                        context.push(AppRoutes.createHabit, extra: habit),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bar_chart_outlined),
                    onPressed: () => context.push(
                      AppRoutes.habitDetailAnalyticsPath(habit.id),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  title: Row(
                    children: [
                      Text(habit.icon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          habit.name,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [habitColor.withValues(alpha: 0.8), habitColor],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 56),
                      child: Row(
                        children: [
                          HabitInfoChip(
                            label: HabitTranslationHelper.categoryName(
                              habit.category,
                            ),
                            icon: HabitTranslationHelper.categoryIcon(
                              habit.category,
                            ),
                          ),
                          const SizedBox(width: 8),
                          HabitInfoChip(
                            label: HabitTranslationHelper.strictnessName(
                              habit.strictness,
                            ),
                            icon: '⚡',
                          ),
                          const SizedBox(width: 8),
                          HabitInfoChip(
                            label:
                                habit.schedule.type == HabitScheduleType.daily
                                ? 'يومي'
                                : '${habit.schedule.timesPerWeek}x أسبوعياً',
                            icon: '📅',
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Streak Cards ─────────────
                      Row(
                        children: [
                          Expanded(
                            child: HabitStatCard(
                              title: 'السلسلة',
                              value: '${streak.current}',
                              unit: 'يوم',
                              icon: '🔥',
                              color: Colors.deepOrange,
                              colorScheme: colorScheme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: HabitStatCard(
                              title: 'الأطول',
                              value: '${streak.longest}',
                              unit: 'يوم',
                              icon: '🏆',
                              color: Colors.amber[700]!,
                              colorScheme: colorScheme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: HabitStatCard(
                              title: 'الإنجاز',
                              value:
                                  '${events.where((e) => e.status == HabitEventStatus.completed).length}',
                              unit: 'مرة',
                              icon: '✅',
                              color: AppColors.success,
                              colorScheme: colorScheme,
                            ),
                          ),
                        ],
                      ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),

                      // ── 30-Day Mini Calendar ──────
                      Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'آخر 30 يوم',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              HabitMiniCalendar(
                                events: events,
                                habitColor: habitColor,
                              ),
                              const SizedBox(height: 8),

                              // Legend
                              Row(
                                children: [
                                  HabitLegendDot(
                                    color: habitColor,
                                    label: 'مكتمل',
                                  ),
                                  const SizedBox(width: 16),
                                  HabitLegendDot(
                                    color: AppColors.warning,
                                    label: 'متخطى',
                                  ),
                                  const SizedBox(width: 16),
                                  HabitLegendDot(
                                    color: colorScheme.error,
                                    label: 'فشل',
                                  ),
                                  const SizedBox(width: 16),
                                  HabitLegendDot(
                                    color: colorScheme.surfaceContainerHighest,
                                    label: 'لا شيء',
                                  ),
                                ],
                              ),
                            ],
                          )
                          .animate(delay: 400.ms)
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),

                      // ── Milestones ────────────────
                      if (milestones.isNotEmpty)
                        ...[
                              Text(
                                'الإنجازات',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 88,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: milestones.length,
                                  itemBuilder: (context, index) {
                                    final m = milestones[index];
                                    return MilestoneCard(milestone: m);
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                            ]
                            .animate(delay: 600.ms)
                            .fadeIn()
                            .slideY(begin: 0.1, end: 0),

                      // ── Event History ─────────────
                      Text(
                        'السجل الكامل',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ── Event list items ───────────────
              events.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'لا توجد أحداث مسجلة بعد',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final event = events[index];
                        return HabitEventTile(
                              event: event,
                              habitColor: habitColor,
                            )
                            .animate(delay: (800 + (index * 50)).ms)
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.1, end: 0);
                      }, childCount: events.length),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }
}
