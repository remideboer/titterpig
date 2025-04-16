class Spell {
  static const int currentSaveVersion = 2; // Increment this when making breaking changes to the save format

  final String name;
  final int cost;
  final String effect;
  final String type;

  Spell({
    required this.name,
    required this.cost,
    this.effect = '',
    this.type = 'Spell',
  });

  // Convert Spell to JSON
  Map<String, dynamic> toJson() {
    return {
      'version': currentSaveVersion,
      'name': name,
      'cost': cost,
      'effect': effect,
      'type': type,
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
        effect: jsonMap['effect'] ?? '',
        type: jsonMap['type'] ?? 'Spell',
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
        effect: json['effect'] as String? ?? '',
        type: json['type'] as String? ?? 'Spell',
      );
    } else {
      // Return empty spell for invalid format
      return Spell(name: '', cost: 0);
    }
  }

  // Default list of available spells
  static final List<Spell> availableSpells = [
    Spell(name: 'Fireball', cost: 3, effect: 'Deal 2 damage to target', type: 'Offensive'),
    Spell(name: 'Heal', cost: 2, effect: 'Restore 2 HP', type: 'Support'),
    Spell(name: 'Shield', cost: 1, effect: 'Gain 2 temporary HP', type: 'Defensive'),
    Spell(name: 'Lightning Bolt', cost: 2, effect: 'Deal 1 damage to all enemies', type: 'Offensive'),
    Spell(name: 'Teleport', cost: 2, effect: 'Move to any unoccupied space', type: 'Utility'),
  ];
} 