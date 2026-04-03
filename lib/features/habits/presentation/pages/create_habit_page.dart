import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/habit.dart';
import '../cubit/habits_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../helpers/habit_translation_helper.dart';
import 'package:intl/intl.dart';

class CreateHabitPage extends StatefulWidget {
  final Habit? habit;
  const CreateHabitPage({super.key, this.habit});

  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _icon = '📝';
  Color _color = AppColors.primary;
  HabitCategory _category = HabitCategory.worship;
  StrictnessLevel _strictness = StrictnessLevel.medium;
  HabitScheduleType _scheduleType = HabitScheduleType.daily;
  int _timesPerWeek = 3;
  HabitGoalType _goalType = HabitGoalType.binary;
  final _targetValueController = TextEditingController(text: '10');
  final _unitController = TextEditingController(text: 'دقيقة');
  int _difficulty = 3;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  HabitReminderTime? _reminderTime;

  static const List<String> _emojis = [
    '📝',
    '🏋️',
    '💧',
    '📚',
    '🧘',
    '💰',
    '🚭',
    '🕌',
    '❤️',
    '💪',
    '🧠',
    '💼',
    '👥',
    '✨',
    '🥗',
    '🎨',
    '📌',
    '⭐',
    '🌙',
    '🔥',
  ];

