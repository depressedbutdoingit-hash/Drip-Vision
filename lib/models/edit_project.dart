import 'package:flutter/foundation.dart';

/// Aspect ratio presets for the Edit Bay preview/export.
enum EditAspectRatio {
  widescreen16x9,
  vertical9x16,
  square1x1,
  cinema21x9,
}

extension EditAspectRatioX on EditAspectRatio {
  String get label {
    switch (this) {
      case EditAspectRatio.widescreen16x9:
        return '16:9';
      case EditAspectRatio.vertical9x16:
        return '9:16';
      case EditAspectRatio.square1x1:
        return '1:1';
      case EditAspectRatio.cinema21x9:
        return '2.39:1';
    }
  }

  double get value {
    switch (this) {
      case EditAspectRatio.widescreen16x9:
        return 16 / 9;
      case EditAspectRatio.vertical9x16:
        return 9 / 16;
      case EditAspectRatio.square1x1:
        return 1;
      case EditAspectRatio.cinema21x9:
        return 2.39;
    }
  }
}

enum TrackKind { video, audio }

enum TransitionType { cut, dissolve, fade, dipBlack, dipWhite, crossfade }

enum DripFilterId {
  none,
  dripCinema,
  film35mm,
  vintage,
  bleach,
  noir,
  dream,
  horror,
  pastelHorror,
  vhs,
  neonNight,
  plasticFantasy,
}

extension DripFilterIdX on DripFilterId {
  String get label {
    switch (this) {
      case DripFilterId.none:
        return 'None';
      case DripFilterId.dripCinema:
        return 'DripVision Cinema';
      case DripFilterId.film35mm:
        return '35mm';
      case DripFilterId.vintage:
        return 'Vintage';
      case DripFilterId.bleach:
        return 'Bleach';
      case DripFilterId.noir:
        return 'Noir';
      case DripFilterId.dream:
        return 'Dream';
      case DripFilterId.horror:
        return 'Horror';
      case DripFilterId.pastelHorror:
        return 'Pastel Horror';
      case DripFilterId.vhs:
        return 'VHS';
      case DripFilterId.neonNight:
        return 'Neon Night';
      case DripFilterId.plasticFantasy:
        return 'Plastic Fantasy';
    }
  }
}

/// Color / cinematic adjustments applied to a clip (and export pipeline).
@immutable
class ClipAdjustments {
  final double exposure;
  final double brightness;
  final double contrast;
  final double saturation;
  final double temperature;
  final double tint;
  final double highlights;
  final double shadows;
  final double sharpness;
  final double fade;
  final double vignette;
  final double grain;
  final double bloom;
  final double letterbox;
  final double filmSoftness;
  final double cinematicContrast;
  final DripFilterId filter;

  const ClipAdjustments({
    this.exposure = 0,
    this.brightness = 0,
    this.contrast = 0,
    this.saturation = 0,
    this.temperature = 0,
    this.tint = 0,
    this.highlights = 0,
    this.shadows = 0,
    this.sharpness = 0,
    this.fade = 0,
    this.vignette = 0,
    this.grain = 0,
    this.bloom = 0,
    this.letterbox = 0,
    this.filmSoftness = 0,
    this.cinematicContrast = 0,
    this.filter = DripFilterId.none,
  });

  ClipAdjustments copyWith({
    double? exposure,
    double? brightness,
    double? contrast,
    double? saturation,
    double? temperature,
    double? tint,
    double? highlights,
    double? shadows,
    double? sharpness,
    double? fade,
    double? vignette,
    double? grain,
    double? bloom,
    double? letterbox,
    double? filmSoftness,
    double? cinematicContrast,
    DripFilterId? filter,
  }) =>
      ClipAdjustments(
        exposure: exposure ?? this.exposure,
        brightness: brightness ?? this.brightness,
        contrast: contrast ?? this.contrast,
        saturation: saturation ?? this.saturation,
        temperature: temperature ?? this.temperature,
        tint: tint ?? this.tint,
        highlights: highlights ?? this.highlights,
        shadows: shadows ?? this.shadows,
        sharpness: sharpness ?? this.sharpness,
        fade: fade ?? this.fade,
        vignette: vignette ?? this.vignette,
        grain: grain ?? this.grain,
        bloom: bloom ?? this.bloom,
        letterbox: letterbox ?? this.letterbox,
        filmSoftness: filmSoftness ?? this.filmSoftness,
        cinematicContrast: cinematicContrast ?? this.cinematicContrast,
        filter: filter ?? this.filter,
      );

