import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../models/character.dart' as live;
import '../../models/character_dna.dart' as dna;
import '../widgets/cinematic_card.dart';
import '../widgets/cinematic_button.dart';
import 'story_planner_screen.dart';
import 'character_creation_screen.dart';
import 'character_lab_screen.dart';
import 'custom_outfit_creator.dart';
import 'music_studio_screen.dart';
import 'style_dna_screen.dart';

class CreateScreen extends ConsumerWidget { const CreateScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) => Scaffold(backgroundColor:DripTheme.voidBlack,body:SafeArea(child:SingleChildScrollView(padding:const EdgeInsets.fromLTRB(22,22,22,40),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('CREATE',style:TextStyle(fontSize:11,letterSpacing:3,color:DripTheme.cosmicTeal,fontWeight:FontWeight.w700)),const SizedBox(height:8),const Text('WHAT ARE WE MAKING?',style:TextStyle(fontSize:31,fontWeight:FontWeight.w600,height:1.05)),const SizedBox(height:8),const Text('Choose the department. The Director handles the technical language.',style:TextStyle(color:DripTheme.muted,height:1.45)),const SizedBox(height:28),
    _CreateCard('FILM','Build a complete production from story to cut.',Icons.movie_creation_outlined,()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const StoryPlannerScreen()))),
    _CreateCard('SCENE','Direct a single cinematic moment.',Icons.camera_alt_outlined,()=>ref.read(navIndexProvider.notifier).state=3),
    Row(children:[Expanded(child:_CreateCard('CHARACTER','Create an actor with continuity.',Icons.person_outline,()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ref.read(characterListProvider).isEmpty ? const CharacterCreationScreen() : const CharacterLabScreen())))),const SizedBox(width:12),Expanded(child:_CreateCard('OUTFIT','Open the wardrobe department.',Icons.checkroom_outlined,()=>_createOutfit(context, ref)))]),
    Row(children:[Expanded(child:_CreateCard('LOCATION','Build a world that stays consistent.',Icons.location_on_outlined, null)),const SizedBox(width:12),Expanded(child:_CreateCard('STYLE','Save a reusable Style DNA.',Icons.auto_awesome_outlined,()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const StyleDnaScreen()))))]),
    Row(children:[Expanded(child:_CreateCard('MUSIC','Score the scene.',Icons.music_note_outlined,()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const MusicStudioScreen())))),const SizedBox(width:12),Expanded(child:_CreateCard('VOICE','Give a character a voice.',Icons.graphic_eq_outlined,null))]),
    const SizedBox(height:22),CinematicCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('DIRECTOR MODE',style:TextStyle(fontSize:10,letterSpacing:2.4,color:DripTheme.cosmicTeal)),const SizedBox(height:8),const Text('Shot • Lens • Movement • Lighting • Performance',style:TextStyle(fontSize:17,fontWeight:FontWeight.w600)),const SizedBox(height:7),const Text('A visual control surface that turns your choices into a smart generation prompt.',style:TextStyle(color:DripTheme.muted,height:1.4)),const SizedBox(height:16),CinematicButton(label:'OPEN DIRECTOR',icon:Icons.tune_outlined,onPressed:()=>ref.read(navIndexProvider.notifier).state=3)]) )
  ]))));

  // Outfits belong to a character's real closet — not a form that mints
  // an Outfit and discards it. Requires an active character so nothing
  // orphaned gets created; the minted look is written straight onto that
  // character via characterListProvider, the same path Character Lab uses.
  Future<void> _createOutfit(BuildContext context, WidgetRef ref) async {
    final character = ref.read(activeCharacterProvider);
    if (character == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a character first — outfits are designed for someone.')),
      );
      return;
    }
    final result = await Navigator.push<dna.Outfit>(
      context,
      MaterialPageRoute(builder: (_) => CustomOutfitCreator(characterName: character.name)),
    );
    if (result == null) return;

    final outfit = live.Outfit(
      id: result.id,
      name: result.name,
      description: result.description,
      outfitImageUrl: result.referenceImageUrl,
    );
    final updated = character.copyWith(closet: [...character.closet, outfit]);
    ref.read(characterListProvider.notifier).updateCharacter(updated);
    ref.read(activeCharacterProvider.notifier).state = updated;
  }
}
class _CreateCard extends StatelessWidget { final String title,desc; final IconData icon; final VoidCallback? onTap; const _CreateCard(this.title,this.desc,this.icon,this.onTap); @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:12),child:CinematicCard(onTap:onTap,child:Row(children:[Container(width:46,height:46,decoration:BoxDecoration(color:DripTheme.cosmicTeal.withOpacity(.07),borderRadius:BorderRadius.circular(13)),child:Icon(icon,color:DripTheme.nebulaCyan)),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:13,letterSpacing:1.5,fontWeight:FontWeight.w700)),const SizedBox(height:5),Text(desc,style:const TextStyle(color:DripTheme.muted,fontSize:12,height:1.35))]))]))); }
