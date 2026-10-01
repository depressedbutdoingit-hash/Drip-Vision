import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/edit_project.dart';
import '../models/scene.dart';
import 'edit_project_service.dart';

final editProjectServiceProvider = Provider((ref) => EditProjectService());

final editBayProvider =
    StateNotifierProvider<EditBayNotifier, EditBayState>((ref) {
  return EditBayNotifier(ref.read(editProjectServiceProvider));
});

class EditBayState {
  final EditProject project;
  final String? selectedClipId;
  final String toolPanel; // media|color|filters|audio|text|transitions|memory
  final bool playing;
  final bool saving;
  final List<EditProject> undoStack;
  final List<EditProject> redoStack;

  const EditBayState({
    required this.project,
    this.selectedClipId,
    this.toolPanel = 'color',
    this.playing = false,
    this.saving = false,
    this.undoStack = const [],
    this.redoStack = const [],
  });

  EditClip? get selectedClip {
    if (selectedClipId == null) return null;
    try {
      return project.clips.firstWhere((c) => c.id == selectedClipId);
    } catch (_) {
      return null;
    }
  }

  EditBayState copyWith({
    EditProject? project,
    String? selectedClipId,
    bool clearSelection = false,
    String? toolPanel,
    bool? playing,
    bool? saving,
    List<EditProject>? undoStack,
    List<EditProject>? redoStack,
  }) =>
      EditBayState(
        project: project ?? this.project,
        selectedClipId:
            clearSelection ? null : (selectedClipId ?? this.selectedClipId),
        toolPanel: toolPanel ?? this.toolPanel,
        playing: playing ?? this.playing,
        saving: saving ?? this.saving,
        undoStack: undoStack ?? this.undoStack,
        redoStack: redoStack ?? this.redoStack,
      );
}

class EditBayNotifier extends StateNotifier<EditBayState> {
  final EditProjectService _service;

  EditBayNotifier(this._service)
      : super(EditBayState(project: EditProject.blank()));

  void _pushUndo(EditProject before) {
    final stack = [...state.undoStack, before];
    if (stack.length > 40) stack.removeAt(0);
    state = state.copyWith(undoStack: stack, redoStack: const []);
  }

  void loadProject(EditProject project) {
    state = EditBayState(project: project);
  }

  void loadFromScenes(List<SceneNode> scenes, {String? name}) {
    final p = _service.fromScenes(scenes, name: name ?? 'Director\'s Cut');
    state = EditBayState(project: p);
  }

  void selectClip(String? id) {
    state = state.copyWith(selectedClipId: id, clearSelection: id == null);
  }

  void setToolPanel(String panel) {
    state = state.copyWith(toolPanel: panel);
  }

  void setPlayhead(double sec) {
    final p = state.project.copyWith(
      playheadSec: sec.clamp(0, state.project.totalDuration),
    );
    state = state.copyWith(project: p);
  }

  void setPlaying(bool v) => state = state.copyWith(playing: v);

  void setAspect(EditAspectRatio ratio) {
    _pushUndo(state.project);
    state = state.copyWith(
      project: state.project.copyWith(aspectRatio: ratio, dirty: true),
    );
  }

  void setZoom(double pps) {
    state = state.copyWith(
      project: state.project.copyWith(
        pixelsPerSecond: pps.clamp(12, 120),
      ),
    );
  }

  void updateClip(EditClip clip) {
    _pushUndo(state.project);
    final clips =
        state.project.clips.map((c) => c.id == clip.id ? clip : c).toList();
    state = state.copyWith(
      project: state.project.copyWith(
        clips: clips,
        dirty: true,
        updatedAt: DateTime.now(),
      ),
    );
  }

  void moveClip(String id, double newStart) {
    final clip = state.project.clips.firstWhere((c) => c.id == id);
    updateClip(clip.copyWith(startOnTimeline: newStart.clamp(0, 36000)));
  }

  void trimClip(String id, {double? inPoint, double? outPoint, double? duration}) {
    final clip = state.project.clips.firstWhere((c) => c.id == id);
    updateClip(clip.copyWith(
      inPoint: inPoint ?? clip.inPoint,
      outPoint: outPoint ?? clip.outPoint,
      duration: duration ?? clip.duration,
    ));
  }

