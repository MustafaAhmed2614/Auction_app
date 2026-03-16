class AppUserProfile {
  final String uid;
  final String email;
  final String role;
  final String? teamId;

  const AppUserProfile({
    required this.uid,
    required this.email,
    required this.role,
    this.teamId,
  });

  factory AppUserProfile.fromJson(String uid, Map<String, dynamic> json) {
    final rawTeamId = json['teamId'];
    return AppUserProfile(
      uid: uid,
      email: (json['email'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'user',
      teamId: rawTeamId is String && rawTeamId.trim().isNotEmpty
          ? rawTeamId
          : null,
    );
  }
}