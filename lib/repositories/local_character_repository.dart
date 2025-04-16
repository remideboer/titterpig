import 'dart:async';
import 'dart:convert';
import '../models/character.dart';
import 'character_repository.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCharacterRepository implements CharacterRepository {
  // Singleton pattern
  static final LocalCharacterRepository _instance = LocalCharacterRepository._internal();
  factory LocalCharacterRepository() => _instance;
  LocalCharacterRepository._internal();

  // Debug flag to print operations
  static const bool _debug = true;
  static const String _charactersKey = 'characters';

  final List<Character> _characters = [];
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      await _loadCharacters();
      _isInitialized = true;
    }
  }

  Future<void> _loadCharacters() async {
    final jsonString = _prefs?.getString(_charactersKey);
    if (jsonString != null) {
      if (_debug) print('Raw JSON string: $jsonString');
      final List<dynamic> jsonList = json.decode(jsonString);
      if (_debug) {
        print('Decoded JSON list:');
        for (var item in jsonList) {
          print(item);
        }
      }
      _characters.clear();
      _characters.addAll(jsonList.map((json) => Character.fromJson(json)));
      if (_debug) print('Loaded ${_characters.length} characters from storage');
    }
  }

  Future<void> _saveCharacters() async {
    final jsonList = _characters.map((c) => c.toJson()).toList();
    await _prefs?.setString(_charactersKey, json.encode(jsonList));
    if (_debug) print('Saved ${_characters.length} characters to storage');
  }

  @override
  Future<List<Character>> getAllCharacters() async {
    await _ensureInitialized();
    return _characters;
  }

  @override
  Future<Character?> getCharacter(String id) async {
    await _ensureInitialized();
    return _characters.firstWhereOrNull((c) => c.id == id);
  }

  @override
  Future<void> addCharacter(Character character) async {
    await _ensureInitialized();
    _characters.add(character);
    await _saveCharacters();
    if (_debug) print('Added character: ${character.name}, Total: ${_characters.length}');
  }

  @override
  Future<void> updateCharacter(Character character) async {
    await _ensureInitialized();
    final index = _characters.indexWhere((c) => c.id == character.id);
    if (index != -1) {
      _characters[index] = character;
      await _saveCharacters();
      if (_debug) print('Updated character: ${character.name}');
    }
  }

  @override
  Future<void> deleteCharacter(String id) async {
    await _ensureInitialized();
    _characters.removeWhere((c) => c.id == id);
    await _saveCharacters();
    if (_debug) print('Deleted character with id: $id, Remaining: ${_characters.length}');
  }

  @override
  Future<void> syncToCloud() async {
    // No-op for local
  }

  @override
  Future<void> syncFromCloud() async {
    // No-op for local
  }
} 