import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../../domain/entities/streak.dart';
import '../cubit/habits_cubit.dart';
import 'habit_card.dart';

class DismissibleHabitCard extends StatelessWidget {
  final Habit habit;
  final HabitEvent? todayEvent;
  final StreakState? streak;
  final dynamic weeklyProgress;

  const DismissibleHabitCard({
    super.key,
    required this.habit,
    this.todayEvent,
    this.streak,
    this.weeklyProgress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete, color: colorScheme.error),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('حذف العادة'),
            content: Text('هل أنت متأكد من حذف "${habit.name}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<HabitsCubit>().deleteHabit(habit.id);
      },
      child: HabitCard(
        habit: habit,
        todayEvent: todayEvent,
        streak: streak,
        weeklyProgress: weeklyProgress,
      ),
    );
  }
}
