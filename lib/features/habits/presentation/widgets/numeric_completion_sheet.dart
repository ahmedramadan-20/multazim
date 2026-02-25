import 'package:flutter/material.dart';
import '../../domain/entities/habit.dart';

class NumericCompletionSheet extends StatefulWidget {
  final Habit habit;
  final int? previousValue;

  const NumericCompletionSheet({
    super.key,
    required this.habit,
    this.previousValue,
  });

  @override
  State<NumericCompletionSheet> createState() => _NumericCompletionSheetState();
}

class _NumericCompletionSheetState extends State<NumericCompletionSheet> {
  late int _currentValue;
  late int _targetValue;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _targetValue = (widget.habit.goal.targetValue ?? 1.0).round();
    _currentValue = widget.previousValue ?? 0;
    _controller.text = _currentValue.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _progress => (_currentValue / _targetValue).clamp(0.0, 1.0);

  bool get _goalReached => _currentValue >= _targetValue;

  void _increment(int amount) {
    setState(() {
      _currentValue = (_currentValue + amount).clamp(0, _targetValue * 10);
      _controller.text = _currentValue.toString();
    });
  }

  void _onTextChanged(String value) {
    setState(() {
      _currentValue = int.tryParse(value) ?? _currentValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unit = widget.habit.goal.unit ?? '';
    final habitColor = _parseColor(widget.habit.color);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Habit name + target
          Text(
            widget.habit.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'الهدف: $_targetValue $unit',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 12,
              backgroundColor: habitColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                _goalReached ? Colors.green : habitColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_currentValue / $_targetValue $unit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _goalReached ? Colors.green : habitColor,
                ),
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Input row
          Row(
            children: [
              // Quick decrement
              _QuickButton(
                label: '-$_quickStep',
                onTap: () => _increment(-_quickStep),
                color: colorScheme.errorContainer,
                textColor: colorScheme.error,
              ),
              const SizedBox(width: 12),

              // Manual input
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixText: unit,
                  ),
                  onChanged: _onTextChanged,
                ),
              ),
              const SizedBox(width: 12),

              // Quick increment
              _QuickButton(
                label: '+$_quickStep',
                onTap: () => _increment(_quickStep),
                color: habitColor.withValues(alpha: 0.15),
                textColor: habitColor,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quick add buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: {_quickStep * 2, _quickStep * 5, _targetValue}
                .map(
                  (v) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      label: Text('+$v'),
                      onPressed: () => _increment(v),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),

          // Save button
          FilledButton.icon(
            onPressed: _currentValue > 0
                ? () => Navigator.pop(context, _currentValue)
                : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: _goalReached ? Colors.green : habitColor,
            ),
            icon: Icon(_goalReached ? Icons.check_circle : Icons.save_outlined),
            label: Text(
              _goalReached ? 'تم! الهدف مكتمل 🎉' : 'حفظ التقدم',
              style: const TextStyle(fontSize: 16),
            ),
          ),

          if (!_goalReached) ...[
            const SizedBox(height: 8),
            Text(
              'سيُحفظ كتقدم جزئي — الهدف لم يكتمل بعد',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  int get _quickStep {
    if (_targetValue <= 10) return 1;
    if (_targetValue <= 100) return 10;
    if (_targetValue <= 1000) return 100;
    return 250;
  }

  Color _parseColor(String colorString) {
    try {
      var hex = colorString;
      if (hex.startsWith('0x')) hex = hex.substring(2);
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.blue;
    }
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  const _QuickButton({
    required this.label,
    required this.onTap,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
