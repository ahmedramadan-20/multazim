import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../../domain/entities/streak.dart';
import '../cubit/habits_cubit.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../helpers/habit_translation_helper.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final HabitEvent? todayEvent;
  final StreakState? streak;
  final ({int current, int target})? weeklyProgress;

  const HabitCard({
    super.key,
    required this.habit,
    this.todayEvent,
    this.streak,
    this.weeklyProgress,
  });

  bool get isCompleted => todayEvent?.status == HabitEventStatus.completed;
  bool get isSkipped => todayEvent?.status == HabitEventStatus.skipped;

  /// Parses a color string (e.g. "0xFF4CAF50") into a
  /// [Color]. Returns [AppColors.primary] on failure.
  static Color parseHabitColor(String colorString) {
    try {
      var hex = colorString;
      if (hex.startsWith('0x')) hex = hex.substring(2);
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = parseHabitColor(habit.color);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: isCompleted ? 0 : 2,
      color: isCompleted ? habitColor.withValues(alpha: 0.1) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCompleted
            ? BorderSide(color: habitColor.withValues(alpha: 0.5))
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
                  color: habitColor.withValues(alpha: 0.2),
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
                      HabitTranslationHelper.categoryName(habit.category),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (weeklyProgress != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value:
                                    weeklyProgress!.current /
                                    weeklyProgress!.target,
                                backgroundColor: habitColor.withValues(
                                  alpha: 0.1,
                                ),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  habitColor.withValues(alpha: 0.7),
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${weeklyProgress!.current}/${weeklyProgress!.target}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Streak Badge
              if (streak != null && streak!.current > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '${streak!.current}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

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
