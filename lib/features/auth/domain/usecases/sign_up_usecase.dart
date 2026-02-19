import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;
  const SignUpUseCase(this.repository);

  Future<User> call(String email, String password) {
    return repository.signUpWithEmail(email, password);
  }
}
