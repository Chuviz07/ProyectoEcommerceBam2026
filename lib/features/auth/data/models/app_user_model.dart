import '../../domain/entities/app_user.dart';
import '../../domain/entities/user_role.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.role,
  });

  factory AppUserModel.fromMap({
    required String uid,
    required Map<String, dynamic> map,
  }) {
    return AppUserModel(
      uid: uid,
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      role: UserRole.fromString(
        map['role']?.toString(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role.value,
    };
  }
}