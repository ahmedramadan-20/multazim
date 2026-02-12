import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/habit.dart';
import '../cubit/habits_cubit.dart';
import '../../../../core/theme/app_colors.dart';

class CreateHabitPage extends StatefulWidget {
  final Habit? habit;

  const CreateHabitPage({super.key, this.habit});

  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Defaults
  String _icon = '📝';
  Color _color = AppColors.primary;
  HabitCategory _category = HabitCategory.health;
  StrictnessLevel _strictness = StrictnessLevel.medium;

  // Schedule
  HabitScheduleType _scheduleType = HabitScheduleType.daily;
  int _timesPerWeek = 3;

  // Goal
  HabitGoalType _goalType = HabitGoalType.binary;
  int _targetCount = 10;
  String _unit = 'mins';

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      final h = widget.habit!;
      _nameController.text = h.name;
      _icon = h.icon;

      // Parse Color
      try {
        var cStr = h.color;
        if (cStr.startsWith('0x')) cStr = cStr.substring(2);
        _color = Color(int.parse(cStr, radix: 16));
      } catch (_) {
        _color = AppColors.primary;
      }

      _category = h.category;
      _strictness = h.strictness;

      // Schedule
      if (h.schedule.type == HabitScheduleType.daily) {
        _scheduleType = HabitScheduleType.daily;
      } else if (h.schedule.type == HabitScheduleType.timesPerWeek) {
        _scheduleType = HabitScheduleType.timesPerWeek;
        _timesPerWeek = h.schedule.timesPerWeek ?? 3;
      }

      // Goal
      if (h.goal.type == HabitGoalType.binary) {
        _goalType = HabitGoalType.binary;
      } else if (h.goal.type == HabitGoalType.countBased) {
        _goalType = HabitGoalType.countBased;
        _targetCount = h.goal.targetCount ?? 10;
        _unit = h.goal.unit ?? 'mins';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      final schedule = _scheduleType == HabitScheduleType.daily
          ? const HabitSchedule.daily()
          : HabitSchedule.timesPerWeek(_timesPerWeek);

      final goal = _goalType == HabitGoalType.binary
          ? const HabitGoal.binary()
          : HabitGoal.countBased(_targetCount, _unit);

      final newHabit = Habit(
        id: widget.habit?.id ?? const Uuid().v4(), // Preserve ID if editing
        name: _nameController.text,
        icon: _icon,
        color: '0xFF${_color.value.toRadixString(16).padLeft(8, '0')}',
        category: _category,
        schedule: schedule,
        goal: goal,
        difficulty: 1,
        strictness: _strictness,
        startDate:
            widget.habit?.startDate ?? DateTime.now(), // Preserve start date
        createdAt:
            widget.habit?.createdAt ?? DateTime.now(), // Preserve creation date
      );

      if (widget.habit != null) {
        context.read<HabitsCubit>().updateHabit(newHabit);
      } else {
        context.read<HabitsCubit>().createHabit(newHabit);
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habit != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'تعديل عادة' : 'عادة جديدة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon + Name Row
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        const emojis = [
                          '📝',
                          '🏋️',
                          '💧',
                          '📚',
                          '🧘',
                          '💰',
                          '🚭',
                        ];
                        _icon =
                            emojis[(emojis.indexOf(_icon) + 1) % emojis.length];
                      });
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(_icon, style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم العادة',
                        hintText: 'مثال: قراءة القرآن',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category
              DropdownButtonFormField<HabitCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'التصنيف'),
                items: HabitCategory.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),

              // Strictness
              DropdownButtonFormField<StrictnessLevel>(
                initialValue: _strictness,
                decoration: const InputDecoration(labelText: 'الصرامة'),
                items: StrictnessLevel.values.map((l) {
                  return DropdownMenuItem(
                    value: l,
                    child: Text(l.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _strictness = v!),
              ),
              const SizedBox(height: 16),

              // Color Picker
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      [
                        AppColors.primary,
                        AppColors.accent,
                        AppColors.success,
                        AppColors.warning,
                        AppColors.danger,
                        Colors.pink,
                        Colors.teal,
                      ].map((c) {
                        return GestureDetector(
                          onTap: () => setState(() => _color = c),
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: _color == c
                                  ? Border.all(color: Colors.black, width: 3)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Schedule Type
              const Text(
                'التكرار',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<HabitScheduleType>(
                      title: const Text('يومي'),
                      value: HabitScheduleType.daily,
                      groupValue: _scheduleType,
                      onChanged: (v) => setState(() => _scheduleType = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<HabitScheduleType>(
                      title: const Text('أسبوعي'),
                      value: HabitScheduleType.timesPerWeek,
                      groupValue: _scheduleType,
                      onChanged: (v) => setState(() => _scheduleType = v!),
                    ),
                  ),
                ],
              ),
              if (_scheduleType == HabitScheduleType.timesPerWeek)
                Slider(
                  value: _timesPerWeek.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  label: '$_timesPerWeek مرات',
                  onChanged: (v) => setState(() => _timesPerWeek = v.round()),
                ),

              const SizedBox(height: 16),
              const Text(
                'الهدف',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<HabitGoalType>(
                      title: const Text('نعم/لا'),
                      value: HabitGoalType.binary,
                      groupValue: _goalType,
                      onChanged: (v) => setState(() => _goalType = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<HabitGoalType>(
                      title: const Text('رقمي'),
                      value: HabitGoalType.countBased,
                      groupValue: _goalType,
                      onChanged: (v) => setState(() => _goalType = v!),
                    ),
                  ),
                ],
              ),
              if (_goalType == HabitGoalType.countBased)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _targetCount.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'العدد'),
                        onChanged: (v) =>
                            setState(() => _targetCount = int.tryParse(v) ?? 1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _unit,
                        decoration: const InputDecoration(labelText: 'الوحدة'),
                        onChanged: (v) => setState(() => _unit = v),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 32),
              FilledButton(
                onPressed: _saveHabit,
                child: Text(isEditing ? 'حفظ التعديلات' : 'حفظ العادة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
