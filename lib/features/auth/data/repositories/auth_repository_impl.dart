import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> signInWithEmail(String email, String password) async {
    try {
      return await remoteDataSource.signInWithEmail(email, password);
    } on RemoteException catch (e) {
      throw RemoteFailure(e.message);
    }
  }

  @override
  Future<User> signUpWithEmail(String email, String password) async {
    try {
      return await remoteDataSource.signUpWithEmail(email, password);
    } on RemoteException catch (e) {
      throw RemoteFailure(e.message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } on RemoteException catch (e) {
      throw RemoteFailure(e.message);
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return await remoteDataSource.getCurrentUser();
    } on RemoteException catch (e) {
      throw RemoteFailure(e.message);
    }
  }

  @override
  Stream<User?> get authStateChanges => remoteDataSource.authStateChanges;
}
