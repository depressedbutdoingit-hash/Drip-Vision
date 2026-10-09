import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../widgets/video_player_widget.dart';
import 'character_creation_screen.dart';
import '../../core/director_settings.dart';
import '../../core/ai_tiers.dart';
import '../../core/model_prefs.dart';
import '../../core/product_models.dart';
import '../widgets/model_picker_sheet.dart';
import '../../models/character.dart';
import '../../services/push_notification_service.dart';
import '../../services/purchase_service.dart';
import '../widgets/camera_joystick.dart';
import '../widgets/drip_swapper.dart';
import '../widgets/media_picker_button.dart';
import '../widgets/video_action_bar.dart';
import '../widgets/cinematic_progress.dart';

class DripVisionStudioScreen extends ConsumerStatefulWidget {
  const DripVisionStudioScreen({super.key});

  @override
  ConsumerState<DripVisionStudioScreen> createState() => _DripVisionStudioScreenState();
}

class _DripVisionStudioScreenState extends ConsumerState<DripVisionStudioScreen> {
  static const _cameraModes = ['LOCK', 'PAN', 'ZOOM', 'ORBIT', 'WHIP', 'DRONE'];

  final _promptController = TextEditingController();
  String _selectedCameraMotion = 'static';
  bool _isRecording = false;
  bool _useDirectorBrief = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = ref.read(pendingScenePromptProvider);
      if (pending != null && pending.isNotEmpty) {
        _promptController.text = pending;
        ref.read(pendingScenePromptProvider.notifier).state = null;
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    final character = ref.read(activeCharacterProvider);
    if (character == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a character first')),
      );
      return;
    }

