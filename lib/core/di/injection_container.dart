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
      repository: sl(),
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
