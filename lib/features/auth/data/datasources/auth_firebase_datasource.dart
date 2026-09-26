import 'package:firebase_auth/firebase_auth.dart';

class AuthFirebaseDatasource {
  final FirebaseAuth firebaseAuth;

  AuthFirebaseDatasource({
    required this.firebaseAuth,
  });

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('No se pudo iniciar sesión');
    }

    return user;
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  Stream<User?> authStateChanges() {
    return firebaseAuth.authStateChanges();
  }
}