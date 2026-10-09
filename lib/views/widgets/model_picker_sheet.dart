import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ai_model_catalog.dart';
import '../../core/ai_tiers.dart';
import '../../core/model_prefs.dart';
import '../../core/product_models.dart';
import '../../core/theme.dart';

enum ModelPickerTab { text, image, video }

/// Premium model picker — product defaults + full free/mid/high catalog.
Future<void> showModelPickerSheet(
  BuildContext context, {
  ModelPickerTab initial = ModelPickerTab.video,
  String? subscriptionTier,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ModelPickerBody(
      initial: initial,
      subscriptionTier: subscriptionTier,
    ),
  );
}

class _ModelPickerBody extends ConsumerStatefulWidget {
  final ModelPickerTab initial;
  final String? subscriptionTier;

  const _ModelPickerBody({
    required this.initial,
    this.subscriptionTier,
  });

  @override
  ConsumerState<_ModelPickerBody> createState() => _ModelPickerBodyState();
}

class _ModelPickerBodyState extends ConsumerState<_ModelPickerBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initial.index,
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  bool _allowed(CatalogModel m) {
    final available =
        AiModelCatalog.availableForSubscription(widget.subscriptionTier);
    return available.any((x) => x.id == m.id);
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * 0.78;
    return Container(
      height: h,
      decoration: const BoxDecoration(
        color: DripTheme.surfaceRaised,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 3,
            decoration: BoxDecoration(
              color: DripTheme.chrome.withOpacity(0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('MODELS', style: DripTheme.overline),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(videoModelOverrideProvider.notifier).state = null;
                    ref.read(imageModelOverrideProvider.notifier).state = null;
                    ref.read(textModelOverrideProvider.notifier).state = null;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reset to product defaults'),
                      ),
                    );
                    setState(() {});
                  },
                  child: const Text('RESET', style: DripTheme.meta),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Defaults are tuned for continuity. Overrides are advanced.',
              style: DripTheme.meta.copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: _tabs,
            labelColor: DripTheme.warmWhite,
            unselectedLabelColor: DripTheme.muted,
            indicatorColor: DripTheme.cosmicTeal,
            labelStyle: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'TEXT'),
              Tab(text: 'IMAGE'),
              Tab(text: 'VIDEO'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildTextTab(),
                _buildImageTab(),
                _buildVideoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTab() {
    final selected = ref.watch(textModelOverrideProvider);
    return _CatalogList(
      sections: [
        _Section('PRODUCT DEFAULTS', [
          ProductModels.textFree,
          ProductModels.textMid,
          ProductModels.textHigh,
          ProductModels.textFlagship,
        ]),
        _Section('FREE', AiModelCatalog.textFree.map((m) => m.id).toList()),
        _Section('MID', AiModelCatalog.textMid.map((m) => m.id).toList()),
        _Section('HIGH', AiModelCatalog.textHigh.map((m) => m.id).toList()),
      ],
      selectedId: selected,
      allowed: _allowed,
      onSelect: (id) {
        ref.read(textModelOverrideProvider.notifier).state = id;
        Navigator.pop(context);
      },
      onClear: () {
        ref.read(textModelOverrideProvider.notifier).state = null;
        Navigator.pop(context);
      },
    );
  }

  Widget _buildImageTab() {
    final selected = ref.watch(imageModelOverrideProvider);
    final quality = ref.watch(imageQualityProvider);
    return Column(
      children: [
        _QualityRow(
          labels: const ['DRAFT', 'STANDARD', 'PRO'],
          selected: quality.index.clamp(0, 2),
          onSelect: (i) {
            ref.read(imageQualityProvider.notifier).state =
                ImageGenTier.values[i];
            setState(() {});
          },
        ),
        Expanded(
          child: _CatalogList(
            sections: [
              _Section('PRODUCT DEFAULTS', [
                ProductModels.imageDraft,
                ProductModels.imageStandard,
                ProductModels.imagePro,
              ]),
              _Section(
                  'FREE', AiModelCatalog.imageFree.map((m) => m.id).toList()),
              _Section(
                  'MID', AiModelCatalog.imageMid.map((m) => m.id).toList()),
              _Section(
                  'HIGH', AiModelCatalog.imageHigh.map((m) => m.id).toList()),
            ],
            selectedId: selected,
            allowed: _allowed,
            onSelect: (id) {
              ref.read(imageModelOverrideProvider.notifier).state = id;
              Navigator.pop(context);
            },
            onClear: () {
              ref.read(imageModelOverrideProvider.notifier).state = null;
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoTab() {
    final selected = ref.watch(videoModelOverrideProvider);
    final quality = ref.watch(videoQualityProvider);
    return Column(
      children: [
        _QualityRow(
          labels: const ['DRAFT', 'PRO', 'CINEMA'],
          selected: quality.index,
          onSelect: (i) {
            ref.read(videoQualityProvider.notifier).state =
                VideoGenTier.values[i];
            setState(() {});
          },
        ),
        Expanded(
          child: _CatalogList(
            sections: [
              _Section('PRODUCT DEFAULTS', [
                ProductModels.videoDraft,
                ProductModels.videoPro,
                ProductModels.videoCinema,
              ]),
              _Section(
                  'DRAFT', AiModelCatalog.videoFree.map((m) => m.id).toList()),
              _Section(
                  'MID', AiModelCatalog.videoMid.map((m) => m.id).toList()),
              _Section(
                  'HIGH', AiModelCatalog.videoHigh.map((m) => m.id).toList()),
            ],
            selectedId: selected,
            allowed: _allowed,
            onSelect: (id) {
              ref.read(videoModelOverrideProvider.notifier).state = id;
              Navigator.pop(context);
            },
            onClear: () {
              ref.read(videoModelOverrideProvider.notifier).state = null;
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}

class _Section {
  final String title;
  final List<String> ids;
  const _Section(this.title, this.ids);
}

class _QualityRow extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  const _QualityRow({
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected == i
                        ? DripTheme.cosmicTeal.withOpacity(0.15)
                        : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected == i
                          ? DripTheme.cosmicTeal.withOpacity(0.5)
                          : Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: selected == i
                          ? DripTheme.warmWhite
                          : DripTheme.muted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CatalogList extends StatelessWidget {
  final List<_Section> sections;
  final String? selectedId;
  final bool Function(CatalogModel) allowed;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  const _CatalogList({
    required this.sections,
    required this.selectedId,
    required this.allowed,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Use product default',
            style: TextStyle(color: DripTheme.warmWhite, fontSize: 13),
          ),
          subtitle: const Text(
            'Recommended for continuity',
            style: DripTheme.meta,
          ),
          trailing: selectedId == null
              ? const Icon(Icons.check, color: DripTheme.cosmicTeal, size: 18)
              : null,
          onTap: onClear,
        ),
        const Divider(color: Colors.white12),
        for (final section in sections) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(section.title, style: DripTheme.overline),
          ),
          for (final id in section.ids)
            Builder(
              builder: (context) {
                final m = AiModelCatalog.byId(id);
                final label = m?.label ?? id.split('/').last;
                final notes = m?.notes ?? '';
                final ok = m == null || allowed(m);
                final isSel = selectedId == id;
                return Opacity(
                  opacity: ok ? 1 : 0.35,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: ok,
                    title: Text(
                      label,
                      style: TextStyle(
                        color: isSel
                            ? DripTheme.aquaGlow
                            : DripTheme.warmWhite,
                        fontSize: 13,
                        fontWeight:
                            isSel ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      notes.isNotEmpty ? '$notes\n$id' : id,
                      style: DripTheme.meta.copyWith(fontSize: 10),
                    ),
                    isThreeLine: notes.isNotEmpty,
                    trailing: isSel
                        ? const Icon(Icons.check,
                            color: DripTheme.cosmicTeal, size: 18)
                        : null,
                    onTap: ok ? () => onSelect(id) : null,
                  ),
                );
              },
            ),
        ],
      ],
    );
  }
}
