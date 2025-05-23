import 'package:flutter/foundation.dart';
import 'die.dart';

@immutable
class Ability {
  static const int currentSaveVersion = 3; // Increment version for breaking changes

  final String name;
  final String description;
  final int cost;
  final String versionId;
  final DateTime lastUpdated;
  final Die? effectValue;
  final String effect;
  final String type;
  final String range;

  const Ability._internal({
    required this.name,
    required this.description,
    required this.cost,
    required this.versionId,
    required this.lastUpdated,
    required this.effect,
    required this.type,
    required this.range,
    this.effectValue,
  });

  factory Ability({
    required String name,
    required String description,
    required int cost,
    String? versionId,
    DateTime? lastUpdated,
    Die? effectValue,
    String effect = '',
    String type = 'Spell',
    String range = 'Self',
  }) {
    return Ability._internal(
      name: name,
      description: description,
      cost: cost,
      versionId: versionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      lastUpdated: lastUpdated ?? DateTime.now(),
      effectValue: effectValue,
      effect: effect,
      type: type,
      range: range,
    );
  }

  Ability copyWith({
    String? name,
    String? description,
    int? cost,
    String? versionId,
    DateTime? lastUpdated,
    Die? effectValue,
    String? effect,
    String? type,
    String? range,
  }) {
    return Ability(
      name: name ?? this.name,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      versionId: versionId ?? this.versionId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      effectValue: effectValue ?? this.effectValue,
      effect: effect ?? this.effect,
      type: type ?? this.type,
      range: range ?? this.range,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'cost': cost,
      'versionId': versionId,
      'lastUpdated': lastUpdated.toIso8601String(),
      'effectValue': effectValue?.count,
      'effect': effect,
      'type': type,
      'range': range,
    };
  }

  factory Ability.fromJson(Map<String, dynamic> json) {
    final effectValue = json['effectValue'] != null 
        ? Die(json['effectValue'] as int)
        : null;

    return Ability(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      cost: json['cost'] ?? 0,
      versionId: json['versionId'],
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'])
          : null,
      effectValue: effectValue,
      effect: json['effect'] ?? '',
      type: json['type'] ?? 'Spell',
      range: json['range'] ?? 'Self',
    );
  }

  bool isNewerThan(Ability other) {
    return lastUpdated.isAfter(other.lastUpdated);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ability &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          cost == other.cost;

  @override
  int get hashCode => name.hashCode ^ description.hashCode ^ cost.hashCode;

  // Default list of available spells
  static final List<Ability> availableSpells = [
    Ability(
      name: 'Arcane Arrow',
      description: '',
      cost: 1,
      versionId: '1745073219149',
      effectValue: Die(3),
      effect: '',
      type: 'Offensive',
      range: '',
    ),
    Ability(
      name: 'Minor Heal',
      description: 'Restore a small amount of HP',
      cost: 1,
      effectValue: Die(1),
      effect: 'Restore HP to target',
      type: 'Support',
      range: 'Touch',
    ),
    Ability(
      name: 'Shield',
      description: 'Gain temporary HP',
      cost: 1,
      effect: 'Gain temporary HP',
      type: 'Defensive',
      range: 'Self',
    ),
    Ability(
      name: 'Energy Bolt',
      description: 'Deal damage to a single target',
      cost: 2,
      effectValue: Die(1),
      effect: 'Deal damage to target',
      type: 'Offensive',
      range: '30ft',
    ),
    Ability(
      name: 'Blink',
      description: 'Teleport a short distance',
      cost: 2,
      effect: 'Move to any unoccupied space',
      type: 'Utility',
      range: '15ft',
    ),
  ];
} 