import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _mainStatsHeightKey = 'main_stats_height';
  static const String _derivedStatsHeightKey = 'derived_stats_height';
  static const String _abilitiesStartKey = 'abilities_start';

  // Default values
  static const double defaultMainStatsHeight = 0.15; // 15% of screen height
  static const double defaultDerivedStatsHeight = 0.25; // 25% of screen height
  static const double defaultAbilitiesStart = 0.45; // 45% from top
  static const double defaultHpLifeHeight = 0.12; // 12% of screen height

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  // Main Stats Height
  double get mainStatsHeight => _prefs.getDouble('mainStatsHeight') ?? defaultMainStatsHeight;
  Future<void> setMainStatsHeight(double value) async {
    await _prefs.setDouble('mainStatsHeight', value);
  }

  // Derived Stats Height
  double get derivedStatsHeight => _prefs.getDouble('derivedStatsHeight') ?? defaultDerivedStatsHeight;
  Future<void> setDerivedStatsHeight(double value) async {
    await _prefs.setDouble('derivedStatsHeight', value);
  }

  // Abilities Start Position
  double get abilitiesStart => _prefs.getDouble('abilitiesStart') ?? defaultAbilitiesStart;
  Future<void> setAbilitiesStart(double value) async {
    await _prefs.setDouble('abilitiesStart', value);
  }

  double get hpLifeHeight => _prefs.getDouble('hpLifeHeight') ?? defaultHpLifeHeight;
  Future<void> setHpLifeHeight(double value) async {
    await _prefs.setDouble('hpLifeHeight', value);
  }
} 