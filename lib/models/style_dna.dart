/// STYLE DNA™
/// A saved, reusable visual language — the same idea as Director Mode's
/// per-shot settings, but persisted, named, and applicable to an entire
/// project at once. Can be built by hand or extracted from a reference
/// image via StyleDnaService.
class StyleDna {
  final String id;
  final String name;
  final List<String> tags; // e.g. "35mm", "wet streets", "deep shadows"
  final String lens;
  final String colorPalette;
  final String lighting;
  final String grain;
  final String contrast;
  final String? sourceImageUrl;
  final DateTime createdAt;

  const StyleDna({
    required this.id,
    required this.name,
    this.tags = const [],
    this.lens = '',
    this.colorPalette = '',
    this.lighting = '',
    this.grain = '',
    this.contrast = '',
    this.sourceImageUrl,
    required this.createdAt,
  });

  /// Plain-language descriptor folded into the generation prompt.
  String toDescriptor() {
    final parts = <String>[
      if (lens.isNotEmpty) 'shot on $lens',
      if (lighting.isNotEmpty) '$lighting lighting',
      if (colorPalette.isNotEmpty) '$colorPalette color palette',
      if (contrast.isNotEmpty) '$contrast contrast',
      if (grain.isNotEmpty) grain,
      ...tags,
    ];
    return 'Style DNA "$name": ${parts.join(', ')}.';
  }

  StyleDna copyWith({
    String? id,
    String? name,
    List<String>? tags,
    String? lens,
    String? colorPalette,
    String? lighting,
    String? grain,
    String? contrast,
    String? sourceImageUrl,
    DateTime? createdAt,
  }) =>
      StyleDna(
        id: id ?? this.id,
        name: name ?? this.name,
        tags: tags ?? this.tags,
        lens: lens ?? this.lens,
        colorPalette: colorPalette ?? this.colorPalette,
        lighting: lighting ?? this.lighting,
        grain: grain ?? this.grain,
        contrast: contrast ?? this.contrast,
        sourceImageUrl: sourceImageUrl ?? this.sourceImageUrl,
        createdAt: createdAt ?? this.createdAt,
      );

  factory StyleDna.fromJson(Map<String, dynamic> json) => StyleDna(
        id: json['id'],
        name: json['name'],
        tags: List<String>.from(json['tags'] ?? const []),
        lens: json['lens'] ?? '',
        colorPalette: json['colorPalette'] ?? '',
        lighting: json['lighting'] ?? '',
        grain: json['grain'] ?? '',
        contrast: json['contrast'] ?? '',
        sourceImageUrl: json['sourceImageUrl'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tags': tags,
        'lens': lens,
        'colorPalette': colorPalette,
        'lighting': lighting,
        'grain': grain,
        'contrast': contrast,
        'sourceImageUrl': sourceImageUrl,
        'createdAt': createdAt.toIso8601String(),
      };
}
