import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;
  const SignInUseCase(this.repository);

  Future<User> call(String email, String password) {
    return repository.signInWithEmail(email, password);
  }
}
