import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // ── Header ─────────────────────────────
          const TodayHeader(),

          // ── Date Strip ─────────────────────────
          const TodayDateStrip(),

          // ── Habit List ─────────────────────────
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

                  // ── CORRECT UNIT-BASED CALCULATION ──
                  double totalTarget = 0;
                  double totalCurrent = 0;

                  for (final habit in state.habits) {
                    final event = state.todayEvents[habit.id];

                    if (habit.goal.type == HabitGoalType.numeric) {
                      final target = habit.goal.targetValue ?? 1.0;
                      final current = (event?.countValue ?? 0.0).clamp(
                        0.0,
                        target,
                      );

                      totalTarget += target;
                      totalCurrent += current;
                    } else {
                      // Binary: target is 1 unit
                      totalTarget += 1.0;
                      if (event?.status == HabitEventStatus.completed) {
                        totalCurrent += 1.0;
                      }
                    }
                  }

                  final progress = totalTarget == 0
                      ? 0.0
                      : totalCurrent / totalTarget;

                  return Column(
                    children: [
                      // ── Daily progress summary ──
                      DailyProgressSummary(
                        progress: progress,
                        totalCurrent: totalCurrent,
                        totalTarget: totalTarget,
                      ),

                      // ── Habit list ──────────────
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () =>
                              context.read<HabitsCubit>().loadHabits(),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: state.habits.length,
                            itemBuilder: (context, index) {
                              final habit = state.habits[index];
                              return DismissibleHabitCard(
                                habit: habit,
                                todayEvent: state.todayEvents[habit.id],
                                streak: state.streaks[habit.id],
                                weeklyProgress: state.weeklyProgress[habit.id],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createHabit),
        child: const Icon(Icons.add),
      ),
    );
  }
}
