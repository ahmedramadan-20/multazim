import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:multazim/core/services/connectivity_service.dart';
import 'package:multazim/core/data/objectbox_store.dart';

// Auth Imports
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/supabase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

// Habit Imports
import '../../features/habits/data/datasources/local/habit_local_datasource.dart';
import '../../features/habits/data/datasources/local/objectbox_habit_datasource.dart';
import '../../features/habits/data/datasources/remote/habit_remote_datasource.dart';
import '../../features/habits/data/datasources/remote/supabase_habit_datasource.dart';
import '../../features/habits/data/repositories/habit_repository_impl.dart';
import '../../features/habits/domain/repositories/habit_repository.dart';
import '../../features/habits/domain/services/sync_service.dart';
import '../../features/habits/domain/services/streak_calculation_service.dart';
import '../../features/habits/domain/services/streak_service.dart';
import '../../features/habits/domain/services/weekly_progress_service.dart';
import '../../features/habits/domain/services/milestone_generator.dart';
import '../../features/habits/domain/services/streak_recovery_service.dart';
import '../../features/habits/domain/usecases/get_habits_usecase.dart';
import '../../features/habits/domain/usecases/watch_habits_usecase.dart';
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
import '../../features/habits/domain/usecases/get_all_milestones_usecase.dart';
import '../../features/habits/domain/usecases/watch_all_milestones_usecase.dart';
import '../../features/habits/domain/usecases/get_all_events_usecase.dart';
import '../../features/habits/domain/usecases/watch_all_events_usecase.dart';
import '../../features/habits/domain/usecases/get_all_streak_repairs_usecase.dart';
import '../../features/habits/domain/usecases/watch_all_streak_repairs_usecase.dart';
import '../../features/habits/presentation/cubit/habit_detail_cubit.dart';
import '../../features/habits/presentation/cubit/habits_cubit.dart';

// Analytics & Export Imports
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/domain/usecases/get_habit_by_id_for_analytics_usecase.dart';
import '../../features/analytics/domain/usecases/get_habit_events_for_analytics_usecase.dart';
import '../../features/analytics/domain/usecases/get_habit_milestones_for_analytics_usecase.dart';
import '../../features/analytics/domain/usecases/get_habit_repairs_for_analytics_usecase.dart';
import '../../features/analytics/domain/usecases/get_habits_for_analytics_usecase.dart';
import '../../features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:multazim/export/domain/services/export_service.dart';
import 'package:multazim/export/presentation/cubit/export_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─────────────────────────────────────────────────
  // 1. EXTERNAL & STORES (Base Layer)
  // ─────────────────────────────────────────────────
  final objectBoxStore = await ObjectBoxStore.create();
  sl.registerSingleton<ObjectBoxStore>(objectBoxStore);

  // SupabaseClient depends on Supabase.initialize() being called in main.dart
  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // ─────────────────────────────────────────────────
  // 2. DATA SOURCES
  // ─────────────────────────────────────────────────
  sl.registerLazySingleton<HabitLocalDataSource>(
    () => ObjectBoxHabitDataSource(sl()),
  );
  sl.registerLazySingleton<HabitRemoteDataSource>(
    () => SupabaseHabitDataSource(sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => SupabaseAuthDataSource(sl()),
  );

  // ─────────────────────────────────────────────────
  // 3. REPOSITORIES
  // ─────────────────────────────────────────────────
  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(sl()),
  );

  // ─────────────────────────────────────────────────
  // 4. DOMAIN SERVICES
  // ─────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => SyncService(localDataSource: sl(), remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => StreakCalculationService());
  sl.registerLazySingleton(() => StreakService(sl()));
  sl.registerLazySingleton(() => WeeklyProgressService());
  sl.registerLazySingleton(() => MilestoneGenerator());
  sl.registerLazySingleton(() => StreakRecoveryService());
  sl.registerLazySingleton(() => ExportService());

  // ─────────────────────────────────────────────────
  // 5. USE CASES
  // ─────────────────────────────────────────────────

  // Auth Use Cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Habit Use Cases
  sl.registerLazySingleton(() => GetHabitsUseCase(sl()));
  sl.registerLazySingleton(() => WatchHabitsUseCase(sl()));
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
  sl.registerLazySingleton(() => GetAllMilestonesUseCase(sl()));
  sl.registerLazySingleton(() => WatchAllMilestonesUseCase(sl()));
  sl.registerLazySingleton(() => GetAllEventsUseCase(sl()));
  sl.registerLazySingleton(() => WatchAllEventsUseCase(sl()));
  sl.registerLazySingleton(() => GetAllStreakRepairsUseCase(sl()));
  sl.registerLazySingleton(() => WatchAllStreakRepairsUseCase(sl()));

  // Analytics Use Cases
  sl.registerLazySingleton(() => GetHabitsForAnalyticsUseCase(sl()));
  sl.registerLazySingleton(() => GetHabitEventsForAnalyticsUseCase(sl()));
  sl.registerLazySingleton(() => GetHabitRepairsForAnalyticsUseCase(sl()));
  sl.registerLazySingleton(() => GetHabitByIdForAnalyticsUseCase(sl()));
  sl.registerLazySingleton(() => GetHabitMilestonesForAnalyticsUseCase(sl()));

  // ─────────────────────────────────────────────────
  // 6. CUBITS & CROSS-CUTTING SERVICES
  // ─────────────────────────────────────────────────

  // Register AuthCubit as a Singleton first (needed by ConnectivityService)
  sl.registerSingleton<AuthCubit>(
    AuthCubit(
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      authRepository: sl(),
      syncService: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(
      connectivity: sl(),
      syncService: sl(),
      authCubit: sl(),
    ),
  );

  // Other Cubits
  sl.registerFactory(
    () => HabitDetailCubit(repository: sl(), streakService: sl()),
  );
  sl.registerFactory(
    () => ExportCubit(habitRepository: sl(), exportService: sl()),
  );

  sl.registerLazySingleton(
    () => HabitsCubit(
      watchHabits: sl(),
      watchAllEvents: sl(),
      watchAllStreakRepairs: sl(),
      watchAllMilestones: sl(),
      getStreakRepairs: sl(),
      createHabit: sl(),
      completeHabit: sl(),
      skipHabit: sl(),
      updateHabit: sl(),
      deleteHabit: sl(),
      saveStreakRepair: sl(),
      streakService: sl(),
      weeklyProgressService: sl(),
      recoveryService: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => AnalyticsCubit(
      repository: sl(),
      watchHabits: sl(),
      watchAllEvents: sl(),
      watchAllStreakRepairs: sl(),
      watchAllMilestones: sl(),
      getHabitEvents: sl(),
      getHabitRepairs: sl(),
      getHabitById: sl(),
      getHabitMilestones: sl(),
      streakService: sl(),
    ),
  );
}
