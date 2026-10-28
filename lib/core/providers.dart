import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/media_action_service.dart';
import '../services/style_dna_service.dart';
import '../services/suno_service.dart';
import '../services/ai_director_service.dart';
import '../services/token_service.dart';
import '../services/openrouter_service.dart';
import '../services/video_stitching_service.dart';
import '../services/ai_generation_service.dart';
import '../services/continuity_service.dart';
import 'env.dart';

final mediaActionProvider = Provider<MediaActionService>((ref) => MediaActionService());
final styleDnaServiceProvider = Provider<StyleDnaService>((ref) => StyleDnaService(Env.openRouterKey));
final sunoServiceProvider = Provider<SunoService>((ref) => SunoService(Env.openRouterKey));
final aiDirectorServiceProvider = Provider<AIDirectorService>((ref) => AIDirectorService(Env.openRouterKey));
final tokenServiceProvider = Provider<TokenService>((ref) => TokenService());
final openRouterProvider = Provider<OpenRouterService>((ref) => OpenRouterService());
final videoStitchProvider = Provider<VideoStitchingService>((ref) => VideoStitchingService());
final aiGenerationServiceProvider = Provider<AIGenerationService>((ref) => AIGenerationService());
final continuityServiceProvider = Provider<ContinuityEngine>((ref) => ContinuityEngine());

export '../services/continuity_service.dart' show ContinuityEngine, continuityEngineProvider;
export 'continuity_providers.dart' show universeProvider, continuityHealthProvider, ContinuityHealth;
