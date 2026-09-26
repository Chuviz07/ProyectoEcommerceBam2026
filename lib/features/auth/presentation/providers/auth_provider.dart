import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_firebase_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_state_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../state/auth_state.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/user_firestore_datasource.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider =
    Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final userFirestoreDatasourceProvider =
    Provider<UserFirestoreDatasource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return UserFirestoreDatasource(
    firestore: firestore,
  );
});

final authFirebaseDatasourceProvider = Provider<AuthFirebaseDatasource>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);

  return AuthFirebaseDatasource(
    firebaseAuth: firebaseAuth,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authDatasource =
      ref.watch(authFirebaseDatasourceProvider);

  final userDatasource =
      ref.watch(userFirestoreDatasourceProvider);

  return AuthRepositoryImpl(
    authDatasource: authDatasource,
    userDatasource: userDatasource,
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);

  return LoginUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);

  return LogoutUseCase(repository);
});

final authStateUseCaseProvider = Provider<AuthStateUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);

  return AuthStateUseCase(repository);
});

final authUserProvider = StreamProvider<AppUser?>((ref) {
  final useCase = ref.watch(authStateUseCaseProvider);

  return useCase();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthNotifier({
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(const AuthState());

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
      );

      final user = await loginUseCase(
        email: email.trim(),
        password: password.trim(),
      );

      state = AuthState(
        isLoading: false,
        user: user,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFirebaseError(e.code),
      );

      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado',
      );

      return false;
    }
  }

  Future<void> logout() async {
    await logoutUseCase();
    state = const AuthState();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El correo no tiene un formato válido';
      case 'user-disabled':
        return 'Este usuario está deshabilitado';
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'wrong-password':
        return 'La contraseña es incorrecta';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      default:
        return 'No se pudo iniciar sesión';
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);

  return AuthNotifier(
    loginUseCase: loginUseCase,
    logoutUseCase: logoutUseCase,
  );
});