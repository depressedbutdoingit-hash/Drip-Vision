class FilmBible {
  final String title;
  final String genre;
  final String era;
  final String format; // e.g. 2.39:1
  final String filmStock;
  final String colorLanguage;
  final String cameraLanguage;
  final String mood;
  final List<String> visualRules;
  final List<String> propNames;
  final String logline;

  const FilmBible({
    this.title = '',
    this.genre = '',
    this.era = '',
    this.format = '2.39:1',
    this.filmStock = '',
    this.colorLanguage = '',
    this.cameraLanguage = '',
    this.mood = '',
    this.visualRules = const [],
    this.propNames = const [],
    this.logline = '',
  });

  FilmBible copyWith({
    String? title,
    String? genre,
    String? era,
    String? format,
    String? filmStock,
    String? colorLanguage,
    String? cameraLanguage,
    String? mood,
    List<String>? visualRules,
    List<String>? propNames,
    String? logline,
  }) =>
      FilmBible(
        title: title ?? this.title,
        genre: genre ?? this.genre,
        era: era ?? this.era,
        format: format ?? this.format,
        filmStock: filmStock ?? this.filmStock,
        colorLanguage: colorLanguage ?? this.colorLanguage,
        cameraLanguage: cameraLanguage ?? this.cameraLanguage,
        mood: mood ?? this.mood,
        visualRules: visualRules ?? this.visualRules,
        propNames: propNames ?? this.propNames,
        logline: logline ?? this.logline,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'genre': genre,
        'era': era,
        'format': format,
        'filmStock': filmStock,
        'colorLanguage': colorLanguage,
        'cameraLanguage': cameraLanguage,
        'mood': mood,
        'visualRules': visualRules,
        'propNames': propNames,
        'logline': logline,
      };

  factory FilmBible.fromJson(Map<String, dynamic> j) => FilmBible(
        title: j['title'] ?? '',
        genre: j['genre'] ?? '',
        era: j['era'] ?? '',
        format: j['format'] ?? '2.39:1',
        filmStock: j['filmStock'] ?? '',
        colorLanguage: j['colorLanguage'] ?? '',
        cameraLanguage: j['cameraLanguage'] ?? '',
        mood: j['mood'] ?? '',
        visualRules: List<String>.from(j['visualRules'] ?? const []),
        propNames: List<String>.from(j['propNames'] ?? const []),
        logline: j['logline'] ?? '',
      );
}
