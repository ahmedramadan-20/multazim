import 'package:get_it/get_it.dart';
import 'package:multazim/features/analytics/domain/usecases/get_habit_by_id_for_analytics_usecase.dart';
import 'package:multazim/features/analytics/domain/usecases/get_habit_events_for_analytics_usecase.dart';
import 'package:multazim/features/analytics/domain/usecases/get_habit_milestones_for_analytics_usecase.dart';
import 'package:multazim/features/analytics/domain/usecases/get_habit_repairs_for_analytics_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/analytics/domain/usecases/get_habits_for_analytics_usecase.dart';
import '../../features/habits/data/datasources/local/habit_local_datasource.dart';
import '../../features/habits/data/datasources/local/objectbox_habit_datasource.dart';
import '../../features/habits/data/datasources/remote/habit_remote_datasource.dart';
import '../../features/habits/data/datasources/remote/supabase_habit_datasource.dart';
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
  sl.registerLazySingleton<HabitRemoteDataSource>(
    () => SupabaseHabitDataSource(Supabase.instance.client),
  );
  // Repository
  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
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
  // Use Cases — Analytics needs to query Habits data
  sl.registerLazySingleton(() => GetHabitsForAnalyticsUseCase(sl()));
  sl.registerLazySingleton(() => GetHabitEventsForAnalyticsUseCase(sl()));
  sl.registerLazySingleton(() => GetHabitRepairsForAnalyticsUseCase(sl()));
  sl.registerLazySingleton(() => GetHabitByIdForAnalyticsUseCase(sl()));
  sl.registerLazySingleton(() => GetHabitMilestonesForAnalyticsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(sl()),
  );

  // Cubit
  sl.registerFactory(
    () => AnalyticsCubit(
      repository: sl(),
      getHabits: sl(),
      getHabitEvents: sl(),
      getHabitRepairs: sl(),
      getHabitById: sl(),
      getHabitMilestones: sl(),
      streakService: sl(),
    ),
  );
}
