import 'package:flutter/foundation.dart';
import '../models/character.dart';

abstract class CharacterRepository extends ChangeNotifier {
  Future<List<Character>> getAllCharacters();
  Future<Character?> getCharacter(String id);
  Future<void> addCharacter(Character character);
  Future<void> updateCharacter(Character character);
  Future<void> deleteCharacter(String id);
  Future<void> updateCharacters(List<Character> characters);
  Future<void> syncToCloud();
  Future<void> syncFromCloud();
} 