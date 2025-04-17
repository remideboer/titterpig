import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../repositories/local_character_repository.dart';

class CharacterListViewModel extends ChangeNotifier {
  final LocalCharacterRepository _repository = LocalCharacterRepository();
  List<Character> _characters = [];
  bool _isLoading = false;
  String? _error;

  List<Character> get characters => _characters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCharacters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _characters = await _repository.getAllCharacters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCharacter(Character character) async {
    try {
      await _repository.deleteCharacter(character.id);
      _characters.removeWhere((c) => c.id == character.id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 