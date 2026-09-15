import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../models/style_dna.dart';
import '../widgets/cinematic_button.dart';
import '../widgets/cinematic_card.dart';

/// STYLE DNA™
/// A library of reusable visual languages. Build one by hand, or lift it
/// straight from a reference image — StyleDnaService sends the image to
/// a vision-capable model and gets back lens/lighting/color/grain/contrast,
/// the same fields Director Mode's COLOR/LIGHTING controls understand.
class StyleDnaScreen extends ConsumerStatefulWidget {
  const StyleDnaScreen({super.key});

  @override
  ConsumerState<StyleDnaScreen> createState() => _StyleDnaScreenState();
}

class _StyleDnaScreenState extends ConsumerState<StyleDnaScreen> {
  bool _extracting = false;

  @override
  Widget build(BuildContext context) {
    final styles = ref.watch(styleListProvider);
    final active = ref.watch(activeStyleProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('STYLE DNA™', style: TextStyle(fontSize: 12, letterSpacing: 3))),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Save a visual language once. Apply it to any project.', style: TextStyle(color: DripTheme.muted, height: 1.4)),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(child: CinematicButton(label: 'CREATE STYLE', icon: Icons.add_circle_outline, primary: false, onPressed: () => _showManualEditor(context))),
                      const SizedBox(width: 10),
                      Expanded(child: CinematicButton(label: 'FROM IMAGE', icon: Icons.image_outlined, onPressed: _extracting ? null : () => _createFromImage(context))),
                    ],
                  ),
                  if (_extracting) ...[
                    const SizedBox(height: 14),
                    const CinematicCard(
                      child: Row(children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: DripTheme.cosmicTeal)),
                        SizedBox(width: 12),
                        Expanded(child: Text('Reading lighting, color, grain and lens character from your image…', style: TextStyle(color: DripTheme.muted))),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 26),

                  if (styles.isEmpty)
                    CinematicCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('No styles saved yet.', style: TextStyle(color: DripTheme.muted)),
                          SizedBox(height: 4),
                          Text('Every recurring look — a location\'s mood, a film stock, an era — starts here.', style: TextStyle(color: DripTheme.muted, fontSize: 12.5, height: 1.4)),
                        ],
                      ),
                    )
                  else
                    ...styles.map((s) => _StyleCard(
                          style: s,
                          isActive: active?.id == s.id,
                          onApply: () => ref.read(activeStyleProvider.notifier).state = s,
                          onEdit: () => _showManualEditor(context, existing: s),
                          onDuplicate: () => ref.read(styleListProvider.notifier).duplicateStyle(s.id),
                          onDelete: () {
                            ref.read(styleListProvider.notifier).removeStyle(s.id);
                            if (active?.id == s.id) ref.read(activeStyleProvider.notifier).state = null;
                          },
                        )),
                ],
              ),
            ),
            if (active != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
                  decoration: BoxDecoration(color: DripTheme.voidBlack.withOpacity(.92), border: Border(top: BorderSide(color: Colors.white.withOpacity(.06)))),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: DripTheme.aquaGlow, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${active.name.toUpperCase()} applied to this project', style: const TextStyle(fontSize: 11, letterSpacing: .3, fontWeight: FontWeight.w600))),
                      TextButton(onPressed: () => ref.read(activeStyleProvider.notifier).state = null, child: const Text('REMOVE', style: TextStyle(fontSize: 10, color: DripTheme.muted))),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _createFromImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() => _extracting = true);
    try {
      final bytes = await File(picked.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      final style = await ref.read(styleDnaServiceProvider).analyzeImage(base64Image);
      ref.read(styleListProvider.notifier).addStyle(style);
      if (mounted) _showManualEditor(context, existing: style, justExtracted: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Couldn\'t read that image: $e'), backgroundColor: DripTheme.surfaceRaised));
      }
    } finally {
      if (mounted) setState(() => _extracting = false);
    }
  }

  void _showManualEditor(BuildContext context, {StyleDna? existing, bool justExtracted = false}) {
    final isNew = existing == null && !justExtracted;
    final nameCtl = TextEditingController(text: existing?.name ?? '');
    final lensCtl = TextEditingController(text: existing?.lens ?? '');
    final colorCtl = TextEditingController(text: existing?.colorPalette ?? '');
    final lightingCtl = TextEditingController(text: existing?.lighting ?? '');
    final grainCtl = TextEditingController(text: existing?.grain ?? '');
    final contrastCtl = TextEditingController(text: existing?.contrast ?? '');
    final tagsCtl = TextEditingController(text: existing?.tags.join(', ') ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          decoration: const BoxDecoration(color: DripTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(justExtracted ? 'STYLE EXTRACTED · REVIEW' : (isNew ? 'NEW STYLE' : 'EDIT STYLE'), style: const TextStyle(fontSize: 10, letterSpacing: 2.4, color: DripTheme.cosmicTeal, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                _labeled('NAME', nameCtl, hint: 'e.g. Neon Noir'),
                _labeled('LENS', lensCtl, hint: 'e.g. 35mm'),
                _labeled('COLOR PALETTE', colorCtl, hint: 'e.g. cyan and amber'),
                _labeled('LIGHTING', lightingCtl, hint: 'e.g. hard, low-key, wet reflections'),
                _labeled('GRAIN', grainCtl, hint: 'e.g. fine film grain, soft halation'),
                _labeled('CONTRAST', contrastCtl, hint: 'e.g. high contrast, crushed blacks'),
                _labeled('TAGS', tagsCtl, hint: 'comma separated'),
                const SizedBox(height: 6),
                CinematicButton(
                  label: 'SAVE STYLE',
                  icon: Icons.save_outlined,
                  onPressed: () {
                    if (nameCtl.text.trim().isEmpty) return;
                    final style = StyleDna(
                      id: existing?.id ?? 'style_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtl.text.trim(),
                      lens: lensCtl.text.trim(),
                      colorPalette: colorCtl.text.trim(),
                      lighting: lightingCtl.text.trim(),
                      grain: grainCtl.text.trim(),
                      contrast: contrastCtl.text.trim(),
                      tags: tagsCtl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
                      sourceImageUrl: existing?.sourceImageUrl,
                      createdAt: existing?.createdAt ?? DateTime.now(),
                    );
                    if (existing != null && ref.read(styleListProvider).any((s) => s.id == existing.id)) {
                      ref.read(styleListProvider.notifier).updateStyle(style);
                    } else {
                      ref.read(styleListProvider.notifier).addStyle(style);
                    }
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _labeled(String label, TextEditingController ctl, {required String hint}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9.5, letterSpacing: 2, color: DripTheme.muted)),
            const SizedBox(height: 5),
            TextField(controller: ctl, style: const TextStyle(color: DripTheme.warmWhite), decoration: InputDecoration(hintText: hint)),
          ],
        ),
      );
}

class _StyleCard extends StatelessWidget {
  final StyleDna style;
  final bool isActive;
  final VoidCallback onApply, onEdit, onDuplicate, onDelete;
  const _StyleCard({required this.style, required this.isActive, required this.onApply, required this.onEdit, required this.onDuplicate, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CinematicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(style.name.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: .5))),
                if (isActive) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: DripTheme.cosmicTeal.withOpacity(.14), borderRadius: BorderRadius.circular(7)), child: const Text('APPLIED', style: TextStyle(fontSize: 9, letterSpacing: 1, color: DripTheme.aquaGlow, fontWeight: FontWeight.w700))),
              ],
            ),
            if (style.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: style.tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(.04), borderRadius: BorderRadius.circular(8)), child: Text(t, style: const TextStyle(fontSize: 10.5, color: DripTheme.chrome)))).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: CinematicButton(label: isActive ? 'APPLIED' : 'APPLY TO PROJECT', icon: Icons.check_circle_outline, primary: !isActive, onPressed: isActive ? null : onApply)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _iconAction(Icons.edit_outlined, onEdit),
                _iconAction(Icons.copy_outlined, onDuplicate),
                _iconAction(Icons.delete_outline, onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconAction(IconData icon, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.white.withOpacity(.03), borderRadius: BorderRadius.circular(9)), child: Icon(icon, size: 16, color: DripTheme.chrome)),
        ),
      );
}
