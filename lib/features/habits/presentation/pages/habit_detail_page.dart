import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/habit_detail_cubit.dart';
import '../widgets/habit_detail_view.dart';

class HabitDetailPage extends StatelessWidget {
  final String habitId;
  const HabitDetailPage({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<HabitDetailCubit>()..load(habitId),
      child: const HabitDetailView(),
    );
  }
}
