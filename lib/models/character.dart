import 'spell.dart';
import 'stat_value.dart';
import 'package:ttrpg_character_manager/models/species.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/spell_repository.dart';

class Character {
  static const int baseHp = 6;
  static const int hpPerVit = 2;
  static const int baseLife = 3;
  static const int minVitForPositiveHp = -2; // HP = 6 + 2*VIT > 0 => VIT > -3
  static const int currentSaveVersion = 2; // Increment this when making breaking changes to the save format

  final String id;
  final String name;
  final Species species;
  final int vit;
  final int ath;
  final int wil;
  int _tempHp;
  late StatValue _hp;
  late StatValue _life;
  late StatValue _power;
  late int def;
  DefCategory defCategory;
  bool hasShield;
  List<Spell> spells;
  List<String> sessionLog;
  String notes;
  int _xp;

  Character({
    required this.id,
    required this.name,
    required this.species,
    required this.vit,
    required this.ath,
    required this.wil,
    int? tempHp,
    DefCategory? defCategory,
    this.hasShield = false,
    List<Spell>? spells,
    List<String>? sessionLog,
    this.notes = '',
    int? xp,
  })  : _tempHp = tempHp ?? 0,
        _xp = xp ?? 0,
        defCategory = defCategory ?? DefCategory.none,
        spells = spells ?? [],
        sessionLog = sessionLog ?? [] {
    // Initialize stat values before calling updateDerivedStats
    final newHp = baseHp + hpPerVit * vit;
    final newLife = baseLife + vit;
    final newPower = wil * 3;
    
    _hp = StatValue.full(newHp);
    _life = StatValue.full(newLife);
    _power = StatValue.full(newPower);
    def = this.defCategory.defValue + (hasShield ? 2 : 0);
  }

  // Getters for the stat values
  StatValue get hpStat => _hp;
  set hpStat(StatValue value) => _hp = value;
  StatValue get lifeStat => _life;
  StatValue get powerStat => _power;

  // Getters for backward compatibility
  int get hp => _hp.max;
  int get currentLife => _life.current;
  int get maxLife => _life.max;
  int get life => currentLife;
  int get power => _power.max;
  int get availablePower => _power.current;
  int get tempHp => _tempHp;
  set tempHp(int value) => _tempHp = value;
  int get xp => _xp;
  set xp(int value) => _xp = value;

  // Setters for backward compatibility
  set availablePower(int value) {
    _power = StatValue(current: value.clamp(0, power), max: power);
  }

  void updateDerivedStats() {
    final newHp = baseHp + hpPerVit * vit;
    _hp = StatValue(
      current: _hp.current.clamp(0, newHp),
      max: newHp
    );
    
    final newLife = baseLife + vit;
    _life = StatValue(
      current: _life.current.clamp(0, newLife),
      max: newLife
    );
    
    final newPower = wil * 3;
    _power = StatValue(
      current: _power.current.clamp(0, newPower),
      max: newPower
    );
    
    def = defCategory.defValue + (hasShield ? 2 : 0);
  }

  // Decrease life by 1, but not below 0
  void decreaseLife() {
    if (_life.current > 0) {
      _life = _life.copyWithCurrent(_life.current - 1);
    }
  }

  // Increase life by 1, but not above maxLife
  void increaseLife() {
    if (_life.current < _life.max) {
      _life = _life.copyWithCurrent(_life.current + 1);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'version': currentSaveVersion,
      'id': id,
      'name': name,
      'species': species.toJson(),
      'vit': vit,
      'ath': ath,
      'wil': wil,
      'tempHp': _tempHp,
      'hp': _hp.max,
      'currentLife': _life.current,
      'maxLife': _life.max,
      'power': _power.max,
      'availablePower': _power.current,
      'def': def,
      'defCategory': defCategory.index,
      'hasShield': hasShield,
      'spells': spells.map((s) => s.toJson()).toList(),
      'sessionLog': sessionLog,
      'notes': notes,
      'xp': _xp,
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    // Check save version
    final saveVersion = json['version'] as int? ?? 1; // Default to 1 for old saves
    if (saveVersion > currentSaveVersion) {
      throw FormatException(
        'This character was saved with a newer version of the app (v$saveVersion). '
        'Please update the app to load this character.'
      );
    }

    // Helper function to safely convert to int
    int safeToInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    // Helper function to safely convert spells
    List<Spell> safeToSpells(dynamic value) {
      if (value is List) {
        return value.map((s) => Spell.fromJson(s)).toList();
      }
      return [];
    }

    // Handle both string and Map species formats
    Species species;
    if (json['species'] is String) {
      // Old format: species is a string
      species = Species(
        name: json['species'] as String,
        icon: '${json['species'].toString().toLowerCase()}-face.svg',
      );
    } else {
      // New format: species is a Map
      species = Species.fromJson(json['species'] as Map<String, dynamic>);
    }

    final character = Character(
      id: json['id'] as String,
      name: json['name'] as String,
      species: species,
      vit: safeToInt(json['vit']),
      ath: safeToInt(json['ath']),
      wil: safeToInt(json['wil']),
      tempHp: safeToInt(json['tempHp']),
      defCategory: DefCategory.values[safeToInt(json['defCategory'])],
      hasShield: json['hasShield'] as bool? ?? false,
      spells: safeToSpells(json['spells']),
      sessionLog: List<String>.from(json['sessionLog'] ?? []),
      notes: json['notes'] as String? ?? '',
      xp: safeToInt(json['xp']),
    );
    
    // Initialize stat values from JSON
    character._life = StatValue(
      current: safeToInt(json['currentLife'] ?? json['life'] ?? (Character.baseLife + safeToInt(json['vit']))),
      max: safeToInt(json['maxLife'] ?? json['life'] ?? (Character.baseLife + safeToInt(json['vit'])))
    );
    
    character._power = StatValue(
      current: safeToInt(json['availablePower'] ?? json['power']),
      max: safeToInt(json['power'])
    );
    
    return character;
  }
}

enum DefCategory {
  none,
  light,
  medium,
  heavy,
}

extension DefCategoryExtension on DefCategory {
  int get defValue {
    switch (this) {
      case DefCategory.none: return 0;
      case DefCategory.light: return 1;
      case DefCategory.medium: return 2;
      case DefCategory.heavy: return 3;
    }
  }
  String get label {
    switch (this) {
      case DefCategory.none:
        return 'None';
      case DefCategory.light:
        return 'Light';
      case DefCategory.medium:
        return 'Medium';
      case DefCategory.heavy:
        return 'Heavy';
    }
  }
} 