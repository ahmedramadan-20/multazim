import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multazim/core/di/injection_container.dart';
import 'package:multazim/features/habits/domain/services/sync_service.dart';
import 'package:multazim/features/habits/presentation/cubit/habits_cubit.dart';
import '../../../habits/data/datasources/local/habit_local_datasource.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import 'auth_state.dart';

/// Key used to persist guest mode choice across app restarts
const _guestModeKey = 'auth_guest_mode';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final GetCurrentUserUseCase getCurrentUser;
  final AuthRepository authRepository;
  final SyncService syncService;
  final HabitLocalDataSource localDataSource;

  AuthCubit({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.getCurrentUser,
    required this.authRepository,
    required this.syncService,
    required this.localDataSource,
  }) : super(AuthInitial());

  // ─────────────────────────────────────────────────
  // Called once on app launch
  // Priority: authenticated user > guest mode > unauthenticated
  // ─────────────────────────────────────────────────

  Future<void> checkAuthStatus() async {
    try {
      final user = await getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
        // Background sync on launch if online
        syncService.fullSync().catchError((e) {
          developer.log('App launch sync failed: $e', name: 'multazim.sync');
        });
        return;
      }

      // Check if user previously chose guest mode
      final isGuest = await _isGuestMode();
      if (isGuest) {
        emit(AuthGuest());
        return;
      }

      emit(AuthUnauthenticated());
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  // ─────────────────────────────────────────────────
  // Listens to Supabase auth stream
  // ─────────────────────────────────────────────────

  void listenToAuthChanges() {
    authRepository.authStateChanges.listen((user) {
      if (isClosed) return;
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        // Only drop to unauthenticated if not in guest mode
        // (Supabase stream fires null on app launch for guest users)
        if (state is! AuthGuest) {
          emit(AuthUnauthenticated());
        }
      }
    });
  }

  // ─────────────────────────────────────────────────
  // GUEST MODE
  // ─────────────────────────────────────────────────

  Future<void> continueAsGuest() async {
    await _saveGuestMode(true);
    emit(AuthGuest());
  }

  bool get isGuest => state is AuthGuest;
  bool get isAuthenticated => state is AuthAuthenticated;

  // ─────────────────────────────────────────────────
  // SIGN IN
  // ─────────────────────────────────────────────────

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await signIn(email, password);
      // Clear guest mode flag since user now has an account
      await _saveGuestMode(false);
      // Migrate guest data to cloud before pulling remote data
      await syncService.fullSync();
      await sl<HabitsCubit>().loadHabits();
      emit(AuthAuthenticated(user));
    } on RemoteFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('حدث خطأ غير متوقع'));
    }
  }

  // ─────────────────────────────────────────────────
  // SIGN UP
  // ─────────────────────────────────────────────────

  Future<void> signUpWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await signUp(email, password);
      await _saveGuestMode(false);
      // Migrate guest data to cloud before pulling remote data
      await syncService.fullSync();
      await sl<HabitsCubit>().loadHabits();
      emit(AuthAuthenticated(user));
    } on RemoteFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('حدث خطأ غير متوقع'));
    }
  }

  // ─────────────────────────────────────────────────
  // SIGN OUT
  // ─────────────────────────────────────────────────

  Future<void> signOutUser() async {
    emit(AuthLoading());
    try {
      // Final attempt to push data before clearing local storage
      await syncService.pushLocalData().catchError((e) {
        developer.log('Logout sync failed: $e', name: 'multazim.sync');
      });
      await signOut();
      await localDataSource.clearAllLocalData();
      await _saveGuestMode(false);
      emit(AuthUnauthenticated());
    } on RemoteFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('تعذر تسجيل الخروج'));
    }
  }

  // ─────────────────────────────────────────────────
  // GUEST MODE PERSISTENCE
  // Uses shared_preferences to remember choice across restarts
  // ─────────────────────────────────────────────────

  Future<bool> _isGuestMode() async {
    try {
      // Use ObjectBox metadata or shared_preferences
      // Using simple file-based flag via localDataSource metadata
      return await localDataSource.getMetadata(_guestModeKey) == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveGuestMode(bool value) async {
    try {
      await localDataSource.saveMetadata(_guestModeKey, value.toString());
    } catch (_) {
      // Non-critical — guest mode just won't persist across restarts
    }
  }
}
