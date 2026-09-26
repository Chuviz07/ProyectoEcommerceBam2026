import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Stream<AppUser?> authStateChanges();

  Future<AppUser?> getCurrentUserProfile();
}