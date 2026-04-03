import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../habits/domain/repositories/habit_repository.dart';
import '../../domain/entities/export_config.dart';
import '../../domain/services/export_service.dart';
import 'export_state.dart';

class ExportCubit extends Cubit<ExportState> {
  final HabitRepository _habitRepository;
  final ExportService _exportService;

  ExportCubit({
    required HabitRepository habitRepository,
    required ExportService exportService,
  }) : _habitRepository = habitRepository,
       _exportService = exportService,
       super(ExportInitial());

  Future<void> exportData(ExportConfig config) async {
    emit(ExportLoading());
    try {
      final habits = await _habitRepository.getHabits();
      final events = await _habitRepository.getAllEvents();

      final filePath = await _exportService.export(
        config: config,
        habits: habits,
        events: events,
      );

      await SharePlus.instance.share(
        ShareParams(files: [XFile(filePath)], title: 'تصدير بيانات ملتزم'),
      );

      emit(ExportSuccess(filePath));
    } catch (e) {
      emit(ExportError('فشل التصدير: $e'));
    }
  }
}
