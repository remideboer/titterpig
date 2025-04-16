class Species {
  final String name;
  final String icon;

  const Species({
    required this.name,
    required this.icon,
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Species && 
           other.name == name && 
           other.icon == icon;
  }

  @override
  int get hashCode => name.hashCode ^ icon.hashCode;
} 