import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../core/theme.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool showControls;
  final bool loop;

  const VideoPlayerWidget({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.showControls = true,
    this.loop = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: widget.autoPlay,
      looping: widget.loop,
      showControls: widget.showControls,
      aspectRatio: _videoController!.value.aspectRatio,
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: DripTheme.cosmicTeal,
          ),
        ),
      ),
      errorBuilder: (context, errorMessage) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white30, size: 48),
            SizedBox(height: 8),
            Text(
              'Failed to load video',
              style: TextStyle(color: Colors.white30),
            ),
          ],
        ),
      ),
    );

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: DripTheme.cosmicTeal),
        ),
      );
    }

    return Chewie(controller: _chewieController!);
  }
}
