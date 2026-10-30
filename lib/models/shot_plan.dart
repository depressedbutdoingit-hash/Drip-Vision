class Shot {
  final int order;
  final String type; // wide, tracking, close_up, insert, over_shoulder, reaction, establishing
  final double durationSeconds;
  final String description;
  final String cameraMovement; // static, dolly, handheld, crane
  final String? lensNotes;
  final String? screenDirection;
  final String? characterFocus;

  const Shot({
    required this.order,
    required this.type,
    required this.durationSeconds,
    required this.description,
    this.cameraMovement = 'static',
    this.lensNotes,
    this.screenDirection,
    this.characterFocus,
  });

  Map<String, dynamic> toJson() => {
        'order': order,
        'type': type,
        'durationSeconds': durationSeconds,
        'description': description,
        'cameraMovement': cameraMovement,
        'lensNotes': lensNotes,
        'screenDirection': screenDirection,
        'characterFocus': characterFocus,
      };

  factory Shot.fromJson(Map<String, dynamic> json) => Shot(
        order: json['order'] ?? 0,
        type: json['type'] ?? 'wide',
        durationSeconds: (json['durationSeconds'] ?? 0.0).toDouble(),
        description: json['description'] ?? '',
        cameraMovement: json['cameraMovement'] ?? 'static',
        lensNotes: json['lensNotes'],
        screenDirection: json['screenDirection'],
        characterFocus: json['characterFocus'],
      );
}

class ShotPlan {
  final String sceneId;
  final String genre;
  final String emotionalArc;
  final List<Shot> shots;
  final double totalDuration;
  final bool continuityChecked;

  const ShotPlan({
    required this.sceneId,
    this.genre = 'drama',
    this.emotionalArc = '',
    this.shots = const [],
    this.totalDuration = 0.0,
    this.continuityChecked = false,
  });

  Map<String, dynamic> toJson() => {
        'sceneId': sceneId,
        'genre': genre,
        'emotionalArc': emotionalArc,
        'shots': shots.map((s) => s.toJson()).toList(),
        'totalDuration': totalDuration,
        'continuityChecked': continuityChecked,
      };

  factory ShotPlan.fromJson(Map<String, dynamic> json) => ShotPlan(
        sceneId: json['sceneId'] ?? '',
        genre: json['genre'] ?? 'drama',
        emotionalArc: json['emotionalArc'] ?? '',
        shots: (json['shots'] as List? ?? [])
            .map((s) => Shot.fromJson(s))
            .toList(),
        totalDuration: (json['totalDuration'] ?? 0.0).toDouble(),
        continuityChecked: json['continuityChecked'] ?? false,
      );
}
