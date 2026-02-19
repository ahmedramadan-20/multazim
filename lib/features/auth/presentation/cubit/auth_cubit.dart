import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multazim/features/habits/domain/services/sync_service.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final GetCurrentUserUseCase getCurrentUser;
  final AuthRepository authRepository;
  final SyncService syncService;

  AuthCubit({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.getCurrentUser,
    required this.authRepository,
    required this.syncService,
  }) : super(AuthInitial());

  // ─────────────────────────────────────────────────
  // Called once on app launch from main.dart / router
  // ─────────────────────────────────────────────────

  Future<void> checkAuthStatus() async {
    try {
      final user = await getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  // ─────────────────────────────────────────────────
  // Listens to Supabase auth stream for session changes
  // (token refresh, sign out from another device, etc.)
  // Call this once after checkAuthStatus()
  // ─────────────────────────────────────────────────

  void listenToAuthChanges() {
    authRepository.authStateChanges.listen((user) {
      if (isClosed) return;
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  // ─────────────────────────────────────────────────
  // SIGN IN
  // ─────────────────────────────────────────────────

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await signIn(email, password);
      await syncService.pullAndMerge();
      emit(AuthAuthenticated(user));
    } on RemoteFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An unexpected error occurred'));
    }
  }

  // ─────────────────────────────────────────────────
  // SIGN UP
  // ─────────────────────────────────────────────────

  Future<void> signUpWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await signUp(email, password);
      await syncService.pullAndMerge();
      emit(AuthAuthenticated(user));
    } on RemoteFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An unexpected error occurred'));
    }
  }

  // ─────────────────────────────────────────────────
  // SIGN OUT
  // ─────────────────────────────────────────────────

  Future<void> signOutUser() async {
    emit(AuthLoading());
    try {
      await signOut();
      emit(AuthUnauthenticated());
    } on RemoteFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Sign out failed'));
    }
  }
}
