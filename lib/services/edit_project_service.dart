import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/edit_project.dart';
import '../models/scene.dart';

/// Persists Edit Bay projects under users/{uid}/editProjects/{id}.
class EditProjectService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>? get _col {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('editProjects');
  }

  Future<void> save(EditProject project) async {
    final col = _col;
    if (col == null) return;
    await col.doc(project.id).set({
      ...project.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<EditProject?> load(String id) async {
    final col = _col;
    if (col == null) return null;
    final snap = await col.doc(id).get();
    if (!snap.exists || snap.data() == null) return null;
    return EditProject.fromMap(snap.data()!);
  }

  Future<List<EditProject>> listRecent({int limit = 20}) async {
    final col = _col;
    if (col == null) return [];
    final q = await col.orderBy('updatedAt', descending: true).limit(limit).get();
    return q.docs.map((d) => EditProject.fromMap(d.data())).toList();
  }

  /// Seed an edit project from the live scene list (Director's Cut → Edit Bay).
  EditProject fromScenes(List<SceneNode> scenes, {String name = 'Director\'s Cut'}) {
    var project = EditProject.blank(name: name);
    final clips = <EditClip>[];
    double t = 0;
    for (var i = 0; i < scenes.length; i++) {
      final s = scenes[i];
      const dur = 4.0;
      clips.add(EditClip(
        id: 'clip_${s.id}',
        trackId: 'v1',
        mediaUrl: s.outputVideoUrl,
        thumbnailUrl: s.generatedLastFrameUrl ?? s.inputLastFrameUrl,
        label: 'SCENE ${(i + 1).toString().padLeft(2, '0')}',
        startOnTimeline: t,
        duration: dur,
        outPoint: dur,
        sceneId: s.id,
        characterName: s.character.name,
        locationName: s.locationName,
        styleNote: s.cameraMotion,
      ));
      t += dur;
    }
    return project.copyWith(clips: clips, dirty: true, updatedAt: DateTime.now());
  }
}
