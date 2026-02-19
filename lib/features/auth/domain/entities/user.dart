class User {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
  });
}
