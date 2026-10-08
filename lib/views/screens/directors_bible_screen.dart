import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../models/film_bible.dart';
import '../widgets/drip_button.dart';
import 'character_lab_screen.dart';
import 'continuity_health_screen.dart';

/// DIRECTOR'S BIBLE — living source of truth for the production.
class DirectorsBibleScreen extends ConsumerStatefulWidget {
  const DirectorsBibleScreen({super.key});

  @override
  ConsumerState<DirectorsBibleScreen> createState() =>
      _DirectorsBibleScreenState();
}

class _DirectorsBibleScreenState extends ConsumerState<DirectorsBibleScreen> {
  late final TextEditingController _title;
  late final TextEditingController _genre;
  late final TextEditingController _era;
  late final TextEditingController _mood;
  late final TextEditingController _logline;
  late final TextEditingController _rules;
  late final TextEditingController _props;

  @override
  void initState() {
    super.initState();
    final b = ref.read(filmBibleProvider);
    _title = TextEditingController(text: b.title);
    _genre = TextEditingController(text: b.genre);
    _era = TextEditingController(text: b.era);
    _mood = TextEditingController(text: b.mood);
    _logline = TextEditingController(text: b.logline);
    _rules = TextEditingController(text: b.visualRules.join('\n'));
    _props = TextEditingController(text: b.propNames.join(', '));
  }

  @override
  void dispose() {
    _title.dispose();
    _genre.dispose();
    _era.dispose();
    _mood.dispose();
    _logline.dispose();
    _rules.dispose();
    _props.dispose();
    super.dispose();
  }

  void _save() {
    final rules = _rules.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final props = _props.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    ref.read(filmBibleProvider.notifier).state = FilmBible(
      title: _title.text.trim(),
      genre: _genre.text.trim(),
      era: _era.text.trim(),
      format: ref.read(filmBibleProvider).format,
      filmStock: ref.read(filmBibleProvider).filmStock,
      colorLanguage: ref.read(filmBibleProvider).colorLanguage,
      cameraLanguage: ref.read(filmBibleProvider).cameraLanguage,
      mood: _mood.text.trim(),
      visualRules: rules,
      propNames: props,
      logline: _logline.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bible saved to this session')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final characters = ref.watch(characterListProvider);
    final scenes = ref.watch(sceneListProvider);
    final bible = ref.watch(filmBibleProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: const Text("DIRECTOR'S BIBLE", style: DripTheme.brandMark),
        actions: [
          IconButton(
            tooltip: 'Continuity',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContinuityHealthScreen()),
            ),
            icon: const Icon(Icons.monitor_heart_outlined, size: 20),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          const Text('THE WORLD', style: DripTheme.overline),
          const SizedBox(height: 8),
          Text(
            bible.title.isEmpty ? 'Untitled production' : bible.title,
            style: DripTheme.display.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 6),
          Text(
            'Cast ${characters.length} · Scenes ${scenes.length} · Source of truth',
            style: DripTheme.meta,
          ),
          const SizedBox(height: 24),
          _field('FILM TITLE', _title, 'Motel Mary'),
          _field('GENRE', _genre, 'Southern Gothic / Crime'),
          _field('ERA', _era, '1978'),
          _field('MOOD', _mood, 'Sweaty, lonely, dangerous'),
          _field('LOGLINE', _logline, 'One sentence the film never forgets', maxLines: 3),
          _field(
            'VISUAL RULES',
            _rules,
            'One rule per line\nNo smartphones\nNo LED lighting',
            maxLines: 5,
          ),
          _field('PROPS', _props, 'Red lighter, revolver, Polaroid'),
          const SizedBox(height: 8),
          DripButton(
            width: double.infinity,
            height: 48,
            onPressed: _save,
            child: const Text('SAVE BIBLE'),
          ),
          const SizedBox(height: 32),
          const Text('CAST', style: DripTheme.overline),
          const SizedBox(height: 12),
          if (characters.isEmpty)
            _linkCard(
              'No cast yet',
              'Open Character Lab to lock identity DNA',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CharacterLabScreen()),
              ),
            )
          else
            ...characters.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: DripTheme.surface,
                    borderRadius: BorderRadius.circular(DripTheme.radiusMd),
                    border: Border.all(color: DripTheme.hairline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                letterSpacing: 1.2,
                                color: DripTheme.warmWhite,
                              ),
                            ),
                            Text(
                              c.continuityLock
                                  ? 'Continuity DNA on · ${c.closet.length} looks'
                                  : 'Continuity off',
                              style: DripTheme.meta,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        c.continuityLock
                            ? Icons.lock_outline
                            : Icons.lock_open_outlined,
                        size: 16,
                        color: c.continuityLock
                            ? DripTheme.cosmicTeal
                            : DripTheme.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          const Text('FORMAT', style: DripTheme.overline),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['2.39:1', '16:9', '9:16', '1:1'].map((f) {
              final on = bible.format == f;
              return GestureDetector(
                onTap: () {
                  ref.read(filmBibleProvider.notifier).state =
                      bible.copyWith(format: f);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: on ? DripTheme.surfaceLight : DripTheme.surface,
                    borderRadius: BorderRadius.circular(DripTheme.radiusSm),
                    border: Border.all(
                      color: on
                          ? DripTheme.cosmicTeal.withOpacity(0.4)
                          : DripTheme.hairline,
                    ),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      fontSize: 12,
                      color: on ? DripTheme.cosmicTeal : DripTheme.chrome,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c,
    String hint, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: DripTheme.overline),
          const SizedBox(height: 8),
          TextField(
            controller: c,
            maxLines: maxLines,
            style: const TextStyle(color: DripTheme.warmWhite, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: DripTheme.muted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkCard(String title, String sub, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DripTheme.surface,
          borderRadius: BorderRadius.circular(DripTheme.radiusMd),
          border: Border.all(color: DripTheme.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: DripTheme.title.copyWith(fontSize: 14)),
            const SizedBox(height: 4),
            Text(sub, style: DripTheme.meta),
          ],
        ),
      ),
    );
  }
}
