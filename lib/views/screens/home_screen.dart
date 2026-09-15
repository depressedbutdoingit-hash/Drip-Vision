import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../widgets/cinematic_button.dart';
import '../widgets/cinematic_card.dart';
import '../widgets/cinematic_media_card.dart';
import '../widgets/section_header.dart';
import 'character_lab_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(sceneListProvider);
    final character = ref.watch(activeCharacterProvider);
    final last = scenes.isEmpty ? null : scenes.last;
    return Scaffold(backgroundColor: DripTheme.voidBlack, body: SafeArea(child: CustomScrollView(slivers: [
      SliverPadding(padding: const EdgeInsets.fromLTRB(22, 16, 22, 10), sliver: SliverToBoxAdapter(child: Row(children: [
        const Expanded(child: Text('DRIPVISION', style: TextStyle(fontSize: 13, letterSpacing: 4.5, fontWeight: FontWeight.w600))),
        IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())), icon: const Icon(Icons.person_outline, size: 21, color: DripTheme.chrome)),
      ]))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(22, 18, 22, 28), sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('GOOD EVENING, DIRECTOR.', style: TextStyle(fontSize: 11, letterSpacing: 2.8, color: DripTheme.cosmicTeal, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8), const Text('Your worlds are waiting.', style: TextStyle(fontSize: 31, height: 1.03, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        CinematicCard(padding: EdgeInsets.zero, child: SizedBox(height: 225, child: Stack(children: [
          Positioned.fill(child: Container(decoration: BoxDecoration(color: DripTheme.surfaceRaised, gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [DripTheme.surfaceRaised, Colors.black])))),
          Positioned(left: 20, top: 18, child: Text('CURRENT PRODUCTION', style: TextStyle(fontSize: 9, letterSpacing: 2.5, color: Colors.white.withOpacity(.5)))),
          Positioned(left: 20, bottom: 20, right: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('THE LAST HOUSE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)), const SizedBox(height: 7),
            Text('${scenes.length.toString().padLeft(2,'0')} SCENES   •   02:14', style: const TextStyle(fontSize: 10, letterSpacing: 1.7, color: DripTheme.chrome)), const SizedBox(height: 16),
            CinematicButton(label: 'CONTINUE PRODUCTION', icon: Icons.play_arrow_rounded, onPressed: () => ref.read(navIndexProvider.notifier).state = 3),
          ])),
        ])),
      ]))),
      SliverPadding(padding: const EdgeInsets.symmetric(horizontal:22), sliver: SliverToBoxAdapter(child: SectionHeader(eyebrow:'RECENT SCENES', title:'The cut so far', action:'VIEW TIMELINE', onAction:() => ref.read(navIndexProvider.notifier).state=3))),
      SliverToBoxAdapter(child: SizedBox(height: 170, child: scenes.isEmpty ? Padding(padding: const EdgeInsets.symmetric(horizontal:22), child: CinematicCard(child: const Text('Your first scene will live here. Start with a visual idea and let the Director build it.', style: TextStyle(color: DripTheme.muted, height:1.5)))) : ListView.separated(padding: const EdgeInsets.symmetric(horizontal:22), scrollDirection: Axis.horizontal, itemCount: scenes.length, separatorBuilder: (_,__)=>const SizedBox(width:12), itemBuilder:(c,i){ final s=scenes[i]; return CinematicMediaCard(title:'SCENE ${(i+1).toString().padLeft(2,'0')}', meta:'${s.cameraMotion ?? 'STATIC'}  •  ${s.character.name}', imageUrl:s.generatedLastFrameUrl ?? s.inputLastFrameUrl); }})),
      SliverPadding(padding: const EdgeInsets.fromLTRB(22, 30, 22, 12), sliver: SliverToBoxAdapter(child: SectionHeader(eyebrow:'YOUR UNIVERSE', title:'Drip Memory™'))),
      SliverPadding(padding: const EdgeInsets.symmetric(horizontal:22), sliver: SliverGrid(delegate: SliverChildListDelegate([
        _MemoryTile(label:'CHARACTERS', icon:Icons.person_outline, onTap:()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>const CharacterLabScreen()))),
        _MemoryTile(label:'LOCATIONS', icon:Icons.location_on_outlined), _MemoryTile(label:'PROPS', icon:Icons.inventory_2_outlined), _MemoryTile(label:'STYLES', icon:Icons.auto_awesome_outlined),
      ]), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, mainAxisSpacing:12, crossAxisSpacing:12, childAspectRatio:1.55)),),
      SliverPadding(padding: const EdgeInsets.fromLTRB(22, 30, 22, 12), sliver: SliverToBoxAdapter(child: SectionHeader(eyebrow:'QUICK CREATE', title:'Make something worth watching'))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(22, 0, 22, 40), sliver: SliverToBoxAdapter(child: Row(children:[Expanded(child:CinematicButton(label:'NEW FILM',icon:Icons.movie_creation_outlined,onPressed:()=>ref.read(navIndexProvider.notifier).state=1)),const SizedBox(width:10),Expanded(child:CinematicButton(label:'NEW SCENE',icon:Icons.camera_alt_outlined,primary:false,onPressed:()=>ref.read(navIndexProvider.notifier).state=1))]))),
    ])));
  }
}
class _MemoryTile extends StatelessWidget { final String label; final IconData icon; final VoidCallback? onTap; const _MemoryTile({required this.label,required this.icon,this.onTap}); @override Widget build(BuildContext context)=>CinematicCard(onTap:onTap,child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Icon(icon,size:24,color:DripTheme.chrome),Text(label,style:const TextStyle(fontSize:11,letterSpacing:2,fontWeight:FontWeight.w600))])); }
