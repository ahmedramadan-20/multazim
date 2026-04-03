import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../../domain/entities/streak.dart';
import '../cubit/habits_cubit.dart';
import '../widgets/numeric_completion_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../helpers/habit_translation_helper.dart';

class HabitCard extends StatefulWidget {
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

  static final _timeFormatter = DateFormat('h:mm a', 'ar');

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
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.93,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.93,
          end: 1.03,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.03,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  bool get isCompleted =>
      widget.todayEvent?.status == HabitEventStatus.completed;
  bool get isSkipped => widget.todayEvent?.status == HabitEventStatus.skipped;
  bool get _isNumeric => widget.habit.goal.type == HabitGoalType.numeric;
  int get _numericTarget => (widget.habit.goal.targetValue ?? 1.0).round();
  int get _currentCount => widget.todayEvent?.countValue ?? 0;
  bool get _numericGoalReached => _isNumeric && _currentCount >= _numericTarget;
  bool get _effectivelyCompleted =>
      isCompleted && (!_isNumeric || _numericGoalReached);

  /// Returns a short "آخر إنجاز" string if completed today
  String? get _lastCompletedLabel {
    if (widget.todayEvent == null) return null;
    if (!isCompleted && !isSkipped) return null;
    final time = widget.todayEvent!.createdAt;
    return HabitCard._timeFormatter.format(time);
  }

  Future<void> _handleTap(BuildContext context) async {
    if (_effectivelyCompleted || isSkipped) return;

    _controller.forward(from: 0);

    if (_isNumeric) {
      final result = await showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        builder: (_) => NumericCompletionSheet(
          habit: widget.habit,
          previousValue: _currentCount,
        ),
      );
      if (result != null && context.mounted) {
        context.read<HabitsCubit>().completeHabit(
          widget.habit.id,
          countValue: result,
        );
        if (result >= _numericTarget) {
          _confettiController.play();
        }
      }
    } else {
      context.read<HabitsCubit>().completeHabit(widget.habit.id);
      _confettiController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = HabitCard.parseHabitColor(widget.habit.color);
    final colorScheme = Theme.of(context).colorScheme;
    final hasStreak =
        widget.streak != null && widget.streak!.current > 0 && !isSkipped;

    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
            elevation: _effectivelyCompleted ? 0 : 1,
            color: _effectivelyCompleted
                ? habitColor.withValues(alpha: 0.08)
                : colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: _effectivelyCompleted
                  ? BorderSide(color: habitColor.withValues(alpha: 0.4))
                  : BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _handleTap(context),
              onLongPress: () => _showOptionsSheet(context),
              child: Padding(
                // ── Reduced padding for compact look ──
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    // ── Icon ──────────────────────────
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: habitColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.habit.icon,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ── Name & Details ────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Name row with streak badge ──
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.habit.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    decoration:
                                        _effectivelyCompleted || isSkipped
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: _effectivelyCompleted || isSkipped
                                        ? colorScheme.onSurfaceVariant
                                        : colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              // ── Streak badge — prominent, next to name ──
                              if (hasStreak) ...[
                                const SizedBox(width: 6),
                                _StreakBadge(
                                  streak: widget.streak!.current,
                                  habitColor: habitColor,
                                ),
                              ],
                            ],
                          ),

                          // ── Category + last completed ──
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                HabitTranslationHelper.categoryName(
                                  widget.habit.category,
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (_lastCompletedLabel != null) ...[
                                Text(
                                  ' · ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Icon(
                                  isSkipped
                                      ? Icons.skip_next_rounded
                                      : Icons.check_rounded,
                                  size: 11,
                                  color: isSkipped
                                      ? AppColors.warning
                                      : habitColor,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _lastCompletedLabel!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSkipped
                                        ? AppColors.warning
                                        : habitColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // ── Numeric progress ──────────
                          if (_isNumeric) ...[
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(
                                        end: (_currentCount / _numericTarget)
                                            .clamp(0.0, 1.0),
                                      ),
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      curve: Curves.easeOut,
                                      builder: (context, value, _) =>
                                          LinearProgressIndicator(
                                            value: value,
                                            backgroundColor: habitColor
                                                .withValues(alpha: 0.1),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  _numericGoalReached
                                                      ? AppColors.success
                                                      : habitColor.withValues(
                                                          alpha: 0.8,
                                                        ),
                                                ),
                                            minHeight: 4,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$_currentCount/$_numericTarget ${widget.habit.goal.unit ?? ''}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _numericGoalReached
                                        ? AppColors.success
                                        : colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // ── Weekly progress ───────────
                          if (!_isNumeric && widget.weeklyProgress != null) ...[
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value:
                                          widget.weeklyProgress!.current /
                                          widget.weeklyProgress!.target,
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
                                  '${widget.weeklyProgress!.current}/${widget.weeklyProgress!.target}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ── Status Icon ───────────────────
                    const SizedBox(width: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.elasticOut,
                        ),
                        child: child,
                      ),
                      child: _buildStatusIcon(habitColor, colorScheme),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: [
            habitColor,
            AppColors.warning,
            AppColors.accent,
            AppColors.success,
          ],
        ),
      ],
    );
  }

  Widget _buildStatusIcon(Color habitColor, ColorScheme colorScheme) {
    if (_effectivelyCompleted) {
      return Icon(
        Icons.check_circle,
        key: const ValueKey('completed'),
        color: habitColor,
        size: 28,
      );
    }
    if (isSkipped) {
      return Icon(
        Icons.skip_next,
        key: const ValueKey('skipped'),
        color: colorScheme.onSurfaceVariant,
        size: 28,
      );
    }
    if (_isNumeric && _currentCount > 0) {
      return SizedBox(
        key: const ValueKey('partial'),
        width: 28,
        height: 28,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: _currentCount / _numericTarget,
              strokeWidth: 3,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(habitColor),
            ),
            Icon(Icons.edit, color: habitColor, size: 11),
          ],
        ),
      );
    }
    return Icon(
      Icons.circle_outlined,
      key: const ValueKey('empty'),
      color: colorScheme.outlineVariant,
      size: 28,
    );
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('عرض التفاصيل'),
              onTap: () {
                Navigator.pop(ctx);
                context.push(AppRoutes.habitDetailPath(widget.habit.id));
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('تعديل العادة'),
              onTap: () {
                Navigator.pop(ctx);
                context.push(AppRoutes.createHabit, extra: widget.habit);
              },
            ),
            if (!_effectivelyCompleted && !isSkipped) ...[
              if (_isNumeric)
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text('تسجيل التقدم'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleTap(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.skip_next_outlined),
                title: const Text('تخطي اليوم'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<HabitsCubit>().skipHabit(widget.habit.id);
                },
              ),
            ],
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'حذف العادة',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    title: const Text('حذف العادة'),
                    content: Text(
                      'هل أنت متأكد من حذف "${widget.habit.name}"؟',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dCtx),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<HabitsCubit>().deleteHabit(
                            widget.habit.id,
                          );
                          Navigator.pop(dCtx);
                        },
                        child: Text(
                          'حذف',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// STREAK BADGE — prominent, pill-shaped
// ─────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  final int streak;
  final Color habitColor;

  const _StreakBadge({required this.streak, required this.habitColor});

  @override
  Widget build(BuildContext context) {
    // Use a warmer fire color for high streaks
    final isHot = streak >= 7;
    final badgeColor = isHot ? AppColors.danger : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔥', style: TextStyle(fontSize: isHot ? 13 : 11)),
          const SizedBox(width: 3),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
