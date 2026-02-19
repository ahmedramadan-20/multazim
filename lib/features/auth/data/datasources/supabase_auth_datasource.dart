import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';
import 'auth_remote_datasource.dart';

class SupabaseAuthDataSource implements AuthRemoteDataSource {
  final supabase.SupabaseClient _client;

  SupabaseAuthDataSource(this._client);

  // ─────────────────────────────────────────────────
  // SIGN IN
  // ─────────────────────────────────────────────────

  @override
  Future<User> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final supabaseUser = response.user;
      if (supabaseUser == null) {
        throw const RemoteException('Sign in failed: no user returned');
      }

      return _mapUser(supabaseUser);
    } on supabase.AuthException catch (e) {
      throw RemoteException(e.message);
    } catch (e) {
      throw RemoteException('Sign in failed: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // SIGN UP
  // ─────────────────────────────────────────────────

  @override
  Future<User> signUpWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final supabaseUser = response.user;
      if (supabaseUser == null) {
        throw const RemoteException('Sign up failed: no user returned');
      }

      return _mapUser(supabaseUser);
    } on supabase.AuthException catch (e) {
      throw RemoteException(e.message);
    } catch (e) {
      throw RemoteException('Sign up failed: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // SIGN OUT
  // ─────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on supabase.AuthException catch (e) {
      throw RemoteException(e.message);
    } catch (e) {
      throw RemoteException('Sign out failed: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // CURRENT USER
  // ─────────────────────────────────────────────────

  @override
  Future<User?> getCurrentUser() async {
    final supabaseUser = _client.auth.currentUser;
    if (supabaseUser == null) return null;
    return _mapUser(supabaseUser);
  }

  // ─────────────────────────────────────────────────
  // AUTH STATE STREAM
  // ─────────────────────────────────────────────────

  @override
  Stream<User?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final supabaseUser = event.session?.user;
      if (supabaseUser == null) return null;
      return _mapUser(supabaseUser);
    });
  }

  // ─────────────────────────────────────────────────
  // MAPPER
  // ─────────────────────────────────────────────────

  User _mapUser(supabase.User supabaseUser) {
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      displayName: supabaseUser.userMetadata?['display_name'] as String?,
      createdAt: DateTime.parse(supabaseUser.createdAt),
    );
  }
}
