import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../models/species.dart';
import '../services/character_service.dart';
import '../repositories/character_repository.dart';

class CharacterCreationViewModel extends ChangeNotifier {
  final CharacterRepository _repository;
  String _name = '';
  int _vit = 0;
  int _ath = 0;
  int _wil = 0;
  int _remainingPoints = CharacterService.totalPoints;

  CharacterCreationViewModel(this._repository);

  String get name => _name;
  int get vit => _vit;
  int get ath => _ath;
  int get wil => _wil;
  int get remainingPoints => _remainingPoints;
  int get hp => CharacterService.calculateHp(_vit);

  bool get canSave => 
      _name.isNotEmpty && 
      _remainingPoints == 0 && 
      CharacterService.isValidVitForHp(_vit);

  void updateName(String name) {
    _name = name;
    notifyListeners();
  }

  void updateStat(String stat, int delta) {
    final currentValue = _getStatValue(stat);
    final isVit = stat == 'vit';
    
    if (CharacterService.canUpdateStat(
      currentValue: currentValue,
      delta: delta,
      remainingPoints: _remainingPoints,
      isVit: isVit,
    )) {
      _setStatValue(stat, currentValue + delta);
      _remainingPoints -= delta;
      notifyListeners();
    }
  }

  Future<void> saveCharacter() async {
    if (!canSave) return;

    final character = Character(
      id: const Uuid().v4(),
      name: _name,
      species: const Species(name: 'Human', icon: 'human-face.svg'),
      vit: _vit,
      ath: _ath,
      wil: _wil,
    );

    await _repository.addCharacter(character);
  }

  int _getStatValue(String stat) {
    switch (stat) {
      case 'vit':
        return _vit;
      case 'ath':
        return _ath;
      case 'wil':
        return _wil;
      default:
        throw ArgumentError('Invalid stat: $stat');
    }
  }

  void _setStatValue(String stat, int value) {
    switch (stat) {
      case 'vit':
        _vit = value;
        break;
      case 'ath':
        _ath = value;
        break;
      case 'wil':
        _wil = value;
        break;
      default:
        throw ArgumentError('Invalid stat: $stat');
    }
  }
} 