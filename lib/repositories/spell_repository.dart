import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/spell.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpellRepository {
  final List<Spell> _spells = Spell.availableSpells;

  SpellRepository();

  Future<List<Spell>> getSpells() async {
    return _spells;
  }

  Future<void> addSpell(Spell spell) async {
    _spells.add(spell);
  }

  Future<void> removeSpell(Spell spell) async {
    _spells.remove(spell);
  }

  Future<void> updateSpell(Spell oldSpell, Spell newSpell) async {
    final index = _spells.indexOf(oldSpell);
    if (index != -1) {
      _spells[index] = newSpell;
    }
  }

  Future<Spell?> getSpellById(String id) async {
    final spells = await getSpells();
    return spells.firstWhere((spell) => spell.versionId == id);
  }
} 