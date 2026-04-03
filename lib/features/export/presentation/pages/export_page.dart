import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/export_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/export_cubit.dart';
import '../cubit/export_state.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  ExportDateRange _selectedRange = ExportDateRange.last30Days;
  DateTime? _customStart;
  DateTime? _customEnd;

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      builder: (context, child) =>
          Theme(data: Theme.of(context), child: child!),
    );
    // ✅ FIX: mounted check after await
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        _customStart = picked.start;
        _customEnd = picked.end;
        _selectedRange = ExportDateRange.custom;
      });
    }
  }

  void _export() {
    if (_selectedRange == ExportDateRange.custom &&
        (_customStart == null || _customEnd == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار نطاق التاريخ')));
      return;
    }

    context.read<ExportCubit>().exportData(
      ExportConfig(
        format: _selectedFormat,
        dateRange: _selectedRange,
        customStart: _customStart,
        customEnd: _customEnd,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<ExportCubit, ExportState>(
      listener: (context, state) {
        if (state is ExportSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم التصدير بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is ExportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('تصدير البيانات'), centerTitle: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Format Selection ─────────────────
              Text(
                'صيغة التصدير',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: ExportFormat.values.map((format) {
                  final isSelected = _selectedFormat == format;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFormat = format),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: colorScheme.primary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _formatIcon(format),
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatLabel(format),
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // ── Date Range Selection ──────────────
              Text(
                'نطاق التاريخ',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...ExportDateRange.values.map((range) {
                return RadioListTile<ExportDateRange>(
                  value: range,
                  groupValue: _selectedRange,
                  title: Text(_rangeLabel(range)),
                  subtitle:
                      range == ExportDateRange.custom &&
                          _customStart != null &&
                          _customEnd != null
                      ? Text(
                          '${DateFormat.yMMMd('ar').format(_customStart!)} — ${DateFormat.yMMMd('ar').format(_customEnd!)}',
                          style: TextStyle(color: colorScheme.primary),
                        )
                      : null,
                  onChanged: (value) async {
                    if (value == ExportDateRange.custom) {
                      await _pickCustomRange();
                    } else {
                      setState(() => _selectedRange = value!);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }),
              const SizedBox(height: 32),

              // ── Export Button ─────────────────────
              BlocBuilder<ExportCubit, ExportState>(
                builder: (context, state) {
                  final isLoading = state is ExportLoading;
                  return FilledButton.icon(
                    onPressed: isLoading ? null : _export,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.surface,
                            ),
                          )
                        : const Icon(Icons.upload_file_rounded),
                    label: Text(
                      isLoading ? 'جاري التصدير...' : 'تصدير ومشاركة',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _formatIcon(ExportFormat format) {
    return switch (format) {
      ExportFormat.csv => Icons.table_rows_rounded,
      ExportFormat.excel => Icons.grid_on_rounded,
      ExportFormat.json => Icons.data_object_rounded,
    };
  }

  String _formatLabel(ExportFormat format) {
    return switch (format) {
      ExportFormat.csv => 'CSV',
      ExportFormat.excel => 'Excel',
      ExportFormat.json => 'JSON',
    };
  }

  String _rangeLabel(ExportDateRange range) {
    return switch (range) {
      ExportDateRange.last7Days => 'آخر 7 أيام',
      ExportDateRange.last30Days => 'آخر 30 يوم',
      ExportDateRange.last90Days => 'آخر 90 يوم',
      ExportDateRange.allTime => 'كل الوقت',
      ExportDateRange.custom => 'نطاق مخصص',
    };
  }
}