  Map<String, dynamic> toMap() => {
        'exposure': exposure,
        'brightness': brightness,
        'contrast': contrast,
        'saturation': saturation,
        'temperature': temperature,
        'tint': tint,
        'highlights': highlights,
        'shadows': shadows,
        'sharpness': sharpness,
        'fade': fade,
        'vignette': vignette,
        'grain': grain,
        'bloom': bloom,
        'letterbox': letterbox,
        'filmSoftness': filmSoftness,
        'cinematicContrast': cinematicContrast,
        'filter': filter.name,
      };

  factory ClipAdjustments.fromMap(Map<String, dynamic>? m) {
    if (m == null) return const ClipAdjustments();
    return ClipAdjustments(
      exposure: (m['exposure'] as num?)?.toDouble() ?? 0,
      brightness: (m['brightness'] as num?)?.toDouble() ?? 0,
      contrast: (m['contrast'] as num?)?.toDouble() ?? 0,
      saturation: (m['saturation'] as num?)?.toDouble() ?? 0,
      temperature: (m['temperature'] as num?)?.toDouble() ?? 0,
      tint: (m['tint'] as num?)?.toDouble() ?? 0,
      highlights: (m['highlights'] as num?)?.toDouble() ?? 0,
      shadows: (m['shadows'] as num?)?.toDouble() ?? 0,
      sharpness: (m['sharpness'] as num?)?.toDouble() ?? 0,
      fade: (m['fade'] as num?)?.toDouble() ?? 0,
      vignette: (m['vignette'] as num?)?.toDouble() ?? 0,
      grain: (m['grain'] as num?)?.toDouble() ?? 0,
      bloom: (m['bloom'] as num?)?.toDouble() ?? 0,
      letterbox: (m['letterbox'] as num?)?.toDouble() ?? 0,
      filmSoftness: (m['filmSoftness'] as num?)?.toDouble() ?? 0,
      cinematicContrast: (m['cinematicContrast'] as num?)?.toDouble() ?? 0,
      filter: DripFilterId.values.firstWhere(
        (f) => f.name == m['filter'],
        orElse: () => DripFilterId.none,
      ),
    );
  }
}

@immutable
class TextOverlay {
  final String id;
  final String text;
  final double startSec;
  final double durationSec;
  final double fontSize;
  final double opacity;
  final String position; // top | center | bottom

  const TextOverlay({
    required this.id,
    required this.text,
    required this.startSec,
    this.durationSec = 3,
    this.fontSize = 24,
    this.opacity = 1,
    this.position = 'bottom',
  });

  TextOverlay copyWith({
    String? text,
    double? startSec,
    double? durationSec,
    double? fontSize,
    double? opacity,
    String? position,
  }) =>
      TextOverlay(
        id: id,
        text: text ?? this.text,
        startSec: startSec ?? this.startSec,
        durationSec: durationSec ?? this.durationSec,
        fontSize: fontSize ?? this.fontSize,
        opacity: opacity ?? this.opacity,
        position: position ?? this.position,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'startSec': startSec,
        'durationSec': durationSec,
        'fontSize': fontSize,
        'opacity': opacity,
        'position': position,
      };

  factory TextOverlay.fromMap(Map<String, dynamic> m) => TextOverlay(
        id: m['id'] as String? ?? '',
        text: m['text'] as String? ?? '',
        startSec: (m['startSec'] as num?)?.toDouble() ?? 0,
        durationSec: (m['durationSec'] as num?)?.toDouble() ?? 3,
        fontSize: (m['fontSize'] as num?)?.toDouble() ?? 24,
        opacity: (m['opacity'] as num?)?.toDouble() ?? 1,
        position: m['position'] as String? ?? 'bottom',
      );
}

/// A single clip on a track — linked to DripVision universe metadata.
@immutable
class EditClip {
  final String id;
  final String trackId;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String label;
  final double startOnTimeline; // seconds
  final double duration; // seconds on timeline
  final double inPoint; // source in
  final double outPoint; // source out
  final double volume;
  final TransitionType transitionIn;
  final ClipAdjustments adjustments;
  final String? sceneId;
  final String? characterId;
  final String? characterName;
  final String? locationName;
  final String? styleNote;

