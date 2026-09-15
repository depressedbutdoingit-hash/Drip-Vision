import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../widgets/video_player_widget.dart';

final exploreFeedProvider = StreamProvider<List<DripFeedItem>>((ref) {
  return FirebaseFirestore.instance
      .collection('public_scenes')
      .orderBy('dripCount', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => DripFeedItem.fromDoc(d)).toList());
});

final userDripsProvider = StateProvider<Set<String>>((ref) => {});

class DripFeedItem {
  final String id;
  final String videoUrl;
  final String creatorName;
  final String? creatorAvatar;
  final String title;
  final String description;
  final int dripCount;
  final int remixCount;
  final DateTime createdAt;
  final List<String> tags;
  final String? creatorId;

  DripFeedItem({
    required this.id,
    required this.videoUrl,
    required this.creatorName,
    this.creatorAvatar,
    required this.title,
    required this.description,
    required this.dripCount,
    required this.remixCount,
    required this.createdAt,
    required this.tags,
    this.creatorId,
  });

  factory DripFeedItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DripFeedItem(
      id: doc.id,
      videoUrl: data['videoUrl'] ?? '',
      creatorName: data['creatorName'] ?? 'Anonymous',
      creatorAvatar: data['creatorAvatar'],
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
      dripCount: data['dripCount'] ?? 0,
      remixCount: data['remixCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] ?? []),
      creatorId: data['creatorId'],
    );
  }
}

class ExploreDripScreen extends ConsumerStatefulWidget {
  const ExploreDripScreen({super.key});

  @override
  ConsumerState<ExploreDripScreen> createState() => _ExploreDripScreenState();
}

class _ExploreDripScreenState extends ConsumerState<ExploreDripScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(exploreFeedProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: feedAsync.when(
        data: (items) => items.isEmpty
            ? _buildEmptyState()
            : PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildDripCard(items[index]);
                },
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: DripTheme.cosmicTeal),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.white30)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_filter, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            'NO DRIPS YET',
            style: TextStyle(
              color: Colors.white30,
              letterSpacing: 4,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to create something',
            style: TextStyle(color: Colors.white20, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDripCard(DripFeedItem item) {
    final userDrips = ref.watch(userDripsProvider);
    final hasDripped = userDrips.contains(item.id);
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black,
          child: item.videoUrl.isNotEmpty
              ? VideoPlayerWidget(
                  url: item.videoUrl,
                  autoPlay: _currentIndex == 0,
                  showControls: false,
                )
              : Center(
                  child: Icon(
                    Icons.movie_creation,
                    size: 64,
                    color: Colors.white10,
                  ),
                ),
        ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                DripTheme.voidBlack.withOpacity(0.6),
                DripTheme.voidBlack.withOpacity(0.9),
              ],
              stops: const [0.0, 0.5, 0.75, 1.0],
            ),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'EXPLORE DRIPS',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 6,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          right: 16,
          bottom: screenHeight * 0.15,
          child: Column(
            children: [
              _buildActionButton(
                icon: Icons.bolt,
                activeIcon: Icons.bolt,
                label: 'DRIP',
                count: item.dripCount,
                isActive: hasDripped,
                activeColor: DripTheme.cosmicTeal,
                onTap: () => _handleDrip(item),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.auto_fix_high_outlined,
                activeIcon: Icons.auto_fix_high,
                label: 'REMIX',
                count: item.remixCount,
                isActive: false,
                activeColor: Colors.purpleAccent,
                onTap: () => _handleRemix(item),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.bookmark_border,
                activeIcon: Icons.bookmark,
                label: 'SAVE',
                count: null,
                isActive: false,
                activeColor: Colors.amber,
                onTap: () => _handleSave(item),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.share_outlined,
                activeIcon: Icons.share,
                label: 'SHARE',
                count: null,
                isActive: false,
                activeColor: Colors.white,
                onTap: () => _handleShare(item),
              ),
            ],
          ),
        ),

        Positioned(
          left: 20,
          right: 80,
          bottom: screenHeight * 0.08,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DripTheme.cosmicTeal.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: item.creatorAvatar != null
                          ? Image.network(item.creatorAvatar!, fit: BoxFit.cover)
                          : Container(
                              color: Colors.white.withOpacity(0.05),
                              child: Icon(Icons.person, size: 18, color: Colors.white30),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '@${item.creatorName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: DripTheme.cosmicTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'CREATOR',
                      style: TextStyle(
                        fontSize: 9,
                        color: DripTheme.cosmicTeal,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: item.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int? count,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isActive ? activeColor.withOpacity(0.2) : Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? activeColor.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? activeColor : Colors.white.withOpacity(0.8),
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              color: isActive ? activeColor : Colors.white.withOpacity(0.5),
            ),
          ),
          if (count != null) ...[
            const SizedBox(height: 2),
            Text(
              _formatCount(count),
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  void _handleDrip(DripFeedItem item) {
    final userDrips = ref.read(userDripsProvider);
    final newSet = Set<String>.from(userDrips);

    if (newSet.contains(item.id)) {
      newSet.remove(item.id);
      FirebaseFirestore.instance.collection('public_scenes').doc(item.id).update({
        'dripCount': FieldValue.increment(-1),
      });
    } else {
      newSet.add(item.id);
      FirebaseFirestore.instance.collection('public_scenes').doc(item.id).update({
        'dripCount': FieldValue.increment(1),
      });
      _rewardCreator(item);
    }

    ref.read(userDripsProvider.notifier).state = newSet;
  }

  Future<void> _rewardCreator(DripFeedItem item) async {
    if (item.creatorId == null) return;
    await FirebaseFirestore.instance.collection('users').doc(item.creatorId).update({
      'tokens': FieldValue.increment(1),
      'totalDripsReceived': FieldValue.increment(1),
    });
  }

  void _handleRemix(DripFeedItem item) {
    Navigator.pushNamed(
      context,
      '/studio',
      arguments: {
        'templateId': item.id,
        'prompt': item.description,
        'tags': item.tags,
      },
    );
  }

  void _handleSave(DripFeedItem item) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('saved')
        .doc(item.id)
        .set({
      'sceneId': item.id,
      'savedAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved to your collection'),
        backgroundColor: Colors.black.withOpacity(0.8),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleShare(DripFeedItem item) {
    // Use share_plus package
  }
}
