import 'user_role.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final UserRole role;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;

  bool get isCustomer => role == UserRole.customer;
}