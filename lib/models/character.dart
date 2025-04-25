import 'spell.dart';
import 'stat_value.dart';
import 'species.dart';
import 'background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/spell_repository.dart';
import 'def_category.dart';
import '../utils/spell_limit_calculator.dart';
import 'package:flutter/foundation.dart';

class Character {
  static const int baseHp = 6;
  static const int hpPerVit = 2;
  static const int baseLife = 3;
  static const int currentSaveVersion = 2; // Increment this when making breaking changes to the save format
  static const int minPower = 0; // Minimum power value

  final String id;
  final String name;
  final Species species;
  final int vit;
  final int ath;
  final int wil;
  final String? avatarPath; // Path to the avatar image file
  int _tempHp;
  int _tempHpToLife;  // New field to track HP that will convert to LIFE
  late StatValue _hp;
  late StatValue _life;
  late StatValue _power;
  late int def;
  DefCategory defCategory;
  bool hasShield;
  List<Spell> _spells;
  List<String> sessionLog;
  String notes;
  int _xp;
  final DateTime createdAt;
  DateTime lastUsed;
  Background? background;

  Character({
    required this.id,
    required this.name,
    required this.species,
    required this.vit,
    required this.ath,
    required this.wil,
    this.avatarPath,
    int? tempHp,
    int? tempHpToLife,  // New parameter
    DefCategory? defCategory,
    this.hasShield = false,
    List<Spell>? spells,
    List<String>? sessionLog,
    this.notes = '',
    int? xp,
    DateTime? createdAt,
    DateTime? lastUsed,
    this.background,
  })  : _tempHp = tempHp ?? 0,
        _tempHpToLife = tempHpToLife ?? 0,  // Initialize new field
        _xp = xp ?? 0,
        defCategory = defCategory ?? DefCategory.none,
        _spells = spells ?? [],
        sessionLog = sessionLog ?? [],
        createdAt = createdAt ?? DateTime.now(),
        lastUsed = lastUsed ?? DateTime.now() {
    final newHp = baseHp + hpPerVit * vit;
    final newLife = baseLife + vit;
    final newPower = wil * 3;
    
    _hp = StatValue.full(newHp < 2 ? 2 : newHp);
    _life = StatValue.full(newLife);
    _power = StatValue.full(newPower < minPower ? minPower : newPower);
    def = this.defCategory.defValue + (hasShield ? 2 : 0);
  }

  // Getters for the stat values
  StatValue get hpStat => _hp;
  set hpStat(StatValue value) => _hp = value;
  StatValue get lifeStat => _life;
  set lifeStat(StatValue value) => _life = value;
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
  int get tempHpToLife => _tempHpToLife;  // New getter
  set tempHpToLife(int value) => _tempHpToLife = value;  // New setter
  int get xp => _xp;
  set xp(int value) => _xp = value;

  // Setters for backward compatibility
  set availablePower(int value) {
    _power = StatValue(current: value.clamp(0, power), max: power);
  }

