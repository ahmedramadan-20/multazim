import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:multazim/features/habits/domain/entities/habit.dart';
import 'package:path_provider/path_provider.dart';
import '../../../features/habits/domain/entities/habit_event.dart';
import '../entities/export_config.dart';

class ExportService {
  Future<String> export({
    required ExportConfig config,
    required List<Habit> habits,
    required List<HabitEvent> events,
  }) async {
    final filteredEvents = events.where((e) {
      return !e.date.isBefore(config.resolvedStart) &&
          !e.date.isAfter(config.resolvedEnd);
    }).toList();

    final filteredHabits = config.habitId != null
        ? habits.where((h) => h.id == config.habitId).toList()
        : habits;

    return switch (config.format) {
      ExportFormat.csv => await _exportCsv(filteredHabits, filteredEvents),
      ExportFormat.excel => await _exportExcel(filteredHabits, filteredEvents),
      ExportFormat.json => await _exportJson(filteredHabits, filteredEvents),
    };
  }

  // ─────────────────────────────────────────────────
  // CSV
  // ─────────────────────────────────────────────────

  Future<String> _exportCsv(List<Habit> habits, List<HabitEvent> events) async {
    final habitMap = {for (var h in habits) h.id: h};

    final rows = <List<dynamic>>[
      ['habit_name', 'category', 'date', 'status', 'note', 'fail_reason'],
    ];

    for (final event in events) {
      final habit = habitMap[event.habitId];
      if (habit == null) continue;

      rows.add([
        habit.name,
        _categoryArabic(habit.category),
        _formatDate(event.date),
        _statusArabic(event.status),
        event.note ?? '',
        event.failReason ?? '',
      ]);
    }

    final csvString = csv.encode(rows);
    return await _writeFile('multazim_export.csv', csvString);
  }

  // ─────────────────────────────────────────────────
  // EXCEL
  // ─────────────────────────────────────────────────

  Future<String> _exportExcel(
    List<Habit> habits,
    List<HabitEvent> events,
  ) async {
    final excelFile = Excel.createExcel();

    // ── Sheet 1: Events ───────────────────────────
    final eventsSheet = excelFile['الأحداث'];
    excelFile.setDefaultSheet('الأحداث');

    final eventHeaders = [
      'اسم العادة',
      'الفئة',
      'التاريخ',
      'الحالة',
      'ملاحظة',
      'سبب الفشل',
    ];

    // Header row with bold style
    for (var i = 0; i < eventHeaders.length; i++) {
      final cell = eventsSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(eventHeaders[i]);
      cell.cellStyle = CellStyle(bold: true);
    }

    // Column widths for events sheet
    eventsSheet.setColumnWidth(0, 28); // habit name
    eventsSheet.setColumnWidth(1, 16); // category
    eventsSheet.setColumnWidth(2, 14); // date
    eventsSheet.setColumnWidth(3, 14); // status
    eventsSheet.setColumnWidth(4, 22); // note
    eventsSheet.setColumnWidth(5, 22); // fail reason

    final habitMap = {for (var h in habits) h.id: h};
    var row = 1;

    for (final event in events) {
      final habit = habitMap[event.habitId];
      if (habit == null) continue;

      final rowData = [
        habit.name,
        _categoryArabic(habit.category),
        _formatDate(event.date),
        _statusArabic(event.status),
        event.note ?? '',
        event.failReason ?? '',
      ];

      for (var col = 0; col < rowData.length; col++) {
        eventsSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
            .value = TextCellValue(
          rowData[col],
        );
      }
      row++;
    }

    // ── Sheet 2: Habits Summary ───────────────────
    final habitsSheet = excelFile['العادات'];
    final habitHeaders = ['الاسم', 'الفئة', 'نوع الجدول', 'الصعوبة', 'نشط'];

    for (var i = 0; i < habitHeaders.length; i++) {
      final cell = habitsSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(habitHeaders[i]);
      cell.cellStyle = CellStyle(bold: true);
    }

    // Column widths for habits sheet
    habitsSheet.setColumnWidth(0, 28); // name
    habitsSheet.setColumnWidth(1, 16); // category
    habitsSheet.setColumnWidth(2, 16); // schedule type
    habitsSheet.setColumnWidth(3, 12); // difficulty
    habitsSheet.setColumnWidth(4, 10); // active

    for (var i = 0; i < habits.length; i++) {
      final h = habits[i];
      final rowData = [
        h.name,
        _categoryArabic(h.category),
        _scheduleArabic(h.schedule.type),
        '${h.difficulty} / 5',
        h.isActive ? 'نعم' : 'لا',
      ];

      for (var col = 0; col < rowData.length; col++) {
        habitsSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i + 1))
            .value = TextCellValue(
          rowData[col],
        );
      }
    }

    excelFile.delete('Sheet1');

    final bytes = excelFile.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/multazim_export.xlsx';
    await File(path).writeAsBytes(bytes);
    return path;
  }

  // ─────────────────────────────────────────────────
  // JSON
  // ─────────────────────────────────────────────────

  Future<String> _exportJson(
    List<Habit> habits,
    List<HabitEvent> events,
  ) async {
    final data = {
      'exported_at': DateTime.now().toIso8601String(),
      'habits': habits
          .map(
            (h) => {
              'id': h.id,
              'name': h.name,
              'category': _categoryArabic(h.category),
              'schedule_type': _scheduleArabic(h.schedule.type),
              'difficulty': h.difficulty,
              'is_active': h.isActive,
              'created_at': h.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'events': events
          .map(
            (e) => {
              'habit_id': e.habitId,
              'date': _formatDate(e.date),
              'status': _statusArabic(e.status),
              'note': e.note,
              'fail_reason': e.failReason,
            },
          )
          .toList(),
    };

    return await _writeFile(
      'multazim_export.json',
      const JsonEncoder.withIndent('  ').convert(data),
    );
  }

  // ─────────────────────────────────────────────────
  // TRANSLATION HELPERS
  // ─────────────────────────────────────────────────

  String _categoryArabic(HabitCategory category) {
    return switch (category) {
      HabitCategory.worship => 'عبادة',
      HabitCategory.health => 'صحة',
      HabitCategory.fitness => 'لياقة',
      HabitCategory.mind => 'ذهن',
      HabitCategory.learning => 'تعلم',
      HabitCategory.work => 'عمل',
      HabitCategory.finance => 'مالية',
      HabitCategory.social => 'اجتماعي',
      HabitCategory.selfCare => 'عناية ذاتية',
      HabitCategory.nutrition => 'تغذية',
      HabitCategory.creativity => 'إبداع',
      HabitCategory.other => 'أخرى',
    };
  }

  String _statusArabic(HabitEventStatus status) {
    return switch (status) {
      HabitEventStatus.completed => 'مكتمل',
      HabitEventStatus.skipped => 'متخطى',
      HabitEventStatus.failed => 'فشل',
      HabitEventStatus.missed => 'فائت',
    };
  }

  String _scheduleArabic(HabitScheduleType type) {
    return switch (type) {
      HabitScheduleType.daily => 'يومي',
      HabitScheduleType.timesPerWeek => 'أسبوعي',
      HabitScheduleType.customDays => 'أيام مخصصة',
    };
  }

  // ─────────────────────────────────────────────────
  // FILE HELPERS
  // ─────────────────────────────────────────────────

  Future<String> _writeFile(String filename, String content) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$filename';
    await File(path).writeAsString(content);
    return path;
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
