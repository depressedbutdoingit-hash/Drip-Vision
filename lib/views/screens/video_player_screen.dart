import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
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
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoController.value.aspectRatio,
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
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
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
      ),
      body: Center(
        child: _initialized && _chewieController != null
            ? AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: DripTheme.teal),
                  SizedBox(height: 16),
                  Text('Loading video…', style: TextStyle(color: DripTheme.silver)),
                ],
              ),
      ),
    );
  }
}