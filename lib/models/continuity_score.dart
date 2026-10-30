class ContinuityScore {
  final double character;
  final double wardrobe;
  final double props;
  final double environment;
  final double timeline;
  final double overall;
  final List<String> issues;

  const ContinuityScore({
    this.character = 1.0,
    this.wardrobe = 1.0,
    this.props = 1.0,
    this.environment = 1.0,
    this.timeline = 1.0,
    this.overall = 1.0,
    this.issues = const [],
  });

  factory ContinuityScore.empty() => const ContinuityScore();

  Map<String, dynamic> toJson() => {
        'character': character,
        'wardrobe': wardrobe,
        'props': props,
        'environment': environment,
        'timeline': timeline,
        'overall': overall,
        'issues': issues,
      };

  factory ContinuityScore.fromJson(Map<String, dynamic> json) => ContinuityScore(
        character: (json['character'] ?? 1.0).toDouble(),
        wardrobe: (json['wardrobe'] ?? 1.0).toDouble(),
        props: (json['props'] ?? 1.0).toDouble(),
        environment: (json['environment'] ?? 1.0).toDouble(),
        timeline: (json['timeline'] ?? 1.0).toDouble(),
        overall: (json['overall'] ?? 1.0).toDouble(),
        issues: List<String>.from(json['issues'] ?? const []),
      );
}
