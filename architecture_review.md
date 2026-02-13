# Multazim Architecture Review

## Project Structure
```
lib/core/constants/app_constants.dart
lib/core/constants/env.dart
lib/core/data/objectbox_store.dart
lib/core/di/injection_container.dart
lib/core/error/exceptions.dart
lib/core/error/failures.dart
lib/core/router/app_router.dart
lib/core/router/app_routes.dart
lib/core/theme/app_colors.dart
lib/core/theme/app_theme.dart
lib/core/utils/date_utils.dart
lib/features/analytics/data/repositories/analytics_repository_impl.dart
lib/features/analytics/domain/entities/daily_summary.dart
lib/features/analytics/domain/entities/habit_analytics_snapshot.dart
lib/features/analytics/domain/entities/insight.dart
lib/features/analytics/domain/repositories/analytics_repository.dart
lib/features/analytics/domain/services/insight_generator.dart
lib/features/analytics/presentation/cubit/analytics_cubit.dart
lib/features/analytics/presentation/cubit/analytics_state.dart
lib/features/analytics/presentation/pages/analytics_page.dart
lib/features/analytics/presentation/pages/habit_detail_analytics_page.dart
lib/features/analytics/presentation/widgets/completion_trend_chart.dart
lib/features/analytics/presentation/widgets/heatmap_calendar.dart
lib/features/analytics/presentation/widgets/insight_card.dart
lib/features/analytics/presentation/widgets/statistics_grid.dart
lib/features/habits/data/datasources/local/habit_local_datasource.dart
lib/features/habits/data/datasources/local/objectbox_habit_datasource.dart
lib/features/habits/data/models/habit_event_model.dart
lib/features/habits/data/models/habit_model.dart
lib/features/habits/data/models/milestone_model.dart
lib/features/habits/data/models/streak_repair_model.dart
lib/features/habits/data/repositories/habit_repository_impl.dart
lib/features/habits/domain/entities/habit.dart
lib/features/habits/domain/entities/habit_event.dart
lib/features/habits/domain/entities/milestone.dart
lib/features/habits/domain/entities/streak.dart
lib/features/habits/domain/entities/streak_repair.dart
lib/features/habits/domain/repositories/habit_repository.dart
lib/features/habits/domain/services/milestone_generator.dart
lib/features/habits/domain/services/streak_calculation_service.dart
lib/features/habits/domain/services/streak_mapper.dart
lib/features/habits/domain/services/streak_recovery_service.dart
lib/features/habits/domain/services/streak_service.dart
lib/features/habits/domain/services/weekly_progress_service.dart
lib/features/habits/domain/usecases/complete_habit_usecase.dart
lib/features/habits/domain/usecases/create_habit_usecase.dart
lib/features/habits/domain/usecases/delete_habit_usecase.dart
lib/features/habits/domain/usecases/get_events_for_habit_usecase.dart
lib/features/habits/domain/usecases/get_habits_usecase.dart
lib/features/habits/domain/usecases/get_milestones_usecase.dart
```

