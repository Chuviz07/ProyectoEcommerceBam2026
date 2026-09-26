import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class AuthStateUseCase {
  final AuthRepository repository;

  AuthStateUseCase(this.repository);

  Stream<AppUser?> call() {
    return repository.authStateChanges();
  }
}