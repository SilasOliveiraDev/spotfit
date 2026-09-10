class Profile {
  const Profile({
    required this.id,
    required this.displayName,
    this.fitnessFocus,
    this.email,
  });

  final String id;
  final String displayName;
  final String? fitnessFocus;
  final String? email;
}
