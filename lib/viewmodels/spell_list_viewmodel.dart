import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/spell.dart';
import '../models/dnd_spell.dart';
import '../services/dnd_spell_converter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpellListViewModel extends ChangeNotifier {
  final DndSpellConverter _converter = DndSpellConverter();
  List<Spell> _spells = [];
  List<Spell> _filteredSpells = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialLoad = true;

  List<Spell> get spells => _spells;
  List<Spell> get filteredSpells => _filteredSpells;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSpells() async {
    if (_isLoading) return;
    
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
      
      // Load all spells in batches
      final spells = <Spell>[];
      final batchSize = 10;
      
      for (var i = 0; i < spellList.length; i += batchSize) {
        final batch = spellList.skip(i).take(batchSize).toList();
        final batchSpells = await Future.wait(
          batch.map((spell) async {
            try {
              final spellUrl = spell['url'] as String;
              final spellResponse = await http.get(Uri.parse('https://www.dnd5eapi.co$spellUrl'));
              if (spellResponse.statusCode == 200) {
                final dndSpell = DndSpell.fromJson(json.decode(spellResponse.body));
                return _converter.convertToSpell(dndSpell);
              }
            } catch (e) {
              print('Failed to load spell ${spell['name']}: $e');
            }
            return null;
          }),
        );
        
        spells.addAll(batchSpells.whereType<Spell>());
        
        // Update UI with progress
        if (_isInitialLoad) {
          _spells = spells;
          _filteredSpells = spells;
          notifyListeners();
        }
      }

      _spells = spells;
      _filteredSpells = spells;
      _isInitialLoad = false;
      
      // Save spells to local storage
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_spells.map((spell) => spell.toJson()).toList());
      await prefs.setString('all_spells', jsonString);
      
    } catch (e) {
      _error = e.toString();
      // Try to load from local storage if available
      try {
        final prefs = await SharedPreferences.getInstance();
        final jsonString = prefs.getString('all_spells');
        if (jsonString != null) {
          final List<dynamic> jsonData = json.decode(jsonString);
          _spells = jsonData.map((json) => Spell.fromJson(json)).toList();
          _filteredSpells = _spells;
        }
      } catch (e) {
        print('Failed to load spells from local storage: $e');
      }
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