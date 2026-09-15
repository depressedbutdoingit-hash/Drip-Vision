import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../models/scene.dart';
import '../widgets/cinematic_card.dart';
import '../widgets/cinematic_button.dart';
import 'export_screen.dart';
import 'generator_screen.dart';
import 'sound_department_screen.dart';

/// TIMELINE — DIRECTOR'S CUT
/// A real, reorderable cut: drag to resequence, tap a scene to open its
/// inspector, and act on it (edit / regenerate / extend / duplicate /
/// delete) — all backed by the live sceneListProvider, the same data
/// the generator and export pipeline use.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(sceneListProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: const Text("DIRECTOR'S CUT", style: TextStyle(fontSize: 12, letterSpacing: 3)),
        actions: [
          if (scenes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.ios_share, size: 19),
              tooltip: 'Export',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen())),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 16),
            child: Row(
              children: [
                const Text('00:00', style: TextStyle(fontSize: 10, color: DripTheme.muted)),
                const Spacer(),
                Text('${scenes.length} SCENES', style: const TextStyle(fontSize: 10, letterSpacing: 2, color: DripTheme.cosmicTeal)),
              ],
            ),
          ),
          Expanded(
            child: scenes.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: CinematicCard(
                      child: Text(
                        'Your timeline is waiting. Generate a scene and it will become a visual cut here.',
                        style: TextStyle(color: DripTheme.muted, height: 1.5),
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    itemCount: scenes.length,
                    onReorder: (oldIndex, newIndex) => ref.read(sceneListProvider.notifier).reorder(oldIndex, newIndex),
                    itemBuilder: (c, i) {
                      final s = scenes[i];
                      return Padding(
                        key: ValueKey(s.id),
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CinematicCard(
                          onTap: () => _openInspector(context, ref, s, i, isLast: i == scenes.length - 1),
                          child: Row(
                            children: [
                              Container(
                                width: 86,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: DripTheme.surfaceRaised,
                                  borderRadius: BorderRadius.circular(9),
                                  image: (s.generatedLastFrameUrl ?? s.inputLastFrameUrl) != null
                                      ? DecorationImage(image: NetworkImage((s.generatedLastFrameUrl ?? s.inputLastFrameUrl)!), fit: BoxFit.cover, onError: (_, __) {})
                                      : null,
                                ),
                                child: (s.generatedLastFrameUrl ?? s.inputLastFrameUrl) == null
                                    ? const Icon(Icons.movie_outlined, color: Colors.white24)
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('SCENE ${(i + 1).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 9, letterSpacing: 1.8, color: DripTheme.cosmicTeal)),
                                    const SizedBox(height: 5),
                                    Text(s.prompt, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('${s.cameraMotion ?? 'STATIC'}  •  ${s.character.name}', style: const TextStyle(fontSize: 10, color: DripTheme.muted)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.drag_handle, color: Colors.white24),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openInspector(BuildContext context, WidgetRef ref, SceneNode scene, int index, {required bool isLast}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _SceneInspectorSheet(scene: scene, index: index, isLast: isLast),
    );
  }
}

class _SceneInspectorSheet extends ConsumerWidget {
  final SceneNode scene;
  final int index;
  final bool isLast;
  const _SceneInspectorSheet({required this.scene, required this.index, required this.isLast});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(characterListProvider);
    final owner = characters.where((c) => c.id == scene.character.id).toList();
    final continuityLocked = owner.isNotEmpty ? owner.first.continuityLock : true;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
        decoration: const BoxDecoration(color: DripTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SCENE ${(index + 1).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 10, letterSpacing: 2.4, color: DripTheme.cosmicTeal, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(scene.prompt, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3)),
              const SizedBox(height: 18),
              _field('CHARACTER', scene.character.name),
              _field('LOCATION', scene.locationName ?? 'Not set'),
              _field('CAMERA', scene.cameraMotion ?? 'Static'),
              _field('ATMOSPHERE', [scene.lighting, scene.timeOfDay, scene.weather].where((s) => s != null && s.isNotEmpty).join(' · ').ifEmpty('Not set')),
              _field('CONTINUITY', continuityLocked ? 'LOCKED' : 'UNLOCKED'),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: CinematicButton(label: 'EDIT', icon: Icons.edit_outlined, primary: false, onPressed: () => _editPrompt(context, ref))),
                const SizedBox(width: 10),
                Expanded(child: CinematicButton(label: 'DUPLICATE', icon: Icons.copy_outlined, primary: false, onPressed: () {
                  ref.read(sceneListProvider.notifier).duplicateScene(scene.id);
                  Navigator.pop(context);
                })),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: CinematicButton(
                    label: isLast ? 'EXTEND' : 'REGENERATE',
                    icon: isLast ? Icons.add_road_outlined : Icons.refresh_rounded,
                    onPressed: () {
                      ref.read(activeCharacterProvider.notifier).state = scene.character;
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const DripVisionStudioScreen()));
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CinematicButton(
                    label: 'DELETE',
                    icon: Icons.delete_outline,
                    primary: false,
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              CinematicButton(
                label: 'SOUND DEPARTMENT',
                icon: Icons.graphic_eq_outlined,
                primary: false,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SoundDepartmentScreen(scene: scene)));
                },
              ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text('Only the last scene in the cut can be Extended — earlier scenes Regenerate in place.', style: TextStyle(fontSize: 10.5, color: DripTheme.muted)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 96, child: Text(label, style: const TextStyle(fontSize: 9.5, letterSpacing: 1.8, color: DripTheme.muted))),
            Expanded(child: Text(value, style: const TextStyle(color: DripTheme.warmWhite, fontWeight: FontWeight.w500))),
          ],
        ),
      );

  void _editPrompt(BuildContext context, WidgetRef ref) {
    final ctl = TextEditingController(text: scene.prompt);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DripTheme.surface,
        title: const Text('Edit Scene', style: TextStyle(color: DripTheme.nebulaCyan)),
        content: TextField(controller: ctl, maxLines: 3, style: const TextStyle(color: DripTheme.warmWhite), decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DripTheme.cosmicTeal, foregroundColor: DripTheme.voidBlack),
            onPressed: () {
              ref.read(sceneListProvider.notifier).updateScene(scene.copyWith(prompt: ctl.text.trim()));
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DripTheme.surface,
        title: const Text('Delete this scene?', style: TextStyle(color: DripTheme.nebulaCyan)),
        content: const Text('This removes it from the cut. This can\'t be undone.', style: TextStyle(color: DripTheme.chrome)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(sceneListProvider.notifier).removeScene(scene.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

extension _EmptyFallback on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