    final tier = ref.read(userProfileProvider).value?.subscriptionTier;
    final videoTier = ref.read(videoQualityProvider);
    if (!AiTiers.videoTierAllowed(tier, videoTier)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AiTiers.videoTierLabel(videoTier)} video requires a higher plan.',
          ),
        ),
      );
      _showPaywall();
      return;
    }

    final cost = AiTiers.videoCostFor(durationSeconds: 5, tier: videoTier);
    final guard = ref.read(generationGuardProvider);
    final hasTokens = await guard.deductAndValidateTokens(costInTokens: cost.tokens);
    if (!hasTokens) {
      _showPaywall();
      return;
    }

    ref.read(isGeneratingProvider.notifier).state = true;
    ref.read(generationProgressProvider.notifier).state = 0;

    try {
      final directorSettings = ref.read(directorSettingsProvider);
      final appliedStyle = ref.read(activeStyleProvider);
      // Director Mode's selections are folded into the raw input *before*
      // the prompt-enhancer runs, so shot/lens/lighting/mood choices reach
      // the actual generation prompt without the user writing any of it
      // themselves. Character identity + continuity remain untouched.
      final directedInput = _useDirectorBrief
          ? '$prompt. ${directorSettings.toDescriptor()}${appliedStyle != null ? ' ${appliedStyle.toDescriptor()}' : ''}'
          : prompt;

      final enhanced = await ref.read(promptEnhancerProvider).enhancePrompt(
            directedInput,
            character.defaultStylePrompt,
          );

      final previousScene = ref.read(sceneListProvider).lastOrNull;
      final cameraMotion = _useDirectorBrief ? directorSettings.cameraMotionLabel : _selectedCameraMotion;
      final model = resolveVideoModel(ref);

      final scene = (await ref.read(dripEngineProvider).generateNextScene(
            previousScene: previousScene,
            rawPrompt: prompt,
            enhancedPrompt: enhanced,
            character: character,
            cameraMotion: cameraMotion,
            onProgress: (p) => ref.read(generationProgressProvider.notifier).state = p,
            model: model,
            tier: videoTier,
          ))
          // characterOutfits/characterIds previously stayed empty forever —
          // nothing ever set them. This is real, not placeholder: it's the
          // outfit this character actually has active right now.
          .copyWith(
            characterIds: [character.id],
            characterOutfits: character.activeOutfitId.isNotEmpty ? {character.id: character.activeOutfitId} : const {},
          );

      ref.read(sceneListProvider.notifier).addScene(scene);
      await PushNotificationService.showAlert(
        title: 'Drip Complete',
        body: 'Scene ${scene.sequenceIndex + 1} is ready',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      ref.read(isGeneratingProvider.notifier).state = false;
    }
  }

  void _showPaywall() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DripTheme.surface,
        title: const Text(
          'Out of Tokens',
          style: TextStyle(
            color: DripTheme.nebulaCyan,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Upgrade to Starter or Pro for more tokens, or grab a top-up pack.',
          style: TextStyle(color: DripTheme.chrome),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DripTheme.cosmicTeal,
              foregroundColor: DripTheme.voidBlack,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await PurchaseService.presentPaywall();
            },
            child: const Text('View Plans', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _recordVoicePrompt() async {
    final whisper = ref.read(whisperProvider);
    if (!await whisper.hasPermission()) return;

    if (_isRecording) {
      final path = await whisper.stopRecording();
      setState(() => _isRecording = false);
      if (path != null) {
        final text = await whisper.transcribe(path);
        _promptController.text = text;
      }
    } else {
      await whisper.startRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGenerating = ref.watch(isGeneratingProvider);
    final progress = ref.watch(generationProgressProvider);
    final scenes = ref.watch(sceneListProvider);
    final character = ref.watch(activeCharacterProvider);
    final characters = ref.watch(characterListProvider);
    final profile = ref.watch(userProfileProvider).value;
    final tokens = profile?.tokenBalance ?? 0;
    final lastScene = scenes.lastOrNull;
    final quality = ref.watch(videoQualityProvider);
    final cost = AiTiers.videoCost(
      durationSeconds: 5,
      quality: quality.name,
    );

    // Prefer last generated frame / video still; else active cast face.
    final previewUrl = lastScene?.generatedLastFrameUrl ??
        (character != null && character.faceReferenceUrls.isNotEmpty
            ? character.faceReferenceUrls.first
            : null);
    final hasVideo = lastScene?.outputVideoUrl != null &&
        lastScene!.outputVideoUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: Column(
        children: [
          // ── Large cinematic scene / cast frame ─────────────────────
          Expanded(
            flex: 42,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasVideo)
                  VideoPlayerWidget(
                    url: lastScene!.outputVideoUrl!,
                    autoPlay: true,
                    showControls: false,
                    loop: true,
                  )
                else if (previewUrl != null)
                  Image.network(
                    previewUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => _emptyPreview(),
                  )
                else
                  _emptyPreview(),
                // Soft bottom fade into controls
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          DripTheme.voidBlack.withOpacity(0),
                          DripTheme.voidBlack,
                        ],
                      ),
                    ),
                  ),
                ),
                if (isGenerating)
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Colors.transparent,
                      color: DripTheme.cosmicTeal,
                    ),
                  ),
              ],
            ),
          ),

          // ── Controls ───────────────────────────────────────────────
          Expanded(
            flex: 58,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CAST header
                  Row(
                    children: [
                      Text(
                        'CAST',
                        style: DripTheme.technical.copyWith(
                          color: DripTheme.muted,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CharacterCreationScreen(),
                          ),
                        ),
                        child: Text(
                          'NEW',
                          style: DripTheme.overline.copyWith(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: characters.isEmpty ? 1 : characters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        if (characters.isEmpty) {
                          return _castPill(
                            name: 'Add cast',
                            subtitle: 'New',
                            selected: false,
                            avatar: null,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CharacterCreationScreen(),
                              ),
                            ),
                          );
                        }
                        final c = characters[index];
                        final selected = character?.id == c.id;
                        return _castPill(
                          name: c.name,
                          subtitle: 'Locked',
                          selected: selected,
                          avatar: c.faceReferenceUrls.isNotEmpty
                              ? c.faceReferenceUrls.first
                              : null,
                          onTap: () {
                            ref.read(activeCharacterProvider.notifier).state = c;
                          },
                          onDoubleTap: () => _showCharacterCloset(context, c),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to cast. Double-tap to open the closet.',
                    style: DripTheme.meta.copyWith(
                      fontSize: 11,
                      color: DripTheme.faint,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // DIRECT
                  Text(
                    'DIRECT',
                    style: DripTheme.technical.copyWith(
                      color: DripTheme.muted,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1F24),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: DripTheme.hairlineStrong),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2, right: 10),
                          child: Icon(Icons.auto_awesome,
                              size: 18, color: DripTheme.cosmicTeal),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _promptController,
                            maxLines: 3,
                            minLines: 2,
                            style: const TextStyle(
                              color: DripTheme.warmWhite,
                              fontSize: 14,
                              height: 1.45,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText:
                                  'A woman discovers a door in her apartment that wasn\'t there yesterday',
                              hintStyle: TextStyle(
                                color: DripTheme.faint,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Camera modes — icon + label like sandbox
                  SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        for (final mode in _cameraModes)
                          Expanded(
                            child: _cameraModeBtn(
                              mode: mode,
                              selected: _selectedCameraMotion.toUpperCase() ==
                                      mode ||
                                  (_selectedCameraMotion == 'static' &&
                                      mode == 'LOCK'),
                              onTap: () => setState(
                                () => _selectedCameraMotion = mode,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mic · image · GENERATE
                  Row(
                    children: [
                      _roundToolBtn(
                        icon: _isRecording ? Icons.mic : Icons.mic_none,
                        active: _isRecording,
                        onTap: _recordVoicePrompt,
                      ),
                      const SizedBox(width: 10),
                      _roundToolBtn(
                        icon: Icons.image_outlined,
                        onTap: () {
                          final tier = ref
                              .read(userProfileProvider)
                              .value
                              ?.subscriptionTier;
                          showModelPickerSheet(
                            context,
                            initial: ModelPickerTab.video,
                            subscriptionTier: tier,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00C9A0),
                                  Color(0xFF1B5FFF),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: DripTheme.cosmicTeal.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(28),
                                onTap: isGenerating ? null : _generate,
                                child: Center(
                                  child: isGenerating
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.bolt,
                                                color: Colors.white, size: 20),
                                            SizedBox(width: 6),
                                            Text(
                                              'GENERATE',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 1.8,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${cost.tokens} tokens · you have $tokens',
                    style: DripTheme.meta.copyWith(
                      fontSize: 11,
                      color: DripTheme.faint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyPreview() {
    return Container(
      color: DripTheme.deepBlack,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_creation_outlined,
                size: 44, color: DripTheme.faint),
            SizedBox(height: 12),
            Text('Frame your next drip', style: DripTheme.meta),
            SizedBox(height: 4),
            Text(
              'Select a cast member or generate a scene',
              style: TextStyle(color: DripTheme.faint, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _castPill({
    required String name,
    required String subtitle,
    required bool selected,
    required String? avatar,
    required VoidCallback onTap,
    VoidCallback? onDoubleTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
        decoration: BoxDecoration(
          color: selected
              ? DripTheme.cosmicTeal.withOpacity(0.10)
              : const Color(0xFF1A1F24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? DripTheme.cosmicTeal.withOpacity(0.85)
                : DripTheme.hairlineStrong,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: DripTheme.surfaceRaised,
              backgroundImage:
                  avatar != null ? NetworkImage(avatar) : null,
              child: avatar == null
                  ? const Icon(Icons.person, size: 18, color: DripTheme.chrome)
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name.length > 12 ? '${name.substring(0, 11)}…' : name,
                  style: const TextStyle(
                    color: DripTheme.warmWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: selected ? DripTheme.cosmicTeal : DripTheme.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraModeBtn({
    required String mode,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final icons = <String, IconData>{
      'LOCK': Icons.center_focus_strong,
      'PAN': Icons.swap_horiz,
      'ZOOM': Icons.zoom_in,
      'ORBIT': Icons.sync,
      'WHIP': Icons.flash_on,
      'DRONE': Icons.flight,
    };
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 40,
            height: 36,
            decoration: BoxDecoration(
              color: selected
                  ? DripTheme.cosmicTeal.withOpacity(0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? DripTheme.cosmicTeal.withOpacity(0.5)
                    : Colors.transparent,
              ),
            ),
            child: Icon(
              icons[mode] ?? Icons.videocam,
              size: 20,
              color: selected ? DripTheme.cosmicTeal : DripTheme.muted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            mode,
            style: TextStyle(
              fontSize: 8,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
              color: selected ? DripTheme.cosmicTeal : DripTheme.faint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundToolBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return Material(
      color: const Color(0xFF1A1F24),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: active ? DripTheme.cosmicTeal : DripTheme.chrome,
            size: 22,
          ),
        ),
      ),
    );
  }

  void _showCharacterCloset(BuildContext context, Character? character) {
    if (character == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DripSwapperView(
        character: character,
        onOutfitSelected: (outfit) {
          ref.read(activeCharacterProvider.notifier).state =
              character.copyWith(activeOutfitId: outfit.id);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _stitchMasterCut() async {
    final scenes = ref.read(sceneListProvider);
    final paths = scenes.map((s) => s.outputVideoUrl!).whereType<String>().toList();
    if (paths.length < 2) return;

    ref.read(isGeneratingProvider.notifier).state = true;
    try {
      final masterPath = await ref.read(videoStitchProvider).concatenateScenes(paths);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Master cut saved: $masterPath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stitch failed: $e')),
      );
    } finally {
      ref.read(isGeneratingProvider.notifier).state = false;
    }
  }
}
