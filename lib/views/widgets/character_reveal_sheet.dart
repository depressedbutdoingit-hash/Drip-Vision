import 'dart:io';

import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/character.dart';
import 'cinematic_button.dart';

/// Premium popup after a character is created.
Future<void> showCharacterReveal(
  BuildContext context, {
  required Character character,
  VoidCallback? onOpenLab,
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
            child: CharacterRevealCard(
              character: character,
              onOpenLab: onOpenLab,
            ),
          ),
        ),
      );
    },
  );
}

class CharacterRevealCard extends StatelessWidget {
  final Character character;
  final VoidCallback? onOpenLab;

  const CharacterRevealCard({
    super.key,
    required this.character,
    this.onOpenLab,
  });

  @override
  Widget build(BuildContext context) {
    final img = character.faceReferenceUrls.isNotEmpty
        ? character.faceReferenceUrls.first
        : character.activeOutfit?.outfitImageUrl;
    final style = character.defaultStylePrompt;

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
                    child: Text('CHARACTER LOCKED', style: DripTheme.overline),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18, color: DripTheme.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: DripTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(DripTheme.radiusMd),
                    border: Border.all(color: DripTheme.hairline),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _portrait(img),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                children: [
                  Text(
                    character.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      letterSpacing: 2.4,
                      fontWeight: FontWeight.w500,
                      color: DripTheme.warmWhite,
                    ),
                  ),
                  if (style.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      style,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DripTheme.meta,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          character.continuityLock
                              ? Icons.lock_outline
                              : Icons.lock_open_outlined,
                          size: 14,
                          color: DripTheme.cosmicTeal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          character.continuityLock
                              ? 'CONTINUITY DNA · ON'
                              : 'CONTINUITY DNA · OFF',
                          style: const TextStyle(
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
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: CinematicButton(
                      label: 'OPEN IN CHARACTER LAB',
                      icon: Icons.person_outline,
                      onPressed: () {
                        Navigator.pop(context);
                        onOpenLab?.call();
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: CinematicButton(
                      label: 'DONE',
                      primary: false,
                      onPressed: () => Navigator.pop(context),
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

  Widget _portrait(String? img) {
    if (img == null || img.isEmpty) {
      return const Center(
        child: Icon(Icons.person_outline, size: 48, color: DripTheme.muted),
      );
    }
    if (img.startsWith('http')) {
      return Image.network(
        img,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.person_outline,
          size: 48,
          color: DripTheme.muted,
        ),
      );
    }
    final file = File(img);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return const Center(
      child: Icon(Icons.person_outline, size: 48, color: DripTheme.muted),
    );
  }
}
