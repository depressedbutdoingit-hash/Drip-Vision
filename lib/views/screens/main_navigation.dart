import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import 'home_screen.dart';
import 'create_screen.dart';
import 'library_screen.dart';
import 'studio_screen.dart';
import 'explore_drip_screen.dart';
import 'settings_screen.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigation extends ConsumerWidget { const MainNavigation({super.key});
  @override Widget build(BuildContext context,WidgetRef ref){final i=ref.watch(navIndexProvider);final screens=[const HomeScreen(),const CreateScreen(),const LibraryScreen(),const StudioScreen(),const ExploreDripScreen()];return Scaffold(backgroundColor:DripTheme.voidBlack,appBar:i==4?null:AppBar(title:const Text('DRIPVISION',style:TextStyle(fontSize:12,letterSpacing:4.5,fontWeight:FontWeight.w600)),actions:[IconButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const SettingsScreen())),icon:const Icon(Icons.person_outline,size:21,color:DripTheme.chrome)),const SizedBox(width:8)]),body:AnimatedSwitcher(duration:const Duration(milliseconds:220),child:KeyedSubtree(key:ValueKey(i),child:screens[i])),bottomNavigationBar:Container(decoration:BoxDecoration(color:DripTheme.deepBlack,border:Border(top:BorderSide(color:Colors.white.withOpacity(.06)))),child:SafeArea(child:Padding(padding:const EdgeInsets.symmetric(vertical:7),child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[_nav(ref,0,Icons.home_outlined,'HOME',i),_nav(ref,1,Icons.add_box_outlined,'CREATE',i),_nav(ref,2,Icons.folder_open_outlined,'LIBRARY',i),_nav(ref,3,Icons.tune_outlined,'STUDIO',i),_nav(ref,4,Icons.explore_outlined,'EXPLORE',i)])))));}
  Widget _nav(WidgetRef ref,int index,IconData icon,String label,int current)=>GestureDetector(onTap:()=>ref.read(navIndexProvider.notifier).state=index,child:AnimatedContainer(duration:const Duration(milliseconds:180),padding:const EdgeInsets.symmetric(horizontal:10,vertical:7),decoration:BoxDecoration(color:index==current?DripTheme.cosmicTeal.withOpacity(.07):Colors.transparent,borderRadius:BorderRadius.circular(10)),child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(icon,color:index==current?DripTheme.cosmicTeal:Colors.white38,size:20),const SizedBox(height:4),Text(label,style:TextStyle(fontSize:8,letterSpacing:1.2,color:index==current?DripTheme.cosmicTeal:Colors.white38,fontWeight:index==current?FontWeight.w700:FontWeight.w400))])));
}
