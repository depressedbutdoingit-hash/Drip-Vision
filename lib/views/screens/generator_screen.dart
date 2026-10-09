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

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: Column(
        children: [
          // Preview / last frame
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              color: DripTheme.deepBlack,
              child: lastScene?.outputVideoUrl != null
                  ? VideoPlayerWidget(url: lastScene!.outputVideoUrl!)
                  : (character != null && character.faceReferenceUrls.isNotEmpty)
                      ? Image.network(
                          character.faceReferenceUrls.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => _emptyPreview(),
                        )
                      : _emptyPreview(),
            ),
          ),
          if (isGenerating)
            LinearProgressIndicator(
              value: progress > 0 ? progress : null,
              backgroundColor: DripTheme.surface,
              color: DripTheme.cosmicTeal,
              minHeight: 2,
            ),
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('CAST', style: DripTheme.technical),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CharacterCreationScreen(),
                          ),
                        ),
                        child: const Text('NEW', style: DripTheme.overline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 78,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: characters.isEmpty ? 1 : characters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        if (characters.isEmpty) {
                          return _castChip(
                            name: 'Add cast',
                            locked: false,
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
                        return _castChip(
                          name: c.name,
                          locked: true,
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
                    style: DripTheme.meta.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 18),
                  const Text('DIRECT', style: DripTheme.technical),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: DripTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: DripTheme.hairlineStrong),
                    ),
                    child: TextField(
                      controller: _promptController,
                      maxLines: 3,
                      style: const TextStyle(
                        color: DripTheme.warmWhite,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText:
                            'A woman discovers a door in her apartment that wasn\'t there yesterday',
                        hintStyle: TextStyle(color: DripTheme.faint, fontSize: 14),
                        prefixIcon: Icon(Icons.auto_awesome,
                            size: 18, color: DripTheme.cosmicTeal),
                        prefixIconConstraints: BoxConstraints(minWidth: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final mode in _cameraModes)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                mode,
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedCameraMotion == mode
                                      ? DripTheme.voidBlack
                                      : DripTheme.chrome,
                                ),
                              ),
                              selected: _selectedCameraMotion == mode,
                              selectedColor: DripTheme.cosmicTeal,
                              backgroundColor: DripTheme.surfaceRaised,
                              side: BorderSide(
                                color: _selectedCameraMotion == mode
                                    ? DripTheme.cosmicTeal
                                    : DripTheme.hairline,
                              ),
                              onSelected: (_) =>
                                  setState(() => _selectedCameraMotion = mode),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _recordVoicePrompt,
                        style: IconButton.styleFrom(
                          backgroundColor: DripTheme.surfaceRaised,
                        ),
                        icon: Icon(
                          _isRecording ? Icons.mic : Icons.mic_none,
                          color: _isRecording
                              ? DripTheme.cosmicTeal
                              : DripTheme.chrome,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          final tier =
                              ref.read(userProfileProvider).value?.subscriptionTier;
                          showModelPickerSheet(
                            context,
                            initial: ModelPickerTab.video,
                            subscriptionTier: tier,
                          );
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: DripTheme.surfaceRaised,
                        ),
                        icon: const Icon(Icons.auto_fix_images_outlined,
                            color: DripTheme.chrome),
                      ),
                      const Spacer(),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00D4AA),
                                  Color(0xFF1A6BFF),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: DripTheme.cosmicTeal.withOpacity(0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: isGenerating ? null : _generate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              child: isGenerating
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.bolt, size: 20),
                                        SizedBox(width: 6),
                                        Text(
                                          'GENERATE',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.6,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${cost.tokens} tokens · you have $tokens',
                    style: DripTheme.meta.copyWith(fontSize: 11),
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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_creation_outlined, size: 40, color: DripTheme.faint),
          SizedBox(height: 10),
          Text('Frame your next drip', style: DripTheme.meta),
        ],
      ),
    );
  }

  Widget _castChip({
    required String name,
    required bool locked,
    required bool selected,
    required String? avatar,
    required VoidCallback onTap,
    VoidCallback? onDoubleTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Container(
        width: 108,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected
              ? DripTheme.cosmicTeal.withOpacity(0.12)
              : DripTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? DripTheme.cosmicTeal : DripTheme.hairlineStrong,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: DripTheme.surfaceRaised,
              backgroundImage:
                  avatar != null ? NetworkImage(avatar) : null,
              child: avatar == null
                  ? const Icon(Icons.person, size: 18, color: DripTheme.chrome)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DripTheme.warmWhite,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    locked ? 'Locked' : 'Open',
                    style: TextStyle(
                      color: locked ? DripTheme.muted : DripTheme.cosmicTeal,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