  const EditClip({
    required this.id,
    required this.trackId,
    this.mediaUrl,
    this.thumbnailUrl,
    required this.label,
    required this.startOnTimeline,
    required this.duration,
    this.inPoint = 0,
    this.outPoint = 0,
    this.volume = 1,
    this.transitionIn = TransitionType.cut,
    this.adjustments = const ClipAdjustments(),
    this.sceneId,
    this.characterId,
    this.characterName,
    this.locationName,
    this.styleNote,
  });

  double get endOnTimeline => startOnTimeline + duration;

  EditClip copyWith({
    String? trackId,
    String? mediaUrl,
    String? thumbnailUrl,
    String? label,
    double? startOnTimeline,
    double? duration,
    double? inPoint,
    double? outPoint,
    double? volume,
    TransitionType? transitionIn,
    ClipAdjustments? adjustments,
    String? sceneId,
    String? characterId,
    String? characterName,
    String? locationName,
    String? styleNote,
  }) =>
      EditClip(
        id: id,
        trackId: trackId ?? this.trackId,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        label: label ?? this.label,
        startOnTimeline: startOnTimeline ?? this.startOnTimeline,
        duration: duration ?? this.duration,
        inPoint: inPoint ?? this.inPoint,
        outPoint: outPoint ?? this.outPoint,
        volume: volume ?? this.volume,
        transitionIn: transitionIn ?? this.transitionIn,
        adjustments: adjustments ?? this.adjustments,
        sceneId: sceneId ?? this.sceneId,
        characterId: characterId ?? this.characterId,
        characterName: characterName ?? this.characterName,
        locationName: locationName ?? this.locationName,
        styleNote: styleNote ?? this.styleNote,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'trackId': trackId,
        'mediaUrl': mediaUrl,
        'thumbnailUrl': thumbnailUrl,
        'label': label,
        'startOnTimeline': startOnTimeline,
        'duration': duration,
        'inPoint': inPoint,
        'outPoint': outPoint,
        'volume': volume,
        'transitionIn': transitionIn.name,
        'adjustments': adjustments.toMap(),
        'sceneId': sceneId,
        'characterId': characterId,
        'characterName': characterName,
        'locationName': locationName,
        'styleNote': styleNote,
      };

  factory EditClip.fromMap(Map<String, dynamic> m) => EditClip(
        id: m['id'] as String? ?? '',
        trackId: m['trackId'] as String? ?? '',
        mediaUrl: m['mediaUrl'] as String?,
        thumbnailUrl: m['thumbnailUrl'] as String?,
        label: m['label'] as String? ?? 'Clip',
        startOnTimeline: (m['startOnTimeline'] as num?)?.toDouble() ?? 0,
        duration: (m['duration'] as num?)?.toDouble() ?? 3,
        inPoint: (m['inPoint'] as num?)?.toDouble() ?? 0,
        outPoint: (m['outPoint'] as num?)?.toDouble() ?? 0,
        volume: (m['volume'] as num?)?.toDouble() ?? 1,
        transitionIn: TransitionType.values.firstWhere(
          (t) => t.name == m['transitionIn'],
          orElse: () => TransitionType.cut,
        ),
        adjustments: ClipAdjustments.fromMap(
          m['adjustments'] as Map<String, dynamic>?,
        ),
        sceneId: m['sceneId'] as String?,
        characterId: m['characterId'] as String?,
        characterName: m['characterName'] as String?,
        locationName: m['locationName'] as String?,
        styleNote: m['styleNote'] as String?,
      );
}

@immutable
class EditTrack {
  final String id;
  final TrackKind kind;
  final String name;
  final bool muted;
  final bool locked;

  const EditTrack({
    required this.id,
    required this.kind,
    required this.name,
    this.muted = false,
    this.locked = false,
  });

  EditTrack copyWith({bool? muted, bool? locked, String? name}) => EditTrack(
        id: id,
        kind: kind,
        name: name ?? this.name,
        muted: muted ?? this.muted,
        locked: locked ?? this.locked,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'kind': kind.name,
        'name': name,
        'muted': muted,
        'locked': locked,
      };

