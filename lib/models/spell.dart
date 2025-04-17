class Spell {
  static const int currentSaveVersion = 2; // Increment this when making breaking changes to the save format

  final String name;
  final int cost;
  final String damage;
  final String effect;
  final String type;
  final String source;
  final String range;
  final DateTime lastUpdated;
  final String versionId;

  Spell({
    required this.name,
    required this.cost,
    this.damage = '',
    this.effect = '',
    this.type = 'Spell',
    this.source = 'default',
    this.range = 'Self',
    DateTime? lastUpdated,
  }) : 
    lastUpdated = lastUpdated ?? DateTime.now(),
    versionId = '${name}_${(lastUpdated ?? DateTime.now()).millisecondsSinceEpoch}';

  // Convert Spell to JSON
  Map<String, dynamic> toJson() {
    return {
      'version': currentSaveVersion,
      'name': name,
      'cost': cost,
      'damage': damage,
      'effect': effect,
      'type': type,
      'source': source,
      'range': range,
      'lastUpdated': lastUpdated.toIso8601String(),
      'versionId': versionId,
    };
  }

  // Create Spell from JSON
  factory Spell.fromJson(dynamic json) {
    // Handle both string and Map formats
    if (json is String) {
      // Old format: string
      final jsonMap = json.substring(1, json.length - 1)
        .split(', ')
        .map((pair) {
          final parts = pair.split(': ');
          return MapEntry(parts[0], parts[1]);
        })
        .fold<Map<String, String>>({}, (map, entry) {
          map[entry.key] = entry.value;
          return map;
        });

      return Spell(
        name: jsonMap['name'] ?? '',
        cost: int.tryParse(jsonMap['cost'] ?? '0') ?? 0,
        damage: jsonMap['damage'] ?? '',
        effect: jsonMap['effect'] ?? '',
        type: jsonMap['type'] ?? 'Spell',
        source: jsonMap['source'] ?? 'default',
        range: jsonMap['range'] ?? 'Self',
      );
    } else if (json is Map<String, dynamic>) {
      // New format: Map
      final saveVersion = json['version'] as int? ?? 1; // Default to 1 for old saves
      if (saveVersion > currentSaveVersion) {
        throw FormatException(
          'This spell was saved with a newer version of the app (v$saveVersion). '
          'Please update the app to load this spell.'
        );
      }

      return Spell(
        name: json['name'] as String? ?? '',
        cost: (json['cost'] as num?)?.toInt() ?? 0,
        damage: json['damage'] as String? ?? '',
        effect: json['effect'] as String? ?? '',
        type: json['type'] as String? ?? 'Spell',
        source: json['source'] as String? ?? 'default',
        range: json['range'] as String? ?? 'Self',
        lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      );
    } else {
      // Return empty spell for invalid format
      return Spell(name: '', cost: 0, damage: '', effect: '', source: 'default');
    }
  }

  bool isNewerThan(Spell other) {
    return lastUpdated.isAfter(other.lastUpdated);
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Spell &&
    runtimeType == other.runtimeType &&
    versionId == other.versionId;

  @override
  int get hashCode => versionId.hashCode;

  // Default list of available spells
  static final List<Spell> availableSpells = [
    Spell(
      name: 'Fireball',
      cost: 3,
      damage: '2d6',
      effect: 'Deal fire damage to all targets in area',
      type: 'Offensive',
      range: '20ft radius',
    ),
    Spell(
      name: 'Heal',
      cost: 2,
      damage: '2d6',
      effect: 'Restore HP to target',
      type: 'Support',
      range: 'Touch',
    ),
    Spell(
      name: 'Shield',
      cost: 1,
      damage: '',
      effect: 'Gain temporary HP',
      type: 'Defensive',
      range: 'Self',
    ),
    Spell(
      name: 'Lightning Bolt',
      cost: 2,
      damage: '1d6',
      effect: 'Deal lightning damage in a line',
      type: 'Offensive',
      range: '60ft line',
    ),
    Spell(
      name: 'Teleport',
      cost: 2,
      damage: '',
      effect: 'Move to any unoccupied space',
      type: 'Utility',
      range: '30ft',
    ),
  ];
} 