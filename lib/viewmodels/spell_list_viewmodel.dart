import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/spell.dart';
import '../models/dnd_spell.dart';
import '../services/dnd_spell_converter.dart';

class SpellListViewModel extends ChangeNotifier {
  final DndSpellConverter _converter = DndSpellConverter();
  List<Spell> _spells = [];
  List<Spell> _filteredSpells = [];
  bool _isLoading = false;
  String? _error;

  List<Spell> get spells => _spells;
  List<Spell> get filteredSpells => _filteredSpells;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSpells() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First fetch the spell index
      final indexResponse = await http.get(Uri.parse('https://www.dnd5eapi.co/api/spells'));
      if (indexResponse.statusCode != 200) {
        throw Exception('Failed to load spell index');
      }

      final indexData = json.decode(indexResponse.body);
      final spellList = (indexData['results'] as List).cast<Map<String, dynamic>>();
      
      // Only take the first 10 spells
      final limitedSpellList = spellList.take(10).toList();

      // Fetch details for each spell
      final spells = <Spell>[];
      for (final spell in limitedSpellList) {
        try {
          final spellUrl = spell['url'] as String;
          final spellResponse = await http.get(Uri.parse('https://www.dnd5eapi.co$spellUrl'));
          if (spellResponse.statusCode == 200) {
            final dndSpell = DndSpell.fromJson(json.decode(spellResponse.body));
            final convertedSpell = _converter.convertToSpell(dndSpell);
            spells.add(convertedSpell);
          }
        } catch (e) {
          print('Failed to load spell ${spell['name']}: $e');
        }
      }

      _spells = spells;
      _filteredSpells = spells;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterSpells(String query) {
    if (query.isEmpty) {
      _filteredSpells = _spells;
    } else {
      _filteredSpells = _spells.where((spell) {
        return spell.name.toLowerCase().contains(query.toLowerCase()) ||
            spell.effect.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
} 