import 'package:flutter/foundation.dart';

@immutable
class Spell {
  static const int currentSaveVersion = 2; // Increment this when making breaking changes to the save format

  final String name;
  final String description;
  final int cost;
  final bool isDndSpell;
  final String versionId;
  final DateTime lastUpdated;
  final String damage;
  final String effect;
  final String type;
  final String range;

  Spell({
    required this.name,
    required this.description,
    required this.cost,
    this.isDndSpell = false,
    String? versionId,
    DateTime? lastUpdated,
    this.damage = '',
    this.effect = '',
    this.type = 'Spell',
    this.range = 'Self',
  }) : 
    versionId = versionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
    lastUpdated = lastUpdated ?? DateTime.now();

  Spell copyWith({
    String? name,
    String? description,
    int? cost,
    bool? isDndSpell,
    String? versionId,
    DateTime? lastUpdated,
    String? damage,
    String? effect,
    String? type,
    String? range,
  }) {
    return Spell(
      name: name ?? this.name,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      isDndSpell: isDndSpell ?? this.isDndSpell,
      versionId: versionId ?? this.versionId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      damage: damage ?? this.damage,
      effect: effect ?? this.effect,
      type: type ?? this.type,
      range: range ?? this.range,
    );
  }

  // Convert Spell to JSON
  Map<String, dynamic> toJson() {
    return {
      'version': currentSaveVersion,
      'name': name,
      'description': description,
      'cost': cost,
      'isDndSpell': isDndSpell,
      'versionId': versionId,
      'lastUpdated': lastUpdated.toIso8601String(),
      'damage': damage,
      'effect': effect,
      'type': type,
      'range': range,
    };
  }

  // Create Spell from JSON
  factory Spell.fromJson(Map<String, dynamic> json) {
    return Spell(
      name: json['name'] ?? 'Unknown Spell',
      description: json['description'] ?? 'No description available',
      cost: json['cost'] ?? 0,
      isDndSpell: json['isDndSpell'] ?? false,
      versionId: json['versionId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      damage: json['damage'] ?? '',
      effect: json['effect'] ?? '',
      type: json['type'] ?? 'Spell',
      range: json['range'] ?? 'Self',
    );
  }

  bool isNewerThan(Spell other) {
    return lastUpdated.isAfter(other.lastUpdated);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Spell &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          versionId == other.versionId;

  @override
  int get hashCode => name.hashCode ^ versionId.hashCode;

  // Default list of available spells
  static final List<Spell> availableSpells = [
    Spell(
      name: 'Fireball',
      description: 'Deal fire damage to all targets in area',
      cost: 3,
      isDndSpell: true,
      damage: '2d6',
      effect: 'Deal fire damage to all targets in area',
      type: 'Offensive',
      range: '20ft radius',
    ),
    Spell(
      name: 'Heal',
      description: 'Restore HP to target',
      cost: 2,
      isDndSpell: true,
      damage: '2d6',
      effect: 'Restore HP to target',
      type: 'Support',
      range: 'Touch',
    ),
    Spell(
      name: 'Shield',
      description: 'Gain temporary HP',
      cost: 1,
      isDndSpell: true,
      damage: '',
      effect: 'Gain temporary HP',
      type: 'Defensive',
      range: 'Self',
    ),
    Spell(
      name: 'Lightning Bolt',
      description: 'Deal lightning damage in a line',
      cost: 2,
      isDndSpell: true,
      damage: '1d6',
      effect: 'Deal lightning damage in a line',
      type: 'Offensive',
      range: '60ft line',
    ),
    Spell(
      name: 'Teleport',
      description: 'Move to any unoccupied space',
      cost: 2,
      isDndSpell: true,
      damage: '',
      effect: 'Move to any unoccupied space',
      type: 'Utility',
      range: '30ft',
    ),
  ];
} 