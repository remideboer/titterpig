import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/spell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SpellRepository {
  static const String _spellsKey = 'spells';
  final List<Ability> _spells = [];

  SpellRepository();

  Future<List<Ability>> getSpells() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      debugPrint('Loading spells from SharedPreferences...');
      
      final spellsJson = prefs.getStringList(_spellsKey);
      if (spellsJson == null || spellsJson.isEmpty) {
        debugPrint('No spells found in SharedPreferences, loading default spells...');
        return Ability.availableSpells;
      }

      debugPrint('Found ${spellsJson.length} spells in SharedPreferences');
      final spells = spellsJson
          .map((json) => Ability.fromJson(jsonDecode(json)))
          .toList();
      
      debugPrint('Loaded spells: ${spells.map((s) => s.name).join(', ')}');
      return spells;
    } catch (e) {
      debugPrint('Error loading spells: $e');
      return Ability.availableSpells;
    }
  }

  Future<void> _saveSpells() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      debugPrint('Saving ${_spells.length} spells to SharedPreferences');
      
      final spellsJson = _spells
          .map((spell) => jsonEncode(spell.toJson()))
          .toList();
      
      await prefs.setStringList(_spellsKey, spellsJson);
      debugPrint('Spells saved successfully');
    } catch (e) {
      debugPrint('Error saving spells: $e');
      rethrow;
    }
  }

  Future<void> addSpell(Ability spell) async {
    _spells.clear();
    _spells.addAll(await getSpells());
    
    debugPrint('Adding spell: ${spell.name}');
    if (!_spells.any((s) => s.versionId == spell.versionId)) {
      _spells.add(spell);
      await _saveSpells();
    } else {
      debugPrint('Spell with ID ${spell.versionId} already exists');
    }
  }

  Future<void> removeSpell(Ability spell) async {
    _spells.clear();
    _spells.addAll(await getSpells());
    
    debugPrint('Removing spell: ${spell.name}');
    _spells.removeWhere((s) => s.versionId == spell.versionId);
    await _saveSpells();
  }

  Future<void> updateSpell(Ability spell) async {
    _spells.clear();
    _spells.addAll(await getSpells());
    
    final index = _spells.indexWhere((s) => s.versionId == spell.versionId);
    if (index != -1) {
      debugPrint('Updating spell: ${spell.name}');
      _spells[index] = spell;
      await _saveSpells();
    }
  }

  Future<void> clearSpells() async {
    print('\nClearing all spells from SharedPreferences');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_spellsKey);
    _spells.clear();
    print('Cleared all spells');
  }

  Future<Ability?> getSpellById(String id) async {
    final spells = await getSpells();
    try {
      final spell = spells.firstWhere((spell) => spell.versionId == id);
      debugPrint('Found spell by ID $id: ${spell.name}');
      return spell;
    } catch (e) {
      debugPrint('Spell not found with ID: $id');
      return null;
    }
  }
} 