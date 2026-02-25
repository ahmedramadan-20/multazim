import '../../domain/entities/user.dart';

abstract class AuthState {}

/// App just launched, checking if user is already logged in
class AuthInitial extends AuthState {}

/// Any async operation in progress (sign in, sign up, sign out)
class AuthLoading extends AuthState {}

/// User is logged in with a full account
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

/// User chose to use the app without an account — offline only
class AuthGuest extends AuthState {}

/// User explicitly landed on auth screen (first launch, or signed out)
class AuthUnauthenticated extends AuthState {}

/// Something went wrong — message shown to UI
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
