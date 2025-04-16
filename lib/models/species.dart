class Species {
  final String name;
  final String icon;
  final bool isCustom;

  const Species({
    required this.name,
    required this.icon,
    this.isCustom = false,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      name: json['name'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Species &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          icon == other.icon &&
          isCustom == other.isCustom;

  @override
  int get hashCode => name.hashCode ^ icon.hashCode ^ isCustom.hashCode;
} 