## DI Container
```dart
import 'package:get_it/get_it.dart';
import '../../features/habits/data/datasources/local/habit_local_datasource.dart';
import '../../features/habits/data/datasources/local/objectbox_habit_datasource.dart';
import '../../features/habits/data/repositories/habit_repository_impl.dart';
import '../../features/habits/domain/repositories/habit_repository.dart';
import '../../features/habits/domain/usecases/get_habits_usecase.dart';
import '../../features/habits/domain/usecases/create_habit_usecase.dart';
import '../../features/habits/domain/usecases/complete_habit_usecase.dart';
import '../../features/habits/domain/usecases/skip_habit_usecase.dart';
import '../../features/habits/domain/usecases/delete_habit_usecase.dart';
import '../../features/habits/domain/usecases/update_habit_usecase.dart';
import '../../features/habits/domain/usecases/get_today_event_usecase.dart';
import '../../features/habits/domain/usecases/get_events_for_habit_usecase.dart';
import '../../features/habits/domain/usecases/get_streak_repairs_usecase.dart';
import '../../features/habits/domain/usecases/get_milestones_usecase.dart';
import '../../features/habits/domain/usecases/save_milestone_usecase.dart';
import '../../features/habits/domain/usecases/save_streak_repair_usecase.dart';
import '../../features/habits/domain/services/streak_calculation_service.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/presentation/cubit/analytics_cubit.dart';
import '../../features/habits/presentation/cubit/habits_cubit.dart';
import '../../features/habits/domain/services/streak_service.dart';
import '../../features/habits/domain/services/weekly_progress_service.dart';
import '../../features/habits/domain/services/milestone_generator.dart';
import '../../features/habits/domain/services/streak_recovery_service.dart';
import '../data/objectbox_store.dart';

// sl = service locator — the single global instance of GetIt
// Import this wherever you need to retrieve a dependency
final sl = GetIt.instance;

// Called once in main.dart before runApp()
// We register dependencies in bottom-up order:
// External → DataSources → Repositories → UseCases → Cubits

Future<void> initDependencies() async {
  // ─────────────────────────────────────────────────
  // EXTERNAL
  // Registered as singletons — created once at startup
  // ─────────────────────────────────────────────────

  // ObjectBox store
  final objectBoxStore = await ObjectBoxStore.create();
  sl.registerSingleton<ObjectBoxStore>(objectBoxStore);

  // Supabase client — registered after Supabase.initialize() in main.dart
  // sl.registerSingleton<SupabaseClient>(Supabase.instance.client);

  // ─────────────────────────────────────────────────
  // FEATURES
  // ─────────────────────────────────────────────────

  _initHabits();
  _initAnalytics();
}

// ─────────────────────────────────────────────────
// HABITS
// ─────────────────────────────────────────────────
void _initHabits() {
  // DataSources
  sl.registerLazySingleton<HabitLocalDataSource>(
    () => ObjectBoxHabitDataSource(sl()),
  );

  // Repository
  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases — ALL registered BEFORE Cubit
  sl.registerLazySingleton(() => GetHabitsUseCase(sl()));
  sl.registerLazySingleton(() => CreateHabitUseCase(sl()));
  sl.registerLazySingleton(() => CompleteHabitUseCase(sl()));
  sl.registerLazySingleton(() => SkipHabitUseCase(sl()));
  sl.registerLazySingleton(() => UpdateHabitUseCase(sl()));
  sl.registerLazySingleton(() => DeleteHabitUseCase(sl()));
  sl.registerLazySingleton(() => GetTodayEventUseCase(sl()));
  sl.registerLazySingleton(() => GetEventsForHabitUseCase(sl()));
  sl.registerLazySingleton(() => GetStreakRepairsUseCase(sl()));
  sl.registerLazySingleton(() => GetMilestonesUseCase(sl()));
  sl.registerLazySingleton(() => SaveMilestoneUseCase(sl()));
  sl.registerLazySingleton(() => SaveStreakRepairUseCase(sl()));

  // Domain Services
  sl.registerLazySingleton(() => StreakCalculationService());
  sl.registerLazySingleton(() => StreakService(sl()));
  sl.registerLazySingleton(() => WeeklyProgressService());
  sl.registerLazySingleton(() => MilestoneGenerator());
  sl.registerLazySingleton(() => StreakRecoveryService());

  // Cubit — registered LAST (depends on all use cases above)
  sl.registerLazySingleton(
    () => HabitsCubit(
      getHabits: sl(),
      createHabit: sl(),
      completeHabit: sl(),
      skipHabit: sl(),
      updateHabit: sl(),
      deleteHabit: sl(),
      getTodayEvent: sl(),
      getEventsForHabit: sl(),
      getStreakRepairs: sl(),
      getMilestones: sl(),
      saveMilestone: sl(),
      saveStreakRepair: sl(),
      streakService: sl(),
      weeklyProgressService: sl(),
      milestoneGenerator: sl(),
      recoveryService: sl(),
    ),
  );
}

// ─────────────────────────────────────────────────
// ANALYTICS
// ─────────────────────────────────────────────────
void _initAnalytics() {
  // Repository
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(sl()),
  );

  // Cubit
  sl.registerFactory(
    () => AnalyticsCubit(
      repository: sl(),
      habitRepository: sl(),
      streakService: sl(),
    ),
  );
}
```

