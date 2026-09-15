import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../services/drip_chain_service.dart';
import '../../services/drip_score_service.dart';
import '../widgets/cinematic_button.dart';
import '../widgets/cinematic_card.dart';

/// DRIP CHAINS + DRIP SCORE
/// Both already had complete Firestore-backed services with nothing in
/// the UI calling them. This screen is the first real surface for
/// DripChainService (open/trending/my chains, starting a chain from your
/// current cut) and DripScoreService (leaderboard + badges) — everything
/// here is a live Firestore read/write, not sample data.
class DripChainsScreen extends ConsumerStatefulWidget {
  const DripChainsScreen({super.key});

  @override
  ConsumerState<DripChainsScreen> createState() => _DripChainsScreenState();
}

enum _ChainTab { open, trending, mine }

class _DripChainsScreenState extends ConsumerState<DripChainsScreen> {
  _ChainTab _tab = _ChainTab.open;
  late Future<List<DripChainSummary>> _future = _load();
  bool _starting = false;

  Future<List<DripChainSummary>> _load() {
    final service = ref.read(dripChainProvider);
    switch (_tab) {
      case _ChainTab.open:
        return service.getOpenChains();
      case _ChainTab.trending:
        return service.getTrendingChains();
      case _ChainTab.mine:
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return Future.value(const []);
        return service.getUserChains(uid);
    }
  }

  void _switchTab(_ChainTab t) {
    setState(() {
      _tab = t;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scenes = ref.watch(sceneListProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('DRIP CHAINS', style: TextStyle(fontSize: 12, letterSpacing: 3))),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
              child: Row(
                children: [
                  _tabChip('OPEN CHAINS', _ChainTab.open),
                  const SizedBox(width: 8),
                  _tabChip('TRENDING', _ChainTab.trending),
                  const SizedBox(width: 8),
                  _tabChip('MY CHAINS', _ChainTab.mine),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<DripChainSummary>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: DripTheme.cosmicTeal));
                  }
                  if (snap.hasError) {
                    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Couldn\'t load chains: ${snap.error}', style: const TextStyle(color: DripTheme.muted), textAlign: TextAlign.center)));
                  }
                  final chains = snap.data ?? const [];
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 100),
                    children: [
                      if (chains.isEmpty)
                        CinematicCard(child: Text(_emptyMessage(), style: const TextStyle(color: DripTheme.muted, height: 1.5)))
                      else
                        ...chains.map((c) => _ChainCard(chain: c)),
                      const SizedBox(height: 26),
                      const Text('DRIP SCORE', style: TextStyle(fontSize: 9.5, letterSpacing: 2.2, color: DripTheme.muted, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 9),
                      FutureBuilder<List<LeaderboardEntry>>(
                        future: ref.read(dripScoreServiceProvider).getLeaderboard(limit: 5),
                        builder: (context, lbSnap) {
                          final entries = lbSnap.data ?? const [];
                          if (lbSnap.connectionState == ConnectionState.waiting) {
                            return const CinematicCard(child: Center(child: Padding(padding: EdgeInsets.all(6), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: DripTheme.cosmicTeal)))));
                          }
                          if (entries.isEmpty) {
                            return const CinematicCard(child: Text('No leaderboard yet — finish and share a film to appear here.', style: TextStyle(color: DripTheme.muted)));
                          }
                          return CinematicCard(
                            child: Column(
                              children: entries.asMap().entries.map((e) {
                                final i = e.key;
                                final entry = e.value;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 22, child: Text('${i + 1}', style: const TextStyle(color: DripTheme.aquaGlow, fontWeight: FontWeight.w700))),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                            Text(entry.creatorName, style: const TextStyle(fontSize: 10.5, color: DripTheme.muted)),
                                          ],
                                        ),
                                      ),
                                      Text('${entry.dripScore}', style: const TextStyle(fontWeight: FontWeight.w700, color: DripTheme.cosmicTeal)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: scenes.isEmpty
          ? null
          : FloatingActionButton.extended(
              backgroundColor: DripTheme.cosmicTeal,
              foregroundColor: DripTheme.voidBlack,
              icon: _starting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: DripTheme.voidBlack)) : const Icon(Icons.link),
              label: const Text('START A CHAIN', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: .5)),
              onPressed: _starting ? null : _startChain,
            ),
    );
  }

  String _emptyMessage() {
    switch (_tab) {
      case _ChainTab.open:
        return 'No open chains yet. Start one from your current cut and be the first link.';
      case _ChainTab.trending:
        return 'No finished chains yet — the first one could be yours.';
      case _ChainTab.mine:
        return 'You haven\'t started or joined a chain yet.';
    }
  }

  Widget _tabChip(String label, _ChainTab t) {
    final selected = _tab == t;
    return GestureDetector(
      onTap: () => _switchTab(t),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? DripTheme.cosmicTeal.withOpacity(.14) : Colors.white.withOpacity(.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? DripTheme.cosmicTeal.withOpacity(.5) : Colors.white.withOpacity(.07)),
        ),
        child: Text(label, style: TextStyle(fontSize: 10.5, letterSpacing: .8, fontWeight: FontWeight.w700, color: selected ? DripTheme.aquaGlow : DripTheme.muted)),
      ),
    );
  }

  Future<void> _startChain() async {
    final scenes = ref.read(sceneListProvider);
    if (scenes.isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in to start a chain.')));
      return;
    }
    setState(() => _starting = true);
    try {
      final genesis = scenes.first;
      final name = FirebaseAuth.instance.currentUser?.displayName ?? 'A Director';
      await ref.read(dripChainProvider).createChain(
            creatorId: uid,
            creatorName: name,
            title: genesis.prompt.split('.').first,
            genre: genesis.lighting ?? 'Cinematic',
            initialSceneId: genesis.id,
            initialScenePrompt: genesis.prompt,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chain started. Other creators can now extend it.')));
        _switchTab(_ChainTab.mine);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Couldn\'t start chain: $e')));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }
}

class _ChainCard extends StatelessWidget {
  final DripChainSummary chain;
  const _ChainCard({required this.chain});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CinematicCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chain.title.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: .5)),
                  const SizedBox(height: 5),
                  Text('${chain.genre} · started by ${chain.creatorName}', style: const TextStyle(fontSize: 11.5, color: DripTheme.muted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _pill(Icons.movie_outlined, '${chain.sceneCount} scenes'),
                      const SizedBox(width: 8),
                      _pill(Icons.people_outline, '${chain.contributorCount} directors'),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.04), borderRadius: BorderRadius.circular(7)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: DripTheme.chrome), const SizedBox(width: 4), Text(text, style: const TextStyle(fontSize: 10, color: DripTheme.chrome))]),
      );
}
