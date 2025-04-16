import 'species.dart';

class SpeciesOption {
  final Species species;
  final bool isCustomOption;

  const SpeciesOption({
    required this.species,
    this.isCustomOption = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeciesOption &&
          runtimeType == other.runtimeType &&
          species == other.species &&
          isCustomOption == other.isCustomOption;

  @override
  int get hashCode => species.hashCode ^ isCustomOption.hashCode;
} 