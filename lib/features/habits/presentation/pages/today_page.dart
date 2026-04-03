import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../../domain/entities/streak.dart';
import '../cubit/habits_cubit.dart';
import '../cubit/habits_state.dart';
import '../widgets/today_header.dart';
import '../widgets/today_date_strip.dart';
import '../widgets/daily_progress_summary.dart';
import '../widgets/empty_habit_state.dart';
import '../widgets/habit_shimmer_list.dart';
import '../widgets/dismissible_habit_card.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<HabitsCubit>();
    if (cubit.state is! HabitsLoaded) {
      cubit.loadHabits();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          const TodayHeader(),
          const TodayDateStrip(),
          Expanded(
            child: BlocBuilder<HabitsCubit, HabitsState>(
              builder: (context, state) {
                if (state is HabitsLoading) {
                  return const HabitShimmerList();
                }

                if (state is HabitsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text('حدث خطأ: ${state.message}'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () =>
                              context.read<HabitsCubit>().loadHabits(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is HabitsLoaded) {
                  if (state.habits.isEmpty) {
                    return EmptyHabitState(
                      onAdd: () => context.push(AppRoutes.createHabit),
                    );
                  }

                  return Column(
                    children: [
                      DailyProgressSummary(
                        progress: state.dailyProgress,
                        totalCurrent: state.dailyTotalCurrent,
                        totalTarget: state.dailyTotalTarget,
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () =>
                              context.read<HabitsCubit>().loadHabits(),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 88),
                            itemCount: state.habits.length,
                            itemBuilder: (context, index) {
                              final habit = state.habits[index];

                              // RepaintBoundary isolates each card's
                              // paint from the rest of the list.
                              return RepaintBoundary(
                                child: _AnimatedHabitCard(
                                  key: ValueKey(habit.id),
                                  index: index,
                                  habit: habit,
                                  todayEvent: state.todayEvents[habit.id],
                                  streak: state.streaks[habit.id],
                                  weeklyProgress:
                                      state.weeklyProgress[habit.id],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Entrance animation fires exactly once per card.
// Subsequent BlocBuilder rebuilds skip the animation
// entirely — no repeated sliding or fading.
// ─────────────────────────────────────────────────
class _AnimatedHabitCard extends StatefulWidget {
  final int index;
  final Habit habit;
  final HabitEvent? todayEvent;
  final StreakState? streak;
  final ({int current, int target})? weeklyProgress;

  const _AnimatedHabitCard({
    super.key,
    required this.index,
    required this.habit,
    this.todayEvent,
    this.streak,
    this.weeklyProgress,
  });

  @override
  State<_AnimatedHabitCard> createState() => _AnimatedHabitCardState();
}

class _AnimatedHabitCardState extends State<_AnimatedHabitCard> {
  bool _hasAnimated = false;

  @override
  Widget build(BuildContext context) {
    final card = DismissibleHabitCard(
      habit: widget.habit,
      todayEvent: widget.todayEvent,
      streak: widget.streak,
      weeklyProgress: widget.weeklyProgress,
    );

    if (!_hasAnimated) {
      _hasAnimated = true;
      return card
          .animate(delay: (widget.index * 50).ms)
          .fadeIn(duration: 250.ms)
          .slideY(begin: 0.12, end: 0, curve: Curves.easeOut);
    }

    return card;
  }
}
