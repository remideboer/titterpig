import '../models/character.dart';

abstract class CharacterRepository {
  Future<List<Character>> getAllCharacters();
  Future<Character?> getCharacter(String id);
  Future<void> addCharacter(Character character);
  Future<void> updateCharacter(Character character);
  Future<void> deleteCharacter(String id);
  Future<void> syncToCloud();
  Future<void> syncFromCloud();
} 