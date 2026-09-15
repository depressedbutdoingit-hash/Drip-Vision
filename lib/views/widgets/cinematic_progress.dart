import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CinematicProgress extends StatelessWidget {
  final double progress;
  final String stage;
  const CinematicProgress({super.key, required this.progress, required this.stage});
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:DripTheme.surface,borderRadius:BorderRadius.circular(16),border:Border.all(color:DripTheme.cosmicTeal.withOpacity(.12))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(stage.toUpperCase(),style:const TextStyle(fontSize:10,letterSpacing:2.2,color:DripTheme.cosmicTeal,fontWeight:FontWeight.w700)),const SizedBox(height:12),ClipRRect(borderRadius:BorderRadius.circular(3),child:LinearProgressIndicator(value:progress,minHeight:3,backgroundColor:Colors.white10,valueColor:const AlwaysStoppedAnimation(DripTheme.cosmicTeal))),const SizedBox(height:9),Text('${(progress*100).round()}%  •  ROLLING CAMERA  •  LOCKING CONTINUITY',style:const TextStyle(fontSize:9,letterSpacing:1.2,color:DripTheme.muted))]));
}
