import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../services/media_action_service.dart';
import '../../core/providers.dart';

class VideoActionBar extends ConsumerStatefulWidget {
  final String videoUrl;
  final String prompt;

  const VideoActionBar({
    super.key,
    required this.videoUrl,
    required this.prompt,
  });

  @override
  ConsumerState<VideoActionBar> createState() => _VideoActionBarState();
}

class _VideoActionBarState extends ConsumerState<VideoActionBar> {
  bool _isDownloading = false;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: DripTheme.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: DripTheme.cosmicTeal.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: DripTheme.cosmicTeal.withOpacity(0.15),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isDownloading)
            SizedBox(
              width: 60,
              child: LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation(DripTheme.nebulaCyan),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.download_rounded, color: DripTheme.nebulaCyan),
              onPressed: () async {
                setState(() => _isDownloading = true);
                final res = await ref.read(mediaActionProvider).downloadVideoToGallery(
                      widget.videoUrl,
                      onProgress: (r, t) => setState(() => _progress = r / t),
                    );
                setState(() => _isDownloading = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        res ? 'Saved to Gallery' : 'Download failed',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: res ? DripTheme.cosmicTeal.withOpacity(0.8) : Colors.red.shade800,
                    ),
                  );
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: DripTheme.cosmicTeal),
            onPressed: () => ref.read(mediaActionProvider).shareVideoToApps(
                  widget.videoUrl,
                  widget.prompt,
                ),
          ),
        ],
      ),
    );
  }
}
