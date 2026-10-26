// ---------------------------------------------------------------------------
// Service providers
// ---------------------------------------------------------------------------

final mediaActionProvider = Provider<MediaActionService>(
  (ref) => MediaActionService(),
);

final styleDnaServiceProvider = Provider<StyleDnaService>(
  (ref) => StyleDnaService(Env.openRouterKey),
);

final sunoServiceProvider = Provider<SunoService>(
  (ref) => SunoService(Env.openRouterKey),
);

final aiDirectorServiceProvider = Provider<AIDirectorService>(
  (ref) => AIDirectorService(),
);

final tokenServiceProvider = Provider<TokenService>(
  (ref) => TokenService(),
);

final openRouterProvider = Provider<OpenRouterService>(
  (ref) => OpenRouterService(),
);

final videoStitchProvider = Provider<VideoStitchingService>(
  (ref) => VideoStitchingService(),
);

final aiGenerationServiceProvider = Provider<AIGenerationService>(
  (ref) => AIGenerationService(),
);

final continuityServiceProvider = Provider<ContinuityEngine>(
  (ref) => ContinuityEngine(),
);