class Team {
  final String id;
  final String name;
  final String logoPath;
  int remainingPoints;

  Team({
    required this.id,
    required this.name,
    required this.logoPath,
    this.remainingPoints = 100000,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      logoPath: json['logoPath'] as String,
      remainingPoints: json['remainingPoints'] as int? ?? 100000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoPath': logoPath,
      'remainingPoints': remainingPoints,
    };
  }
}
