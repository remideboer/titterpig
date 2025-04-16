import 'package:shared_preferences/shared_preferences.dart';
import '../models/spell.dart';

class SpellRepository {
  static const String _spellsKey = 'spells';
  final SharedPreferences _prefs;

  SpellRepository(this._prefs);

  Future<List<Spell>> getSpells() async {
    final spellsJson = _prefs.getStringList(_spellsKey) ?? [];
    return spellsJson.map((json) => Spell.fromJson(json)).toList();
  }

  Future<void> saveSpells(List<Spell> spells) async {
    final spellsJson = spells.map((spell) => spell.toJson().toString()).toList();
    await _prefs.setStringList(_spellsKey, spellsJson);
  }

  Future<void> addSpell(Spell spell) async {
    final spells = await getSpells();
    spells.add(spell);
    await saveSpells(spells);
  }

  Future<void> updateSpell(Spell spell) async {
    final spells = await getSpells();
    final index = spells.indexWhere((s) => s.name == spell.name);
    if (index != -1) {
      spells[index] = spell;
      await saveSpells(spells);
    }
  }

  Future<void> deleteSpell(String spellName) async {
    final spells = await getSpells();
    spells.removeWhere((s) => s.name == spellName);
    await saveSpells(spells);
  }
} 