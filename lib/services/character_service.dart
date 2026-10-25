import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/character.dart';

class CharacterService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> saveCharacter(Character character) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('characters')
        .doc(character.id)
        .set(character.toJson());
  }

  static Future<List<Character>> loadCharacters() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snap = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('characters')
        .get();

    return snap.docs.map((doc) => Character.fromJson(doc.data())).toList();
  }

  static Future<void> deleteCharacter(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('characters')
        .doc(id)
        .delete();
  }
}