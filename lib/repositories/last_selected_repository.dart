import 'package:shared_preferences/shared_preferences.dart';

class LastSelectedRepository {
  static const String _lastSelectedCharacterIdKey = 'last_selected_character_id';

  final SharedPreferences _prefs;

  LastSelectedRepository(this._prefs);

  Future<void> setLastSelectedCharacterId(String characterId) async {
    await _prefs.setString(_lastSelectedCharacterIdKey, characterId);
  }

  String? getLastSelectedCharacterId() {
    return _prefs.getString(_lastSelectedCharacterIdKey);
  }
} 