  void updateDerivedStats() {
    final newHp = baseHp + hpPerVit * vit;
    _hp = StatValue(
      current: _hp.current.clamp(0, newHp < 2 ? 2 : newHp),
      max: newHp < 2 ? 2 : newHp
    );
    
    final newLife = baseLife + vit;
    _life = StatValue(
      current: _life.current.clamp(0, newLife),
      max: newLife
    );
    
    final newPower = wil * 3;
    _power = StatValue(
      current: _power.current.clamp(0, newPower < minPower ? minPower : newPower),
      max: newPower < minPower ? minPower : newPower
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

  /// Returns true if the character is dead (LIFE stat is 0)
  bool get isDead => lifeStat.current == 0;

  /// Resurrects a dead character, restoring them to life with minimal stats
  void resurrect() {
    if (!isDead) return; // Only resurrect if actually dead
    
    _life = StatValue(current: 1, max: _life.max);
    _hp = StatValue(current: 1, max: _hp.max);
    _power = StatValue(current: 0, max: _power.max);
    updateDerivedStats();
  }

  // Add new method to handle HP to LIFE conversion
  void addHpToLife() {
    if (_tempHpToLife >= _hp.max) {
      if (_life.current < _life.max) {
        _life = _life.copyWithCurrent(_life.current + 1);
        _tempHpToLife -= _hp.max;
      }
    }
  }

  // Modify heal method to handle new behavior
  void heal([int amount = 1]) {
    for (int i = 0; i < amount; i++) {
      // First try to heal HP if not at max
      if (hpStat.current < hpStat.max) {
        hpStat = hpStat.copyWithCurrent(hpStat.current + 1);
      } else if (lifeStat.current < lifeStat.max) {
        // If HP is at max, add to temp HP to Life
        _tempHpToLife++;
        
        // If temp HP to Life reaches max HP, convert to actual Life
        if (_tempHpToLife >= hpStat.max) {
          _tempHpToLife = 0;
          _life = _life.copyWithCurrent(_life.current + 1);
          break; // you only get 1 life and no extra overflow
        }
      }
    }
    updateDerivedStats();
  }

  void takeDamage([int amount = 1]) {
    // first check if can get damaged, if so subtract def from damage
    if (amount < def){ // too tough to hit
      return;
    }
    amount -= def;
    // when take damage reset _tempHpToLife to 0
    if (_life.current < _life.max) {
      _tempHpToLife = 0;
    }
    // this basically keeps subtracting 1 from each value pool till end amount
    // though it should only subtract life once, so break looks strange
    // but alternative is a bunch of nested if statements with double conditions
    // for small amount this is acceptable since it's clearly not optimal
    for (int i = 0; i < amount; i++) {
      if (_tempHp > 0) {
        _tempHp--;
      } else if (_hp.current > 0) {
        _hp = _hp.copyWithCurrent(_hp.current - 1);
      } else if (_life.current > 0) {
        _life = _life.copyWithCurrent(_life.current - 1);
        break; // do only once
      }
    }
    updateDerivedStats();
  }

  // Add method to add temporary HP
  void addTempHp([int amount = 1]) {
    _tempHp += amount;
    updateDerivedStats();
  }

  // Add method to clear temporary HP
  void clearTempHp() {
    _tempHp = 0;
    updateDerivedStats();
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
      'avatarPath': avatarPath,
      'tempHp': _tempHp,
      'tempHpToLife': _tempHpToLife,  // Add new field
      'hp': _hp.max,
      'currentLife': _life.current,
      'maxLife': _life.max,
      'power': _power.max,
      'availablePower': _power.current,
      'def': def,
      'defCategory': defCategory.index,
      'hasShield': hasShield,
      'spells': _spells.map((s) => s.toJson()).toList(),
      'sessionLog': sessionLog,
      'notes': notes,
      'xp': _xp,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
      'background': background?.toJson(),
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

    // Helper function to safely convert to DateTime
    DateTime safeToDateTime(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
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
      avatarPath: json['avatarPath'] as String?,
      tempHp: safeToInt(json['tempHp']),
      tempHpToLife: safeToInt(json['tempHpToLife']),  // Add new parameter
      defCategory: DefCategory.values[safeToInt(json['defCategory'])],
      hasShield: json['hasShield'] as bool? ?? false,
      spells: safeToSpells(json['spells']),
      sessionLog: List<String>.from(json['sessionLog'] ?? []),
      notes: json['notes'] as String? ?? '',
      xp: safeToInt(json['xp']),
      createdAt: safeToDateTime(json['createdAt']),
      lastUsed: safeToDateTime(json['lastUsed']),
      background: json['background'] != null 
          ? Background.fromJson(json['background'] as Map<String, dynamic>)
          : null,
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

  Character copyWith({
    String? id,
    String? name,
    Species? species,
    int? vit,
    int? ath,
    int? wil,
    String? avatarPath,
    int? tempHp,
    int? tempHpToLife,  // New parameter
    DefCategory? defCategory,
    bool? hasShield,
    List<Spell>? spells,
    List<String>? sessionLog,
    String? notes,
    int? xp,
    DateTime? createdAt,
    DateTime? lastUsed,
    Background? background,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      vit: vit ?? this.vit,
      ath: ath ?? this.ath,
      wil: wil ?? this.wil,
      avatarPath: avatarPath ?? this.avatarPath,
      tempHp: tempHp ?? this._tempHp,
      tempHpToLife: tempHpToLife ?? this._tempHpToLife,  // New parameter
      defCategory: defCategory ?? this.defCategory,
      hasShield: hasShield ?? this.hasShield,
      spells: spells ?? this._spells,
      sessionLog: sessionLog ?? this.sessionLog,
      notes: notes ?? this.notes,
      xp: xp ?? this._xp,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      background: background ?? this.background,
    );
  }

  List<Spell> get spells => _spells;
  set spells(List<Spell> newSpells) {
    final spellLimit = SpellLimitCalculator.calculateSpellLimit(wil);
    if (newSpells.length > spellLimit) {
      _spells = newSpells.sublist(0, spellLimit);
    } else {
      _spells = newSpells;
    }
    updateDerivedStats();
  }

  void addSpell(Spell spell) {
    final spellLimit = SpellLimitCalculator.calculateSpellLimit(wil);
    if (_spells.length < spellLimit && !_spells.any((s) => s.versionId == spell.versionId)) {
      _spells.add(spell);
      updateDerivedStats();
    }
  }

  void removeSpell(Spell spell) {
    _spells.removeWhere((s) => s.versionId == spell.versionId);
    updateDerivedStats();
  }

  void updateSpells(List<Spell> updatedSpells) {
    final spellLimit = SpellLimitCalculator.calculateSpellLimit(wil);
    final Map<String, Spell> currentMap = {
      for (var spell in _spells) spell.name: spell
    };
    
    _spells = updatedSpells.where((spell) {
      final currentSpell = currentMap[spell.name];
      return currentSpell == null || spell.isNewerThan(currentSpell);
    }).toList();

    if (_spells.length > spellLimit) {
      _spells = _spells.sublist(0, spellLimit);
    }
    
    updateDerivedStats();
  }
}

class StatBlock {
  int ath;
  int dex;
  int intel;
  int cha;

  StatBlock({
    required this.ath,
    required this.dex,
    required this.intel,
    required this.cha,
  });

  int get totalPoints => ath + dex + intel + cha;

  Map<String, dynamic> toJson() {
    return {
      'ath': ath,
      'dex': dex,
      'intel': intel,
      'cha': cha,
    };
  }

  factory StatBlock.fromJson(Map<String, dynamic> json) {
    return StatBlock(
      ath: json['ath'],
      dex: json['dex'],
      intel: json['intel'],
      cha: json['cha'],
    );
  }
}

class LifeStat {
  int max;
  int current;

  LifeStat({required this.max, required this.current});

  Map<String, dynamic> toJson() {
    return {
      'max': max,
      'current': current,
    };
  }

  factory LifeStat.fromJson(Map<String, dynamic> json) {
    return LifeStat(
      max: json['max'],
      current: json['current'],
    );
  }
} 