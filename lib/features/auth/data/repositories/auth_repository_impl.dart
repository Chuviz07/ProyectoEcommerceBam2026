import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';
import '../datasources/user_firestore_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDatasource authDatasource;
  final UserFirestoreDatasource userDatasource;

  AuthRepositoryImpl({
    required this.authDatasource,
    required this.userDatasource,
  });

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final firebaseUser = await authDatasource.login(
      email: email,
      password: password,
    );

    return userDatasource.getUserByUid(
      firebaseUser.uid,
    );
  }

  @override
  Future<void> logout() {
    return authDatasource.logout();
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return authDatasource.authStateChanges().asyncMap(
      (firebaseUser) async {
        if (firebaseUser == null) {
          return null;
        }

        return userDatasource.getUserByUid(
          firebaseUser.uid,
        );
      },
    );
  }

  @override
  Future<AppUser?> getCurrentUserProfile() async {
    final User? firebaseUser =
        authDatasource.firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    return userDatasource.getUserByUid(
      firebaseUser.uid,
    );
  }
}