  void splitClipAtPlayhead() {
    final id = state.selectedClipId;
    if (id == null) return;
    final clip = state.project.clips.firstWhere((c) => c.id == id);
    final ph = state.project.playheadSec;
    if (ph <= clip.startOnTimeline + 0.15 ||
        ph >= clip.endOnTimeline - 0.15) {
      return;
    }
    _pushUndo(state.project);
    final leftDur = ph - clip.startOnTimeline;
    final rightDur = clip.endOnTimeline - ph;
    final left = clip.copyWith(duration: leftDur, outPoint: clip.inPoint + leftDur);
    final right = EditClip(
      id: '${clip.id}_split_${DateTime.now().millisecondsSinceEpoch}',
      trackId: clip.trackId,
      mediaUrl: clip.mediaUrl,
      thumbnailUrl: clip.thumbnailUrl,
      label: clip.label,
      startOnTimeline: ph,
      duration: rightDur,
      inPoint: clip.inPoint + leftDur,
      outPoint: clip.outPoint,
      volume: clip.volume,
      transitionIn: TransitionType.cut,
      adjustments: clip.adjustments,
      sceneId: clip.sceneId,
      characterId: clip.characterId,
      characterName: clip.characterName,
      locationName: clip.locationName,
      styleNote: clip.styleNote,
    );
    final clips = state.project.clips
        .map((c) => c.id == id ? left : c)
        .toList()
      ..add(right);
    state = state.copyWith(
      project: state.project.copyWith(clips: clips, dirty: true),
      selectedClipId: right.id,
    );
  }

  void deleteSelected() {
    final id = state.selectedClipId;
    if (id == null) return;
    _pushUndo(state.project);
    state = state.copyWith(
      project: state.project.copyWith(
        clips: state.project.clips.where((c) => c.id != id).toList(),
        dirty: true,
      ),
      clearSelection: true,
    );
  }

  void setTransition(TransitionType t) {
    final clip = state.selectedClip;
    if (clip == null) return;
    updateClip(clip.copyWith(transitionIn: t));
  }

  void setFilter(DripFilterId f) {
    final clip = state.selectedClip;
    if (clip == null) return;
    updateClip(clip.copyWith(adjustments: clip.adjustments.copyWith(filter: f)));
  }

  void setAdjustment(ClipAdjustments Function(ClipAdjustments) fn) {
    final clip = state.selectedClip;
    if (clip == null) return;
    updateClip(clip.copyWith(adjustments: fn(clip.adjustments)));
  }

  void undo() {
    if (state.undoStack.isEmpty) return;
    final stack = [...state.undoStack];
    final prev = stack.removeLast();
    state = state.copyWith(
      project: prev,
      undoStack: stack,
      redoStack: [...state.redoStack, state.project],
    );
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    final stack = [...state.redoStack];
    final next = stack.removeLast();
    state = state.copyWith(
      project: next,
      redoStack: stack,
      undoStack: [...state.undoStack, state.project],
    );
  }


  /// Append a media clip to V1 at the end of the current cut.
  void addMediaClip({
    required String mediaUrl,
    String? thumbnailUrl,
    String label = 'CLIP',
    String? sceneId,
    String? characterName,
    String? locationName,
    String? styleNote,
    double duration = 4,
  }) {
    _pushUndo(state.project);
    final start = state.project.totalDuration;
    final clip = EditClip(
      id: 'clip_${DateTime.now().millisecondsSinceEpoch}',
      trackId: 'v1',
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      label: label,
      startOnTimeline: start,
      duration: duration,
      outPoint: duration,
      sceneId: sceneId,
      characterName: characterName,
      locationName: locationName,
      styleNote: styleNote,
    );
    state = state.copyWith(
      project: state.project.copyWith(
        clips: [...state.project.clips, clip],
        dirty: true,
        updatedAt: DateTime.now(),
      ),
      selectedClipId: clip.id,
    );
  }

  Future<void> save() async {
    state = state.copyWith(saving: true);
    try {
      final p = state.project.copyWith(dirty: false, updatedAt: DateTime.now());
      await _service.save(p);
      state = state.copyWith(project: p, saving: false);
    } catch (_) {
      state = state.copyWith(saving: false);
      rethrow;
    }
  }
}
