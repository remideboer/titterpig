import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../repositories/local_character_repository.dart';
import '../repositories/character_repository.dart';

class CharacterListViewModel extends ChangeNotifier {
  final CharacterRepository _repository;
  List<Character> _characters = [];
  Character? _selectedCharacter;
  bool _isLoading = false;
  String? _error;
  int _currentIndex = 0;

  CharacterListViewModel([CharacterRepository? repository])
      : _repository = repository ?? LocalCharacterRepository() {
    loadCharacters();
  }

  List<Character> get characters => _characters;
  Character? get selectedCharacter => _selectedCharacter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentIndex => _currentIndex;

  Future<void> loadCharacters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _characters = await _repository.getAllCharacters();
      if (_characters.isNotEmpty) {
        // Find the most recently used character
        final lastVisited = _characters.reduce((a, b) => 
          a.lastUsed.isAfter(b.lastUsed) ? a : b
        );
        _selectedCharacter = lastVisited;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCharacter(Character character) async {
    await _repository.addCharacter(character);
    await loadCharacters();
  }

  Future<void> updateCharacter(Character character) async {
    await _repository.updateCharacter(character);
    await loadCharacters();
  }

  Future<void> deleteCharacter(Character character) async {
    await _repository.deleteCharacter(character.id);
    if (_selectedCharacter?.id == character.id) {
      _selectedCharacter = null;
    }
    await loadCharacters();
  }

  void selectCharacter(Character character) {
    _selectedCharacter = character;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
} 