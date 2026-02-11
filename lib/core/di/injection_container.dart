import 'package:get_it/get_it.dart';

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

  // ObjectBox store — registered after Phase 0 ObjectBox setup
  // sl.registerSingleton<Store>(await openStore());

  // Supabase client — registered after Supabase.initialize() in main.dart
  // sl.registerSingleton<SupabaseClient>(Supabase.instance.client);

  // ─────────────────────────────────────────────────
  // FEATURES
  // Each feature registers its own dependencies below.
  // When a feature grows large, move its registration
  // to a separate file: di/habits_injection.dart etc.
  // ─────────────────────────────────────────────────

  _initHabits();
  // _initStreaks();    — uncomment as we build each feature
  // _initAnalytics();
}

// ─────────────────────────────────────────────────
// HABITS
// ─────────────────────────────────────────────────
void _initHabits() {
  // DataSources
  // sl.registerLazySingleton<HabitLocalDataSource>(
  //   () => ObjectBoxHabitDataSource(sl()),
  // );
  // sl.registerLazySingleton<HabitRemoteDataSource>(
  //   () => SupabaseHabitDataSource(sl()),
  // );

  // Repository
  // sl.registerLazySingleton<HabitRepository>(
  //   () => HabitRepositoryImpl(
  //     localDataSource: sl(),
  //     remoteDataSource: sl(),
  //   ),
  // );

  // Use Cases
  // sl.registerLazySingleton(() => GetHabitsUseCase(sl()));
  // sl.registerLazySingleton(() => CreateHabitUseCase(sl()));
  // sl.registerLazySingleton(() => CompleteHabitUseCase(sl()));
  // sl.registerLazySingleton(() => SkipHabitUseCase(sl()));

  // Cubit
  // sl.registerFactory(() => HabitsCubit(
  //   getHabits: sl(),
  //   createHabit: sl(),
  //   completeHabit: sl(),
  //   skipHabit: sl(),
  // ));
}
