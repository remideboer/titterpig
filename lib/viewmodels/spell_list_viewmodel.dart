import 'package:flutter/foundation.dart';
import '../models/spell.dart';
import '../repositories/spell_repository.dart';

class SpellListViewModel extends ChangeNotifier {
  final List<Spell> _localSpells = [];
  final SpellRepository _spellRepository;

  SpellListViewModel(this._spellRepository);

  List<Spell> get allSpells => _localSpells;

  Future<void> loadSpells() async {
    final spells = await _spellRepository.getSpells();
    _localSpells.clear();
    _localSpells.addAll(spells);
    notifyListeners();
  }

  Future<void> addSpell(Spell spell) async {
    await _spellRepository.addSpell(spell);
    _localSpells.add(spell);
    notifyListeners();
  }

  Future<void> removeSpell(Spell spell) async {
    await _spellRepository.removeSpell(spell);
    _localSpells.remove(spell);
    notifyListeners();
  }

  Future<void> updateSpell(Spell oldSpell, Spell newSpell) async {
    await _spellRepository.updateSpell(oldSpell, newSpell);
    final index = _localSpells.indexOf(oldSpell);
    if (index != -1) {
      _localSpells[index] = newSpell;
      notifyListeners();
    }
  }

  Future<void> refreshSpells() async {
    await loadSpells();
  }

  @override
  void dispose() {
    super.dispose();
  }
} 