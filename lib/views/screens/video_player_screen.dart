import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    this.title = 'Preview',
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    setState(() {
      _error = null;
      _initialized = false;
    });
    final url = widget.videoUrl.trim();
    if (url.isEmpty || !url.startsWith('http')) {
      setState(() => _error = 'No video URL returned. Generation may still be processing, or the model did not return a playable link.');
      return;
    }
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _videoController = controller;
      await controller.initialize();
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        aspectRatio: controller.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: DripTheme.teal,
          handleColor: DripTheme.teal,
          backgroundColor: DripTheme.gunmetalLight,
          bufferedColor: DripTheme.silver.withOpacity(0.4),
        ),
        placeholder: Container(color: DripTheme.voidBlack),
      );
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not play video: $e');
    }
  }

  Future<void> _share() async {
    final url = widget.videoUrl.trim();
    if (url.isEmpty) return;
    await Share.share('$url\nMade with DripVision', subject: widget.title);
  }

  Future<void> _openApp(String scheme, String fallback) async {
    final uri = Uri.parse(scheme);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(Uri.parse(fallback), mode: LaunchMode.externalApplication);
    }
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12161A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _shareItem(Icons.share, 'Share', _share),
                _shareItem(Icons.download, 'Download', _share),
                _shareItem(Icons.music_note, 'TikTok', () => _openApp('tiktok://', 'https://www.tiktok.com')),
                _shareItem(Icons.camera_alt, 'Instagram', () => _openApp('instagram://', 'https://www.instagram.com')),
                _shareItem(Icons.facebook, 'Facebook', () => _openApp('fb://', 'https://www.facebook.com')),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _shareItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5C0).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF00E5C0)),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_error == null && _initialized)
            IconButton(
              onPressed: _showShareSheet,
              icon: const Icon(Icons.share, color: DripTheme.teal),
            ),
        ],
      ),
      body: Center(
        child: _error != null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DripTheme.teal,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: _initPlayer,
                      child: const Text('Retry'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back', style: TextStyle(color: DripTheme.teal)),
                    ),
                  ],
                ),
              )
            : _initialized && _chewieController != null
                ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: Chewie(controller: _chewieController!),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: DripTheme.teal),
                      SizedBox(height: 16),
                      Text('Loading video\u2026', style: TextStyle(color: DripTheme.silver)),
                    ],
                  ),
      ),
    );
  }
}
