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
  final _targetValueController = TextEditingController(text: '10');
  final _unitController = TextEditingController(text: 'دقيقة');

  int _difficulty = 3;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

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

      // Schedule (Frequency)
      _scheduleType = h.schedule.type;
      _timesPerWeek = h.schedule.timesPerWeek ?? 3;

      // Goal (Quantitative)
      _goalType = h.goal.type;
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
    if (_formKey.currentState!.validate()) {
      // 1. Determine Schedule
      final schedule = switch (_scheduleType) {
        HabitScheduleType.daily => const HabitSchedule.daily(),
        HabitScheduleType.timesPerWeek => HabitSchedule.timesPerWeek(
          _timesPerWeek,
        ),
        HabitScheduleType.customDays =>
          const HabitSchedule.daily(), // Placeholder
      };

      // 2. Determine Goal
      final goal = _goalType == HabitGoalType.binary
          ? const HabitGoal.binary()
          : HabitGoal.numeric(
              double.tryParse(_targetValueController.text) ?? 1.0,
              _unitController.text,
            );

      final newHabit = Habit(
        id: widget.habit?.id ?? const Uuid().v4(),
        name: _nameController.text,
        icon: _icon,
        color: '0xFF${_color.value.toRadixString(16).padLeft(8, '0')}',
        category: _category,
        schedule: schedule,
        goal: goal,
        difficulty: _difficulty,
        strictness: _strictness,
        startDate: _startDate,
        endDate: _endDate,
        createdAt: widget.habit?.createdAt ?? DateTime.now(),
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
                    child: Text(HabitTranslationHelper.categoryName(c)),
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
                    child: Text(HabitTranslationHelper.strictnessName(l)),
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

              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الصعوبة: $_difficulty / 5'),
                  Slider(
                    value: _difficulty.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$_difficulty',
                    onChanged: (v) => setState(() => _difficulty = v.round()),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Unified Frequency
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الهدف الأسبوعي: $_timesPerWeek مرات'),
                      Slider(
                        value: _timesPerWeek.toDouble(),
                        min: 1,
                        max: 7,
                        divisions: 6,
                        label: '$_timesPerWeek مرات',
                        onChanged: (v) =>
                            setState(() => _timesPerWeek = v.round()),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Completion Type (Goal)
              const Text(
                'نوع الهدف',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<HabitGoalType>(
                      title: const Text('صح/خطأ'),
                      value: HabitGoalType.binary,
                      groupValue: _goalType,
                      onChanged: (v) => setState(() => _goalType = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<HabitGoalType>(
                      title: const Text('رقمي'),
                      value: HabitGoalType.numeric,
                      groupValue: _goalType,
                      onChanged: (v) => setState(() => _goalType = v!),
                    ),
                  ),
                ],
              ),

              if (_goalType == HabitGoalType.numeric)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _targetValueController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'القيمة المستهدفة',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _unitController,
                          decoration: const InputDecoration(
                            labelText: 'الوحدة (مثلاً: مل، صفحة)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'التاريخ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
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
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),
              SwitchListTile(
                title: const Text('تاريخ الانتهاء (اختياري)'),
                value: _endDate != null,
                onChanged: (v) {
                  setState(() {
                    if (v) {
                      _endDate = DateTime.now().add(const Duration(days: 30));
                    } else {
                      _endDate = null;
                    }
                  });
                },
              ),
              if (_endDate != null)
                ListTile(
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
                    if (picked != null) setState(() => _endDate = picked);
                  },
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
