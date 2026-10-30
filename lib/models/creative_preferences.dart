class TemporaryInstruction {
  final String sceneId;
  final String instruction;
  final String? expiresAfter;

  const TemporaryInstruction({
    required this.sceneId,
    required this.instruction,
    this.expiresAfter,
  });

  Map<String, dynamic> toJson() => {
        'sceneId': sceneId,
        'instruction': instruction,
        'expiresAfter': expiresAfter,
      };

  factory TemporaryInstruction.fromJson(Map<String, dynamic> json) =>
      TemporaryInstruction(
        sceneId: json['sceneId'] ?? '',
        instruction: json['instruction'] ?? '',
        expiresAfter: json['expiresAfter'],
      );
}

class CreativePreferences {
  final String userId;
  final List<String> permanent;
  final List<String> project;
  final List<TemporaryInstruction> temporary;
  final List<Map<String, dynamic>> approvedExamples;

  const CreativePreferences({
    required this.userId,
    this.permanent = const [],
    this.project = const [],
    this.temporary = const [],
    this.approvedExamples = const [],
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'permanent': permanent,
        'project': project,
        'temporary': temporary.map((t) => t.toJson()).toList(),
        'approvedExamples': approvedExamples,
      };

  factory CreativePreferences.fromJson(Map<String, dynamic> json) =>
      CreativePreferences(
        userId: json['userId'] ?? '',
        permanent: List<String>.from(json['permanent'] ?? const []),
        project: List<String>.from(json['project'] ?? const []),
        temporary: (json['temporary'] as List? ?? [])
            .map((t) => TemporaryInstruction.fromJson(t))
            .toList(),
        approvedExamples: List<Map<String, dynamic>>.from(
            json['approvedExamples'] ?? const []),
      );
}
