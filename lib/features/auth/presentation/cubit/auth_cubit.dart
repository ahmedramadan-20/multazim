import 'dart:async';
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

const _guestModeKey = 'auth_guest_mode';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final GetCurrentUserUseCase getCurrentUser;
  final AuthRepository authRepository;
  final SyncService syncService;
  final HabitLocalDataSource localDataSource;

  StreamSubscription? _authSubscription;

  AuthCubit({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.getCurrentUser,
    required this.authRepository,
    required this.syncService,
    required this.localDataSource,
  }) : super(AuthInitial()) {
    // Auth initializes itself on construction.
    // checkAuthStatus is async — router stays on welcome (AuthInitial)
    // until it completes, then redirects automatically via refreshListenable.
    checkAuthStatus();
    listenToAuthChanges(); // single subscription — never call again from outside
  }

  // ─────────────────────────────────────────────────
  // APP LAUNCH
  // Priority: authenticated > guest > unauthenticated
  // ─────────────────────────────────────────────────

  Future<void> checkAuthStatus() async {
    try {
      final user = await getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
        syncService.fullSync().catchError((e) {
          developer.log('App launch sync failed: $e', name: 'multazim.sync');
        });
        return;
      }

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
  // AUTH STREAM — single subscription from constructor
  // ─────────────────────────────────────────────────

  void listenToAuthChanges() {
    _authSubscription = authRepository.authStateChanges.listen((user) {
      if (isClosed) return;
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        if (state is! AuthGuest) {
          emit(AuthUnauthenticated());
        }
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
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
      await _saveGuestMode(false);
      await syncService.fullSync();
      await sl<HabitsCubit>().loadHabits();
      emit(AuthAuthenticated(user));
    } on RemoteFailure catch (e) {
      emit(AuthError(_translateAuthError(e.message)));
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
      await syncService.fullSync();
      await sl<HabitsCubit>().loadHabits();
      emit(AuthAuthenticated(user));
    } on RemoteFailure catch (e) {
      emit(AuthError(_translateAuthError(e.message)));
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
      // Run sync and a minimum delay in parallel to ensure the loading spinner is visible
      await Future.wait([
        syncService.pushLocalData().catchError((e) {
          developer.log('Logout sync failed: $e', name: 'multazim.sync');
        }),
        Future.delayed(const Duration(milliseconds: 600)),
      ]);
      await signOut();
      await localDataSource.clearAllLocalData();
      await _saveGuestMode(false);
      emit(AuthUnauthenticated());
    } on RemoteFailure catch (e) {
      emit(AuthError(_translateAuthError(e.message)));
    } catch (e) {
      emit(AuthError('تعذر تسجيل الخروج'));
    }
  }

  // ─────────────────────────────────────────────────
  // ERROR TRANSLATION
  // ─────────────────────────────────────────────────

  String _translateAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('rate limit') || lower.contains('too many')) {
      return 'تجاوزت الحد المسموح به، حاول بعد قليل';
    }
    if (lower.contains('already registered') ||
        lower.contains('already exists') ||
        lower.contains('user already')) {
      return 'هذا البريد الإلكتروني مسجل مسبقاً';
    }
    if (lower.contains('invalid login') ||
        lower.contains('invalid credentials') ||
        lower.contains('wrong password') ||
        lower.contains('invalid password')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (lower.contains('email not confirmed') ||
        lower.contains('confirm your email')) {
      return 'يرجى تأكيد بريدك الإلكتروني أولاً';
    }
    if (lower.contains('invalid email') || lower.contains('valid email')) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    if (lower.contains('weak password') || lower.contains('password should')) {
      return 'كلمة المرور ضعيفة — استخدم 6 أحرف أو أكثر';
    }
    if (lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('timeout')) {
      return 'تعذر الاتصال، تحقق من الإنترنت';
    }
    if (lower.contains('user not found') || lower.contains('no user')) {
      return 'لا يوجد حساب بهذا البريد الإلكتروني';
    }
    return 'حدث خطأ، حاول مرة أخرى';
  }

  // ─────────────────────────────────────────────────
  // GUEST MODE PERSISTENCE
  // ─────────────────────────────────────────────────

  Future<bool> _isGuestMode() async {
    try {
      return await localDataSource.getMetadata(_guestModeKey) == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveGuestMode(bool value) async {
    try {
      await localDataSource.saveMetadata(_guestModeKey, value.toString());
    } catch (_) {}
  }
}
