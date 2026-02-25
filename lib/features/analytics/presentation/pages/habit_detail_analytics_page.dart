import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multazim/core/di/injection_container.dart';
import 'package:multazim/features/analytics/presentation/cubit/analytics_cubit.dart';
import '../widgets/habit_analytics_view.dart';

class HabitDetailAnalyticsPage extends StatelessWidget {
  final String habitId;

  const HabitDetailAnalyticsPage({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AnalyticsCubit>()..loadHabitDetails(habitId),
      child: const HabitAnalyticsView(),
    );
  }
}
