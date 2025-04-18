import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/spell.dart';
import '../services/dnd_spell_converter.dart';

class DndSpellRepository {
  static const String _storageKey = 'dnd_spells';
  static const String _versionKey = 'dnd_spells_version';
  static const String _lastUpdatedKey = 'dnd_spells_last_updated';
  
  late final SharedPreferences _prefs;
  final http.Client _client;
  final String _baseUrl = 'https://www.dnd5eapi.co/api/spells';
  bool _isInitialized = false;

  DndSpellRepository(this._client);

  Future<void> initialize() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  Future<List<Spell>> getSpells() async {
    await initialize();
    final localSpells = _getLocalSpells();
    if (localSpells.isNotEmpty) {
      return localSpells;
    }

    return await _fetchAndStoreSpells();
  }

  List<Spell> _getLocalSpells() {
    final jsonStr = _prefs.getString(_storageKey);
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((json) => Spell.fromJson(json)).toList();
  }

  Future<List<Spell>> _fetchAndStoreSpells() async {
    try {
      final response = await _client.get(Uri.parse(_baseUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch spells');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> spellList = data['results'];

      final List<Spell> spells = [];
      for (var spell in spellList) {
        final spellDetail = await _fetchSpellDetail(spell['url']);
        final convertedSpell = DndSpellConverter.convertToSpell(spellDetail);
        spells.add(convertedSpell);
      }

      await _storeSpells(spells);
      return spells;
    } catch (e) {
      print('Error fetching D&D spells: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> _fetchSpellDetail(String url) async {
    final response = await _client.get(Uri.parse('https://www.dnd5eapi.co$url'));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch spell detail');
    }
    return json.decode(response.body);
  }

  Future<void> _storeSpells(List<Spell> spells) async {
    final jsonList = spells.map((spell) => spell.toJson()).toList();
    await _prefs.setString(_storageKey, json.encode(jsonList));
    await _prefs.setString(_versionKey, DateTime.now().millisecondsSinceEpoch.toString());
    await _prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
  }

  Future<bool> checkForUpdates() async {
    await initialize();
    final lastUpdated = _prefs.getString(_lastUpdatedKey);
    if (lastUpdated == null) return true;

    final lastUpdateDate = DateTime.parse(lastUpdated);
    final now = DateTime.now();
    final difference = now.difference(lastUpdateDate);

    // Check for updates once per day
    return difference.inDays >= 1;
  }

  Future<void> updateSpells() async {
    await initialize();
    if (await checkForUpdates()) {
      await _fetchAndStoreSpells();
    }
  }

  Future<void> purgeSpells() async {
    await initialize();
    await _prefs.remove(_storageKey);
    await _prefs.remove(_versionKey);
    await _prefs.remove(_lastUpdatedKey);
  }

  void dispose() {
    _client.close();
  }
} 