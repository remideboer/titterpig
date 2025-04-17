class DndSpell {
  final String name;
  final String description;
  final String damage;
  final int level;
  final String school;
  final String castingTime;
  final String range;
  final String duration;
  final List<String> components;
  final bool concentration;
  final bool ritual;

  DndSpell({
    required this.name,
    required this.description,
    required this.damage,
    required this.level,
    required this.school,
    required this.castingTime,
    required this.range,
    required this.duration,
    required this.components,
    required this.concentration,
    required this.ritual,
  });

  factory DndSpell.fromJson(Map<String, dynamic> json) {
    return DndSpell(
      name: json['name'] as String,
      description: json['desc']?.join('\n') ?? '',
      damage: json['damage']?['damage_dice'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      school: json['school']?['name'] as String? ?? '',
      castingTime: json['casting_time'] as String? ?? '',
      range: json['range'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      components: (json['components'] as List<dynamic>?)?.cast<String>() ?? [],
      concentration: json['concentration'] as bool? ?? false,
      ritual: json['ritual'] as bool? ?? false,
    );
  }
} 