import 'package:flutter/foundation.dart';

class Species {
  static const int totalPoints = 2;
  static const int highCost = 2; // Cost for VIT, ATH, WIL, LIFE
  static const int lowCost = 1;  // Cost for HP, POWER, DEF, SPEED

  final String name;
  final String icon;
  final bool isCustom;
  final int vit;
  final int ath;
  final int wil;
  final int hp;
  final int life;
  final int power;
  final int def;
  final int speed;
  final String culture;
  final List<String> traits;

  const Species({
    required this.name,
    required this.icon,
    this.isCustom = false,
    this.vit = 0,
    this.ath = 0,
    this.wil = 0,
    this.hp = 0,
    this.life = 0,
    this.power = 0,
    this.def = 0,
    this.speed = 0,
    this.culture = '',
    this.traits = const [],
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      name: json['name'] as String,
      icon: json['icon'] as String,
      vit: json['vit'] as int? ?? 0,
      ath: json['ath'] as int? ?? 0,
      wil: json['wil'] as int? ?? 0,
      hp: json['hp'] as int? ?? 0,
      life: json['life'] as int? ?? 0,
      power: json['power'] as int? ?? 0,
      def: json['def'] as int? ?? 0,
      speed: json['speed'] as int? ?? 0,
      culture: json['culture'] as String? ?? '',
      traits: (json['traits'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'vit': vit,
      'ath': ath,
      'wil': wil,
      'hp': hp,
      'life': life,
      'power': power,
      'def': def,
      'speed': speed,
      'culture': culture,
      'traits': traits,
    };
  }

  int get remainingPoints {
    int spentPoints = 0;
    spentPoints += vit * highCost;
    spentPoints += ath * highCost;
    spentPoints += wil * highCost;
    spentPoints += life * highCost;
    spentPoints += hp * lowCost;
    spentPoints += power * lowCost;
    spentPoints += def * lowCost;
    spentPoints += speed * lowCost;
    return totalPoints - spentPoints;
  }

  bool canIncreaseStat(String stat) {
    final cost = getStatCost(stat);
    return remainingPoints >= cost;
  }

  bool canDecreaseStat(String stat) {
    // Allow decreasing any stat to negative values
    return true;
  }

  int getStatCost(String stat) {
    switch (stat) {
      case 'vit':
      case 'ath':
      case 'wil':
      case 'life':
        return highCost;
      case 'hp':
      case 'power':
      case 'def':
      case 'speed':
        return lowCost;
      default:
        return 0;
    }
  }

  int getStatValue(String stat) {
    switch (stat) {
      case 'vit': return vit;
      case 'ath': return ath;
      case 'wil': return wil;
      case 'hp': return hp;
      case 'life': return life;
      case 'power': return power;
      case 'def': return def;
      case 'speed': return speed;
      default: return 0;
    }
  }

  Species copyWith({
    String? name,
    String? icon,
    bool? isCustom,
    int? vit,
    int? ath,
    int? wil,
    int? hp,
    int? life,
    int? power,
    int? def,
    int? speed,
    String? culture,
    List<String>? traits,
  }) {
    return Species(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isCustom: isCustom ?? this.isCustom,
      vit: vit ?? this.vit,
      ath: ath ?? this.ath,
      wil: wil ?? this.wil,
      hp: hp ?? this.hp,
      life: life ?? this.life,
      power: power ?? this.power,
      def: def ?? this.def,
      speed: speed ?? this.speed,
      culture: culture ?? this.culture,
      traits: traits ?? this.traits,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Species &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          icon == other.icon &&
          isCustom == other.isCustom &&
          vit == other.vit &&
          ath == other.ath &&
          wil == other.wil &&
          hp == other.hp &&
          life == other.life &&
          power == other.power &&
          def == other.def &&
          speed == other.speed &&
          culture == other.culture &&
          listEquals(traits, other.traits);

  @override
  int get hashCode => Object.hash(
        name,
        icon,
        isCustom,
        vit,
        ath,
        wil,
        hp,
        life,
        power,
        def,
        speed,
        culture,
        Object.hashAll(traits),
      );
} 