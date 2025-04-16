class Spell {
  final String id;
  final String name;
  final int cost;
  final String effect;
  final String? damage;

  const Spell({
    required this.id,
    required this.name,
    required this.cost,
    required this.effect,
    this.damage,
  });

  static final List<Spell> availableSpells = [
    Spell(
      id: 'fireball',
      name: 'Fireball',
      cost: 2,
      effect: 'Deals fire damage in an area',
      damage: '2d6',
    ),
    Spell(
      id: 'heal',
      name: 'Heal',
      cost: 1,
      effect: 'Restores health to target',
    ),
    Spell(
      id: 'shield',
      name: 'Shield',
      cost: 1,
      effect: 'Grants temporary defense bonus',
    ),
    Spell(
      id: 'teleport',
      name: 'Teleport',
      cost: 3,
      effect: 'Instantly move to a visible location',
    ),
    Spell(
      id: 'invisibility',
      name: 'Invisibility',
      cost: 2,
      effect: 'Become invisible for a short duration',
    ),
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
      'effect': effect,
      'damage': damage,
    };
  }

  factory Spell.fromJson(Map<String, dynamic> json) {
    return Spell(
      id: json['id'],
      name: json['name'],
      cost: json['cost'],
      effect: json['effect'],
      damage: json['damage'],
    );
  }
} 