  static const List<Color> _colors = [
    AppColors.primary,
    AppColors.accent,
    AppColors.success,
    AppColors.warning,
    AppColors.danger,
    Color(0xFF0EA5E9), // sky
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
    Color(0xFF14B8A6), // teal
    Color(0xFFF97316), // orange
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      final h = widget.habit!;
      _nameController.text = h.name;
      _icon = h.icon;
      _difficulty = h.difficulty;
      _startDate = h.startDate;
      _endDate = h.endDate;
      _category = h.category;
      _strictness = h.strictness;
      _scheduleType = h.schedule.type;
      _timesPerWeek = h.schedule.timesPerWeek ?? 3;
      _goalType = h.goal.type;
      _reminderTime = h.reminderTime;

      try {
        var cStr = h.color;
        if (cStr.startsWith('0x')) cStr = cStr.substring(2);
        _color = Color(int.parse(cStr, radix: 16));
      } catch (_) {
        _color = AppColors.primary;
      }

      if (h.goal.type == HabitGoalType.numeric) {
        _targetValueController.text = h.goal.targetValue?.toString() ?? '';
        _unitController.text = h.goal.unit ?? '';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetValueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;

    final schedule = switch (_scheduleType) {
      HabitScheduleType.daily => const HabitSchedule.daily(),
      HabitScheduleType.timesPerWeek => HabitSchedule.timesPerWeek(
        _timesPerWeek,
      ),
      HabitScheduleType.customDays => const HabitSchedule.daily(),
    };

    final goal = _goalType == HabitGoalType.binary
        ? const HabitGoal.binary()
        : HabitGoal.numeric(
            double.tryParse(_targetValueController.text) ?? 1.0,
            _unitController.text,
          );

    final colorHex =
        '0xFF${_color.toARGB32().toRadixString(16).padLeft(8, '0')}';

    final newHabit = Habit(
      id: widget.habit?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      icon: _icon,
      color: colorHex,
      category: _category,
      schedule: schedule,
      goal: goal,
      difficulty: _difficulty,
      strictness: _strictness,
      startDate: _startDate,
      endDate: _endDate,
      createdAt: widget.habit?.createdAt ?? DateTime.now(),
      version: (widget.habit?.version ?? 0) + 1,
      reminderTime: _reminderTime,
    );

    if (widget.habit != null) {
      context.read<HabitsCubit>().updateHabit(newHabit);
    } else {
      context.read<HabitsCubit>().createHabit(newHabit);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habit != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل عادة' : 'عادة جديدة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Icon + Name ───────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showIconPicker(context),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _color.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(_icon, style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'اسم العادة',
                        hintText: 'مثال: قراءة القرآن',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Category ──────────────────────────
              DropdownButtonFormField<HabitCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'التصنيف',
                  border: OutlineInputBorder(),
                ),
                items: HabitCategory.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Text(HabitTranslationHelper.categoryIcon(c)),
                        const SizedBox(width: 10),
                        Text(HabitTranslationHelper.categoryName(c)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),

              // ── Strictness ────────────────────────
              DropdownButtonFormField<StrictnessLevel>(
                initialValue: _strictness,
                decoration: const InputDecoration(
                  labelText: 'الصرامة',
                  border: OutlineInputBorder(),
                ),
                items: StrictnessLevel.values.map((l) {
                  return DropdownMenuItem(
                    value: l,
                    child: Text(HabitTranslationHelper.strictnessName(l)),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _strictness = v!),
              ),
              const SizedBox(height: 6),
              Text(
                HabitTranslationHelper.strictnessDescription(_strictness),
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // ── Color Picker ──────────────────────
              Text('اللون', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _colors.map((c) {
                    final isSelected = _color.toARGB32() == c.toARGB32();
                    return GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: colorScheme.outline, width: 3)
                              : Border.all(color: Colors.transparent, width: 3),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: c.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // ── Difficulty ────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الصعوبة',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    _difficultyLabel(_difficulty),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _difficulty.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _difficultyLabel(_difficulty),
                onChanged: (v) => setState(() => _difficulty = v.round()),
              ),

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 16),

              // ── Schedule ──────────────────────────
              Text(
                'التكرار',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ScheduleChip(
                      label: 'يومي',
                      icon: Icons.repeat,
                      selected: _scheduleType == HabitScheduleType.daily,
                      onTap: () => setState(
                        () => _scheduleType = HabitScheduleType.daily,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ScheduleChip(
                      label: 'أسبوعي',
                      icon: Icons.date_range,
                      selected: _scheduleType == HabitScheduleType.timesPerWeek,
                      onTap: () => setState(
                        () => _scheduleType = HabitScheduleType.timesPerWeek,
                      ),
                    ),
                  ),
                ],
              ),
              if (_scheduleType == HabitScheduleType.timesPerWeek) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('المرات أسبوعياً'),
                    Text(
                      '$_timesPerWeek مرات',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _timesPerWeek.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  label: '$_timesPerWeek',
                  onChanged: (v) => setState(() => _timesPerWeek = v.round()),
                ),
              ],

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 16),

              // ── Goal Type ─────────────────────────
              Text(
                'نوع الهدف',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ScheduleChip(
                      label: 'صح / خطأ',
                      icon: Icons.check_circle_outline,
                      selected: _goalType == HabitGoalType.binary,
                      onTap: () =>
                          setState(() => _goalType = HabitGoalType.binary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ScheduleChip(
                      label: 'رقمي',
                      icon: Icons.numbers,
                      selected: _goalType == HabitGoalType.numeric,
                      onTap: () =>
                          setState(() => _goalType = HabitGoalType.numeric),
                    ),
                  ),
                ],
              ),
              if (_goalType == HabitGoalType.numeric) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _targetValueController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'القيمة المستهدفة',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'مطلوب' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          labelText: 'الوحدة',
                          hintText: 'مثال: دقيقة، صفحة',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 16),

              // ── Dates ─────────────────────────────
              Text(
                'التاريخ',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('تاريخ البدء'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    if (!mounted) return;
                    setState(() => _startDate = picked);
                  }
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('تحديد تاريخ انتهاء'),
                value: _endDate != null,
                onChanged: (v) {
                  setState(() {
                    _endDate = v
                        ? DateTime.now().add(const Duration(days: 30))
                        : null;
                  });
                },
              ),
              if (_endDate != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('تاريخ الانتهاء'),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(_endDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate!,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      if (!mounted) return;
                      setState(() => _endDate = picked);
                    }
                  },
                ),

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 16),

              // ── Reminder ──────────────────────────
              Text(
                'التذكير اليومي',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _ReminderTile(
                reminderTime: _reminderTime,
                onSet: (time) => setState(() => _reminderTime = time),
                onClear: () => setState(() => _reminderTime = null),
              ),

              const SizedBox(height: 32),

              // ── Save Button ───────────────────────
              FilledButton.icon(
                onPressed: _saveHabit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(
                  isEditing ? 'حفظ التعديلات' : 'حفظ العادة',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showIconPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اختر أيقونة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _emojis.map((emoji) {
                final isSelected = _icon == emoji;
                return GestureDetector(
                  onTap: () {
                    setState(() => _icon = emoji);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _color.withValues(alpha: 0.2)
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: _color, width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 26)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _difficultyLabel(int level) {
    return switch (level) {
      1 => 'سهل جداً',
      2 => 'سهل',
      3 => 'متوسط',
      4 => 'صعب',
      5 => 'صعب جداً',
      _ => '$level',
    };
  }
}

// ─────────────────────────────────────────────────
// REMINDER TILE
// ─────────────────────────────────────────────────

class _ReminderTile extends StatelessWidget {
  final HabitReminderTime? reminderTime;
  final ValueChanged<HabitReminderTime> onSet;
  final VoidCallback onClear;

  const _ReminderTile({
    required this.reminderTime,
    required this.onSet,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSet = reminderTime != null;

    return Container(
      decoration: BoxDecoration(
        color: isSet
            ? colorScheme.primaryContainer.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: isSet
            ? Border.all(color: colorScheme.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: ListTile(
        leading: Icon(
          Icons.notifications_outlined,
          color: isSet ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          isSet ? 'تذكير يومي على ${reminderTime!.display}' : 'بدون تذكير',
          style: TextStyle(
            color: isSet ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: isSet ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: isSet
            ? Text(
                'سيصلك تنبيه كل يوم في هذا الوقت',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: isSet
            ? IconButton(
                icon: Icon(Icons.close, color: colorScheme.error, size: 20),
                onPressed: onClear,
                tooltip: 'إلغاء التذكير',
              )
            : Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: reminderTime != null
                ? TimeOfDay(
                    hour: reminderTime!.hour,
                    minute: reminderTime!.minute,
                  )
                : const TimeOfDay(hour: 8, minute: 0),
            helpText: 'اختر وقت التذكير',
            builder: (context, child) => Directionality(
              textDirection: ui.TextDirection.rtl,
              child: child!,
            ),
          );
          if (picked != null) {
            onSet(HabitReminderTime(hour: picked.hour, minute: picked.minute));
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// SCHEDULE / GOAL CHIP
// ─────────────────────────────────────────────────

class _ScheduleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ScheduleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
