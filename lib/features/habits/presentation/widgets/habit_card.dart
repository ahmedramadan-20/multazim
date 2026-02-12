import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../cubit/habits_cubit.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final HabitEvent? todayEvent; // null if not done today

  const HabitCard({super.key, required this.habit, this.todayEvent});

  bool get isCompleted => todayEvent?.status == HabitEventStatus.completed;
  bool get isSkipped => todayEvent?.status == HabitEventStatus.skipped;

  @override
  Widget build(BuildContext context) {
    Color habitColor;
    try {
      // Remove '0x' prefix if present before parsing
      var colorString = habit.color;
      if (colorString.startsWith('0x')) {
        colorString = colorString.substring(2);
      }
      habitColor = Color(int.parse(colorString, radix: 16));
    } catch (e) {
      habitColor = AppColors.primary; // Fallback
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: isCompleted ? 0 : 2,
      color: isCompleted ? habitColor.withOpacity(0.1) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCompleted
            ? BorderSide(color: habitColor.withOpacity(0.5))
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (!isCompleted && !isSkipped) {
            context.read<HabitsCubit>().completeHabit(habit.id);
          }
        },
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('تعديل العادة'),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push(AppRoutes.createHabit, extra: habit);
                    },
                  ),
                  if (!isCompleted && !isSkipped)
                    ListTile(
                      leading: const Icon(Icons.skip_next),
                      title: const Text('تخطي اليوم'),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.read<HabitsCubit>().skipHabit(habit.id);
                      },
                    ),
                  // Delete is handled by Swipe, but we can add it here too for accessibility
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'حذف',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      // Trigger delete confirmation dialog from here?
                      // Or just call delete directly? Swipe has confirmation.
                      // Let's reuse the confirmation dialog logic if possible,
                      // but for now simple delete with dialog.
                      showDialog(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('حذف العادة'),
                          content: Text('هل أنت متأكد من حذف "${habit.name}"؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx),
                              child: const Text('إلغاء'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<HabitsCubit>().deleteHabit(
                                  habit.id,
                                );
                                Navigator.pop(dCtx);
                              },
                              child: const Text(
                                'حذف',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(habit.icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),

              // Name & Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted || isSkipped
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompleted || isSkipped
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      habit.category.name.toUpperCase(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Status Icon
              if (isCompleted)
                Icon(Icons.check_circle, color: habitColor, size: 32)
              else if (isSkipped)
                const Icon(Icons.skip_next, color: Colors.grey, size: 32)
              else
                Icon(Icons.circle_outlined, color: Colors.grey[300], size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
