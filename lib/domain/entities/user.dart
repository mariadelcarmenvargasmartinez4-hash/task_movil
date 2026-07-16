class FamilyUser {
  final String username;
  final String password;
  final String role; // 'padre' or 'hijo'

  const FamilyUser({
    required this.username,
    required this.password,
    required this.role,
  });
}
