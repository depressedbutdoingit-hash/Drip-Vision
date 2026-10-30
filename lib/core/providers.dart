import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ai_director_service.dart';
import '../services/ai_generation_service.dart';
import '../services/continuity_service.dart';
import '../services/drip_chain_service.dart';
import '../services/drip_score_service.dart';
import '../services/media_action_service.dart';
import '../services/openrouter_service.dart';
import '../services/style_dna_service.dart';
import '../services/lyria_service.dart';
import '../services/token_service.dart';
import '../services/video_stitching_service.dart';
import 'env.dart';

export '../services/continuity_service.dart' show ContinuityEngine, continuityEngineProvider;
export 'continuity_providers.dart' show continuityHealthProvider, ContinuityHealth;

final mediaActionProvider = Provider<MediaActionService>((ref) => MediaActionService());
final styleDnaServiceProvider = Provider<StyleDnaService>((ref) => StyleDnaService(Env.openRouterKey));
final lyriaServiceProvider = Provider<LyriaService>((ref) => LyriaService(Env.openRouterKey));
final aiDirectorServiceProvider = Provider<AIDirectorService>((ref) => AIDirectorService(Env.openRouterKey));
final tokenServiceProvider = Provider<TokenService>((ref) => TokenService());
final openRouterProvider = Provider<OpenRouterService>((ref) => OpenRouterService());
final videoStitchProvider = Provider<VideoStitchingService>((ref) => VideoStitchingService());
final aiGenerationServiceProvider = Provider<AIGenerationService>((ref) => AIGenerationService());
final continuityServiceProvider = Provider<ContinuityEngine>((ref) => ContinuityEngine());
final dripChainProvider = Provider<DripChainService>(
  (ref) => DripChainService(FirebaseFirestore.instance),
);
final dripScoreServiceProvider = Provider<DripScoreService>(
  (ref) => DripScoreService(FirebaseFirestore.instance),
);
