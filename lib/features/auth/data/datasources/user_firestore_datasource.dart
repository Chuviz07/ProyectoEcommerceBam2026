import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user_model.dart';

class UserFirestoreDatasource {
  final FirebaseFirestore firestore;

  UserFirestoreDatasource({
    required this.firestore,
  });

  Future<AppUserModel> getUserByUid(String uid) async {
    final document = await firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!document.exists) {
      throw Exception(
        'El usuario está autenticado, pero no tiene un perfil en Firestore',
      );
    }

    final data = document.data();

    if (data == null) {
      throw Exception(
        'El perfil del usuario no contiene información',
      );
    }

    return AppUserModel.fromMap(
      uid: document.id,
      map: data,
    );
  }

  Stream<AppUserModel?> watchUserByUid(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((document) {
      if (!document.exists || document.data() == null) {
        return null;
      }

      return AppUserModel.fromMap(
        uid: document.id,
        map: document.data()!,
      );
    });
  }
}