## Analytics Cubit
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multazim/features/analytics/domain/entities/insight.dart';
import 'package:multazim/features/analytics/domain/entities/habit_analytics_snapshot.dart';
import 'package:multazim/features/analytics/domain/services/insight_generator.dart';
import 'package:multazim/features/habits/domain/repositories/habit_repository.dart';
import 'package:multazim/features/habits/domain/services/streak_service.dart';
import 'package:multazim/features/habits/domain/entities/milestone.dart';
import 'package:multazim/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:multazim/features/analytics/presentation/cubit/analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository _repository;
  final HabitRepository _habitRepository;
  final StreakService _streakService;
  final InsightGenerator _insightGenerator = InsightGenerator();

  AnalyticsCubit({
    required AnalyticsRepository repository,
    required HabitRepository habitRepository,
    required StreakService streakService,
  }) : _repository = repository,
       _habitRepository = habitRepository,
       _streakService = streakService,
       super(AnalyticsInitial());

  Future<void> loadAnalytics([DateTime? start, DateTime? end]) async {
    emit(AnalyticsLoading());
    try {
      final endDate = end ?? DateTime.now();
      final startDate = start ?? endDate.subtract(const Duration(days: 30));

      // 1. Fetch Global Summaries
      final summaries = await _repository.getSummaries(startDate, endDate);

      // 2. Build Analytics Snapshots for Insights
      final habits = await _habitRepository.getHabits();
      final snapshots = <HabitAnalyticsSnapshot>[];

      for (final habit in habits.where((h) => h.isActive)) {
        final events = await _habitRepository.getEventsForHabit(habit.id);
        final repairs = await _habitRepository.getStreakRepairs(habit.id);

        final streak = _streakService.calculateStreak(habit, events, repairs);

        final dowStats = await _repository.getDayOfWeekStats(habit.id);

        final last30DaysEvents = events
            .where(
              (e) => e.date.isAfter(
                DateTime.now().subtract(const Duration(days: 30)),
              ),
            )
            .toList();

        final completionRate = last30DaysEvents.isEmpty
            ? 0.0
            : last30DaysEvents
                      .where((e) => e.status.name == 'completed')
                      .length /
                  30;

        snapshots.add(
          HabitAnalyticsSnapshot(
            habitId: habit.id,
            habitName: habit.name,
            streak: streak,
            dayOfWeekCompletionRates: dowStats,
            completionRateLast30Days: completionRate,
          ),
        );
      }

      // 3. Generate Insights
      final insights = _insightGenerator.generate(
        summaries: summaries,
        habitStats: snapshots,
      );

      // 4. Fetch All Milestones for the global view
      final allMilestones = await _habitRepository.getAllMilestones();

      emit(
        AnalyticsLoaded(
          summaries: summaries,
          insights: insights,
          milestones: allMilestones,
        ),
      );
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> loadHabitDetails(String habitId) async {
    emit(AnalyticsLoading());
    try {
      final heatmap = await _repository.getHeatmapData(habitId);
      final stats = await _repository.getDayOfWeekStats(habitId);

      // Generate insights for this specific habit
      final habit = await _habitRepository.getHabitById(habitId);
      final insights = <Insight>[];
      final milestones = <Milestone>[];

      if (habit != null) {
        final events = await _habitRepository.getEventsForHabit(habitId);
        final repairs = await _habitRepository.getStreakRepairs(habitId);
        final streak = _streakService.calculateStreak(habit, events, repairs);
        milestones.addAll(await _habitRepository.getMilestones(habitId));

        // Approx 30-day rate
        final last30DaysEvents = events
            .where(
              (e) => e.date.isAfter(
                DateTime.now().subtract(const Duration(days: 30)),
              ),
            )
            .toList();
        final completionRate = last30DaysEvents.isEmpty
            ? 0.0
            : last30DaysEvents
                      .where((e) => e.status.name == 'completed')
                      .length /
                  30;

        final snapshot = HabitAnalyticsSnapshot(
          habitId: habitId,
          habitName: habit.name,
          streak: streak,
          dayOfWeekCompletionRates: stats,
          completionRateLast30Days: completionRate,
        );

        insights.addAll(
          _insightGenerator.generate(summaries: [], habitStats: [snapshot]),
        );
      }

      emit(
        AnalyticsLoaded(
          summaries: [],
          heatmapData: heatmap,
          dayOfWeekStats: stats,
          insights: insights,
          milestones: milestones,
        ),
      );
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}
```

## Habits Cubit
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_event.dart';
import '../../domain/entities/streak.dart';
import '../../domain/entities/streak_repair.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/services/streak_service.dart';
import '../../domain/services/weekly_progress_service.dart';
import '../../domain/services/milestone_generator.dart';
import '../../domain/services/streak_recovery_service.dart';
import '../../domain/usecases/get_habits_usecase.dart';
import '../../domain/usecases/create_habit_usecase.dart';
import '../../domain/usecases/complete_habit_usecase.dart';
import '../../domain/usecases/skip_habit_usecase.dart';
import '../../domain/usecases/delete_habit_usecase.dart';
import '../../domain/usecases/update_habit_usecase.dart';
import '../../domain/usecases/get_today_event_usecase.dart';
import '../../domain/usecases/get_events_for_habit_usecase.dart';
import '../../domain/usecases/get_streak_repairs_usecase.dart';
import '../../domain/usecases/get_milestones_usecase.dart';
import '../../domain/usecases/save_milestone_usecase.dart';
import '../../domain/usecases/save_streak_repair_usecase.dart';
import 'habits_state.dart';

class HabitsCubit extends Cubit<HabitsState> {
  final GetHabitsUseCase _getHabits;
  final CreateHabitUseCase _createHabit;
  final CompleteHabitUseCase _completeHabit;
  final SkipHabitUseCase _skipHabit;
  final UpdateHabitUseCase _updateHabit;
  final DeleteHabitUseCase _deleteHabit;
  final GetTodayEventUseCase _getTodayEvent;
  final GetEventsForHabitUseCase _getEventsForHabit;
  final GetStreakRepairsUseCase _getStreakRepairs;
  final GetMilestonesUseCase _getMilestones;
  final SaveMilestoneUseCase _saveMilestone;
  final SaveStreakRepairUseCase _saveStreakRepair;
  final StreakService _streakService;
  final WeeklyProgressService _weeklyProgressService;
  final MilestoneGenerator _milestoneGenerator;
  final StreakRecoveryService _recoveryService;

  HabitsCubit({
    required GetHabitsUseCase getHabits,
    required CreateHabitUseCase createHabit,
    required CompleteHabitUseCase completeHabit,
    required SkipHabitUseCase skipHabit,
    required UpdateHabitUseCase updateHabit,
    required DeleteHabitUseCase deleteHabit,
    required GetTodayEventUseCase getTodayEvent,
    required GetEventsForHabitUseCase getEventsForHabit,
    required GetStreakRepairsUseCase getStreakRepairs,
    required GetMilestonesUseCase getMilestones,
    required SaveMilestoneUseCase saveMilestone,
    required SaveStreakRepairUseCase saveStreakRepair,
    required StreakService streakService,
    required WeeklyProgressService weeklyProgressService,
    required MilestoneGenerator milestoneGenerator,
    required StreakRecoveryService recoveryService,
  }) : _getHabits = getHabits,
       _createHabit = createHabit,
       _completeHabit = completeHabit,
       _skipHabit = skipHabit,
       _updateHabit = updateHabit,
       _deleteHabit = deleteHabit,
       _getTodayEvent = getTodayEvent,
       _getEventsForHabit = getEventsForHabit,
       _getStreakRepairs = getStreakRepairs,
       _getMilestones = getMilestones,
       _saveMilestone = saveMilestone,
       _saveStreakRepair = saveStreakRepair,
       _streakService = streakService,
       _weeklyProgressService = weeklyProgressService,
       _milestoneGenerator = milestoneGenerator,
       _recoveryService = recoveryService,
       super(HabitsInitial());

  Future<void> loadHabits() async {
    emit(HabitsLoading());
    try {
      final habits = await _getHabits();
      final now = DateTime.now();

      final todayEvents = <String, HabitEvent?>{};
      final streaks = <String, StreakState>{};
      final weeklyProgress = <String, ({int current, int target})>{};
      final milestones = <String, List<Milestone>>{};

      for (final habit in habits) {
        // Today's event
        todayEvents[habit.id] = await _getTodayEvent(habit.id);

        // Fetch events and repairs for streak/progress calculation
        final events = await _getEventsForHabit(habit.id);
        final repairs = await _getStreakRepairs(habit.id);

        // Streak calculation
        streaks[habit.id] = _streakService.calculateStreak(
          habit,
          events,
          repairs,
        );

        // Weekly progress
        weeklyProgress[habit.id] = _weeklyProgressService.getProgress(
          habit,
          events,
          now,
        );

        // Milestones
        milestones[habit.id] = await _getMilestones(habit.id);
      }

      emit(
        HabitsLoaded(
          habits: habits,
          todayEvents: todayEvents,
          streaks: streaks,
          weeklyProgress: weeklyProgress,
          milestones: milestones,
        ),
      );
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> completeHabit(String habitId) async {
    final currentState = state;
    if (currentState is! HabitsLoaded) return;

    try {
      final oldStreak = currentState.streaks[habitId]?.current ?? 0;

      await _completeHabit(habitId, DateTime.now());

      // Reload to get updated data
      await loadHabits();

      // Check for new milestones
      final newState = state;
      if (newState is HabitsLoaded) {
        final newStreakState = newState.streaks[habitId];
        if (newStreakState != null) {
          final milestone = _milestoneGenerator.checkMilestone(
            habitId,
            oldStreak,
            newStreakState.current,
            DateTime.now(),
          );

          if (milestone != null) {
            await _saveMilestone(milestone);
            // Refresh to show newly added milestone
            await loadHabits();
          }
        }
      }
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> repairStreak(String habitId, String reason) async {
    final currentState = state;
    if (currentState is! HabitsLoaded) return;

    try {
      final repairs = await _getStreakRepairs(habitId);
      final now = DateTime.now();

      if (!_recoveryService.canRepair(habitId, repairs, now)) {
        throw Exception('عذراً، يمكنك إصلاح السلسلة مرة واحدة فقط في الأسبوع');
      }

      final streak = currentState.streaks[habitId];
      if (streak == null || streak.lastCompletedDate == null) {
        throw Exception('لا يوجد تاريخ إكمال سابق للإصلاح');
      }

      final repairDate = _recoveryService.suggestRepairDate(
        streak.lastCompletedDate!,
        now,
      );

      if (repairDate == null) {
        throw Exception('السلسلة غير مكسورة حالياً');
      }

      final repair = StreakRepair(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        habitId: habitId,
        date: repairDate,
        reason: reason,
      );

      await _saveStreakRepair(repair);
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> createHabit(Habit habit) async {
    try {
      await _createHabit(habit);
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> skipHabit(String habitId) async {
    try {
      await _skipHabit(habitId, DateTime.now());
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _updateHabit(habit);
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _deleteHabit(habitId);
      await loadHabits();
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }
}
```

## Analytics Repository
```dart
import 'package:multazim/features/analytics/domain/entities/daily_summary.dart';

abstract class AnalyticsRepository {
  /// aggregated daily summaries for a specific date range
  Future<List<DailySummary>> getSummaries(DateTime startDate, DateTime endDate);

  /// heatmap data for a specific habit (Date -> Completion Rate 0.0-1.0)
  Future<Map<DateTime, double>> getHeatmapData(String habitId);

  /// day of week stats for a specific habit (Weekday 1-7 -> Completion Rate 0.0-1.0)
  Future<Map<int, double>> getDayOfWeekStats(String habitId);
}
```

## Habit Repository
```dart
import '../entities/habit.dart';
import '../entities/habit_event.dart';
import '../entities/streak_repair.dart';
import '../entities/milestone.dart';

abstract class HabitRepository {
  Future<List<Habit>> getHabits();
  Future<Habit?> getHabitById(String id);
  Future<void> createHabit(Habit habit);
  Future<void> deleteHabit(String id);
  Future<void> updateHabit(Habit habit);

  Future<void> saveEvent(HabitEvent event);
  Future<List<HabitEvent>> getEventsForHabit(String habitId);
  Future<List<HabitEvent>> getEventsForDate(DateTime date);
  Future<HabitEvent?> getTodayEvent(String habitId);

  // Phase 5: Motivation Persistence
  Future<void> saveStreakRepair(StreakRepair repair);
  Future<List<StreakRepair>> getStreakRepairs(String habitId);
  Future<void> saveMilestone(Milestone milestone);
  Future<List<Milestone>> getMilestones(String habitId);
  Future<List<Milestone>> getAllMilestones();
}
```