  factory EditTrack.fromMap(Map<String, dynamic> m) => EditTrack(
        id: m['id'] as String? ?? '',
        kind: TrackKind.values.firstWhere(
          (k) => k.name == m['kind'],
          orElse: () => TrackKind.video,
        ),
        name: m['name'] as String? ?? 'Track',
        muted: m['muted'] as bool? ?? false,
        locked: m['locked'] as bool? ?? false,
      );
}

@immutable
class EditProject {
  final String id;
  final String name;
  final String sequenceName;
  final EditAspectRatio aspectRatio;
  final List<EditTrack> tracks;
  final List<EditClip> clips;
  final List<TextOverlay> texts;
  final double playheadSec;
  final double pixelsPerSecond;
  final bool dirty;
  final DateTime updatedAt;

  const EditProject({
    required this.id,
    required this.name,
    this.sequenceName = 'SEQUENCE 01',
    this.aspectRatio = EditAspectRatio.widescreen16x9,
    this.tracks = const [],
    this.clips = const [],
    this.texts = const [],
    this.playheadSec = 0,
    this.pixelsPerSecond = 40,
    this.dirty = false,
    required this.updatedAt,
  });

  double get totalDuration {
    if (clips.isEmpty) return 30;
    return clips.map((c) => c.endOnTimeline).fold<double>(0, (a, b) => a > b ? a : b);
  }

  EditProject copyWith({
    String? name,
    String? sequenceName,
    EditAspectRatio? aspectRatio,
    List<EditTrack>? tracks,
    List<EditClip>? clips,
    List<TextOverlay>? texts,
    double? playheadSec,
    double? pixelsPerSecond,
    bool? dirty,
    DateTime? updatedAt,
  }) =>
      EditProject(
        id: id,
        name: name ?? this.name,
        sequenceName: sequenceName ?? this.sequenceName,
        aspectRatio: aspectRatio ?? this.aspectRatio,
        tracks: tracks ?? this.tracks,
        clips: clips ?? this.clips,
        texts: texts ?? this.texts,
        playheadSec: playheadSec ?? this.playheadSec,
        pixelsPerSecond: pixelsPerSecond ?? this.pixelsPerSecond,
        dirty: dirty ?? this.dirty,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'sequenceName': sequenceName,
        'aspectRatio': aspectRatio.name,
        'tracks': tracks.map((t) => t.toMap()).toList(),
        'clips': clips.map((c) => c.toMap()).toList(),
        'texts': texts.map((t) => t.toMap()).toList(),
        'playheadSec': playheadSec,
        'pixelsPerSecond': pixelsPerSecond,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory EditProject.fromMap(Map<String, dynamic> m) => EditProject(
        id: m['id'] as String? ?? 'project',
        name: m['name'] as String? ?? 'Untitled',
        sequenceName: m['sequenceName'] as String? ?? 'SEQUENCE 01',
        aspectRatio: EditAspectRatio.values.firstWhere(
          (a) => a.name == m['aspectRatio'],
          orElse: () => EditAspectRatio.widescreen16x9,
        ),
        tracks: (m['tracks'] as List? ?? [])
            .map((e) => EditTrack.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        clips: (m['clips'] as List? ?? [])
            .map((e) => EditClip.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        texts: (m['texts'] as List? ?? [])
            .map((e) => TextOverlay.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        playheadSec: (m['playheadSec'] as num?)?.toDouble() ?? 0,
        pixelsPerSecond: (m['pixelsPerSecond'] as num?)?.toDouble() ?? 40,
        dirty: false,
        updatedAt: DateTime.tryParse(m['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );

  static EditProject blank({String name = 'Untitled Project'}) {
    final now = DateTime.now();
    return EditProject(
      id: 'edit_${now.millisecondsSinceEpoch}',
      name: name,
      tracks: const [
        EditTrack(id: 'v1', kind: TrackKind.video, name: 'V1'),
        EditTrack(id: 'v2', kind: TrackKind.video, name: 'V2'),
        EditTrack(id: 'a1', kind: TrackKind.audio, name: 'A1'),
        EditTrack(id: 'a2', kind: TrackKind.audio, name: 'A2'),
      ],
      updatedAt: now,
    );
  }
}
