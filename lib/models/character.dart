import 'spell.dart';
import 'stat_value.dart';
import 'species.dart';
import 'background.dart';
import 'def_category.dart';
import '../utils/spell_limit_calculator.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

enum Stat {
  vit,
  ath,
  wil;

  String get displayName => name.toUpperCase();
}

class Character {
  static const int baseHp = 6;
  static const int hpPerVit = 2;
  static const int baseLife = 3;
  static const int minPower = 0; // Minimum power value
  static const int baseCheckDice = 3; // Base number of dice for checks

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
  List<Ability> _spells;
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
    List<Ability>? spells,
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
    def = _defUpdate();
  }

  int _defUpdate() => defCategory.defValue + (hasShield ? 2 : 0);

  // Getters for the stat values
  StatValue get hpStat => _hp;
  set hpStat(StatValue value) => _hp = value;
  StatValue get lifeStat => _life;
  set lifeStat(StatValue value) => _life = value;
  StatValue get powerStat => _power;
  set powerStat(StatValue value) => _power = value;

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

    // Track remaining damage after HP is depleted
    int remainingDamage = amount;
    
    // First apply damage to temp HP if available
    if (_tempHp > 0) {
      final tempHpDamage = math.min(_tempHp, remainingDamage);
      _tempHp -= tempHpDamage;
      remainingDamage -= tempHpDamage;
    }

    // Then apply damage to HP
    if (remainingDamage > 0 && _hp.current > 0) {
      final hpDamage = math.min(_hp.current, remainingDamage);
      _hp = _hp.copyWithCurrent(_hp.current - hpDamage);
      remainingDamage -= hpDamage;
    }

    // If there's still damage remaining after HP is depleted, trigger vitality check
    if (remainingDamage > 0 && _hp.current == 0) {
      // Store the remaining damage for the vitality check
      _pendingVitalityCheckDamage = remainingDamage;
      // The actual life deduction will be handled by the vitality check result
    }

    updateDerivedStats();
  }

  // Add this field to track pending vitality check damage
  int _pendingVitalityCheckDamage = 0;
  int get pendingVitalityCheckDamage => _pendingVitalityCheckDamage;

  // Add this method to handle vitality check result
  void handleVitalityCheckResult(bool success) {
    if (!success && _life.current > 0) {
      _life = _life.copyWithCurrent(_life.current - 1);
    }
    _pendingVitalityCheckDamage = 0;
    updateDerivedStats();
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
    List<Ability>? spells,
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

  List<Ability> get spells => _spells;
  set spells(List<Ability> newSpells) {
    final spellLimit = SpellLimitCalculator.calculateSpellLimit(wil);
    if (newSpells.length > spellLimit) {
      _spells = newSpells.sublist(0, spellLimit);
    } else {
      _spells = newSpells;
    }
    updateDerivedStats();
  }

  /// Performs a stat check with the given target number
  /// Returns a tuple of (diceCount, result, success)
  /// where diceCount is the number of dice to roll (3 + stat value, minimum 3)
  /// result is the actual roll result
  /// success is whether the roll met or exceeded the target number
  (int, int, bool) check(Stat stat, int targetNumber) {
    // Get the stat value
    final statValue = switch (stat) {
      Stat.vit => vit,
      Stat.ath => ath,
      Stat.wil => wil,
    };

    // Calculate dice count: 3 base + stat value, minimum 3
    final diceCount = math.max(baseCheckDice, baseCheckDice + statValue);

    // Roll the dice (simulated for now, actual rolling happens in UI)
    final result = 0; // This will be set by the UI

    return (diceCount, result, result >= targetNumber);
  }
}
