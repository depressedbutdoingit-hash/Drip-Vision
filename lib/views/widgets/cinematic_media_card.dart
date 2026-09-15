import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CinematicMediaCard extends StatelessWidget {
  final String title; final String meta; final String? imageUrl; final VoidCallback? onTap; final double width;
  const CinematicMediaCard({super.key, required this.title, required this.meta, this.imageUrl, this.onTap, this.width = 230});
  @override Widget build(BuildContext context) => SizedBox(width: width, child: GestureDetector(onTap: onTap, child: Container(
    height: 150,
    decoration: BoxDecoration(color: DripTheme.surfaceRaised, borderRadius: BorderRadius.circular(16), image: imageUrl == null ? null : DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover, onError: (_, __) {})),
    clipBehavior: Clip.antiAlias,
    child: Stack(children: [
      Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(.82)])))),
      Positioned(left: 14, right: 14, bottom: 13, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(meta, style: const TextStyle(fontSize: 9, letterSpacing: 1.6, color: DripTheme.nebulaCyan)), const SizedBox(height: 3), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: DripTheme.warmWhite))]))
    ]),
  )));
}
