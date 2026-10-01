import 'dart:io';

import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/character_dna.dart';
import 'cinematic_button.dart';

/// Premium popup after an outfit is minted to the wardrobe.
Future<void> showOutfitReveal(
  BuildContext context, {
  required Outfit outfit,
  String? characterName,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.72),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(curved),
          child: Center(
            child: OutfitRevealCard(
              outfit: outfit,
              characterName: characterName,
            ),
          ),
        ),
      );
    },
  );
}

class OutfitRevealCard extends StatelessWidget {
  final Outfit outfit;
  final String? characterName;

  const OutfitRevealCard({
    super.key,
    required this.outfit,
    this.characterName,
  });

  @override
  Widget build(BuildContext context) {
    final tags = outfit.tags.where((t) => t != 'custom').toList();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.88,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: DripTheme.surface,
          borderRadius: BorderRadius.circular(DripTheme.radiusLg),
          border: Border.all(color: DripTheme.hairlineStrong),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('OUTFIT MINTED', style: DripTheme.overline),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18, color: DripTheme.muted),
                  ),
                ],
              ),
            ),
            if (characterName != null && characterName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'FOR ${characterName!.toUpperCase()}',
                    style: DripTheme.technical,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: DripTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(DripTheme.radiusMd),
                    border: Border.all(color: DripTheme.hairline),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _image(outfit.referenceImageUrl),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
              child: Column(
                children: [
                  Text(
                    outfit.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      letterSpacing: 2.2,
                      fontWeight: FontWeight.w500,
                      color: DripTheme.warmWhite,
                    ),
                  ),
                  if (outfit.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      outfit.description,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: DripTheme.body.copyWith(fontSize: 13),
                    ),
                  ],
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: tags
                          .map(
                            (t) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  DripTheme.radiusSm,
                                ),
                                border: Border.all(color: DripTheme.hairline),
                                color: const Color(0x08FFFFFF),
                              ),
                              child: Text(
                                t,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: DripTheme.chrome,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: DripTheme.cosmicTeal.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(DripTheme.radiusSm),
                      border: Border.all(
                        color: DripTheme.cosmicTeal.withOpacity(0.25),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.checkroom_outlined,
                          size: 14,
                          color: DripTheme.cosmicTeal,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'ADDED TO WARDROBE',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w600,
                            color: DripTheme.cosmicTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: CinematicButton(
                  label: 'CONTINUE',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(String? path) {
    if (path == null || path.isEmpty) {
      return const Center(
        child: Icon(Icons.checkroom_outlined, size: 48, color: DripTheme.muted),
      );
    }
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.checkroom_outlined,
          size: 48,
          color: DripTheme.muted,
        ),
      );
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return const Center(
      child: Icon(Icons.checkroom_outlined, size: 48, color: DripTheme.muted),
    );
  }
}
