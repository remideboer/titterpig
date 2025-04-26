import 'dart:async';
import 'dart:convert';
import '../models/character.dart';
import '../mappers/character_mapper.dart';
import 'character_repository.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LocalCharacterRepository extends ChangeNotifier implements CharacterRepository {
  // Singleton pattern
  static final LocalCharacterRepository _instance = LocalCharacterRepository._internal();
  factory LocalCharacterRepository() => _instance;
  LocalCharacterRepository._internal();

  // Debug flag to print operations
  static const bool _debug = true;
  static const String _charactersKey = 'characters';

  List<Character> _characters = [];
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // Try to load characters from the new format (List<String>)
      final charactersJson = prefs.getStringList(_charactersKey);
      if (charactersJson != null) {
        _characters = charactersJson
            .map((json) => CharacterMapper.fromJson(jsonDecode(json)))
            .toList();
      } else {
        // Try to load from old format (single JSON string)
        final oldFormatJson = prefs.getString(_charactersKey);
        if (oldFormatJson != null) {
          if (_debug) print('Loading characters from old format');
          final List<dynamic> jsonList = jsonDecode(oldFormatJson);
          _characters = jsonList
              .map((json) => CharacterMapper.fromJson(json))
              .toList();
          // Migrate to new format
          await _saveCharacters();
        } else {
          if (_debug) print('No characters found in storage');
          _characters = [];
        }
      }
    } catch (e) {
      print('Error loading characters: $e');
      // Reset to empty list if there's any error
      _characters = [];
      // Clear potentially corrupted data
      await prefs.remove(_charactersKey);
    }
    
    _isInitialized = true;
    if (_debug) print('Loaded ${_characters.length} characters');
  }

  Future<List<Character>> getAllCharacters() async {
    await _ensureInitialized();
    return List.unmodifiable(_characters);
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
    notifyListeners();
    if (_debug) print('Added character: ${character.name}, Total: ${_characters.length}');
  }

  @override
  Future<void> updateCharacter(Character character) async {
    await _ensureInitialized();
    
    final index = _characters.indexWhere((c) => c.id == character.id);
    if (index != -1) {
      _characters[index] = character;
      await _saveCharacters();
      notifyListeners();
      if (_debug) print('Updated character: ${character.name}');
    }
  }

  @override
  Future<void> deleteCharacter(String id) async {
    await _ensureInitialized();
    
    _characters.removeWhere((c) => c.id == id);
    await _saveCharacters();
    notifyListeners();
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

  Future<void> updateCharacters(List<Character> characters) async {
    await _ensureInitialized();
    
    _characters = List.from(characters);
    await _saveCharacters();
    notifyListeners();
    if (_debug) print('Updated ${characters.length} characters');
  }

  Future<void> _saveCharacters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final charactersJson = _characters
          .map((character) => jsonEncode(CharacterMapper.toJson(character)))
          .toList();
      
      await prefs.setStringList(_charactersKey, charactersJson);
      if (_debug) print('Saved ${_characters.length} characters to storage');
    } catch (e) {
      print('Error saving characters: $e');
      // Handle error (maybe add retry logic or notify user)
    }
  }
} 