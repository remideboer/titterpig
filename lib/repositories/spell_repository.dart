import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/spell.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpellRepository {
  final String baseUrl;
  final http.Client? _client;
  static const String _spellStorageKey = 'spells';
  static const String _lastUpdateCheckKey = 'last_spell_update_check';
  static const String _allSpellsKey = 'all_spells';

  SpellRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<List<Spell>> getSpells() async {
    // First try to get spells from local storage
    final localSpells = await _getLocalSpells();
    
    // Check if we need to update from API
    final lastCheck = await _getLastUpdateCheck();
    final now = DateTime.now();
    final shouldCheckForUpdates = lastCheck == null || 
        now.difference(lastCheck).inHours > 24; // Check daily

    if (shouldCheckForUpdates) {
      // Start background update
      _updateSpellsInBackground();
    }
    
    return localSpells;
  }

  Future<void> _updateSpellsInBackground() async {
    try {
      final response = await _client!.get(Uri.parse('$baseUrl/spells'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final apiSpells = jsonData.map((json) => Spell.fromJson(json)).toList();
        
        // Compare and update local spells
        final localSpells = await _getLocalSpells();
        final updatedSpells = await _updateLocalSpells(localSpells, apiSpells);
        
        // Update last check timestamp
        await _setLastUpdateCheck(DateTime.now());
        
        // Save all spells to local storage
        await _setLocalSpells(updatedSpells);
      }
    } catch (e) {
      print('Error updating spells in background: $e');
    }
  }

  Future<Spell?> getSpellById(String id) async {
    final spells = await getSpells();
    return spells.firstWhere((spell) => spell.versionId == id);
  }

  Future<List<Spell>> _getLocalSpells() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_spellStorageKey);
    if (jsonString == null) {
      // If no spells stored, try to get from all_spells
      final allSpellsString = prefs.getString(_allSpellsKey);
      if (allSpellsString != null) {
        final List<dynamic> jsonData = json.decode(allSpellsString);
        return jsonData.map((json) => Spell.fromJson(json)).toList();
      }
      return [];
    }
    
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((json) => Spell.fromJson(json)).toList();
  }

  Future<void> _setLocalSpells(List<Spell> spells) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(spells.map((spell) => spell.toJson()).toList());
    await prefs.setString(_spellStorageKey, jsonString);
  }

  Future<DateTime?> _getLastUpdateCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastUpdateCheckKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  Future<void> _setLastUpdateCheck(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastUpdateCheckKey, timestamp.millisecondsSinceEpoch);
  }

  Future<List<Spell>> _updateLocalSpells(List<Spell> localSpells, List<Spell> apiSpells) async {
    final Map<String, Spell> localMap = {
      for (var spell in localSpells) spell.name: spell
    };
    
    final List<Spell> updatedSpells = [];
    bool hasUpdates = false;

    for (final apiSpell in apiSpells) {
      final localSpell = localMap[apiSpell.name];
      
      if (localSpell == null) {
        // New spell
        updatedSpells.add(apiSpell);
        hasUpdates = true;
      } else if (apiSpell.isNewerThan(localSpell)) {
        // Updated spell
        updatedSpells.add(apiSpell);
        hasUpdates = true;
      } else {
        // Keep existing spell
        updatedSpells.add(localSpell);
      }
    }

    if (hasUpdates) {
      await _setLocalSpells(updatedSpells);
    }

    return updatedSpells;
  }

  void dispose() {
    _client?.close();
  }
} 