import '../models/species.dart';
import '../services/species_service.dart';

class SpeciesRepository {
  final SpeciesService _service = SpeciesService();
  List<Species> _species = [];

  Future<List<Species>> getSpecies() async {
    if (_species.isEmpty) {
      _species = await _service.getSpecies();
    } else {
    }
    return _species;
  }

  Future<void> addSpecies(Species species) async {
    await _service.addSpecies(species);
    _species = await _service.getSpecies(); // Refresh the cache
  }

  Future<void> updateSpecies(Species species) async {
    await _service.updateSpecies(species);
    _species = await _service.getSpecies(); // Refresh the cache
  }

  Future<void> deleteSpecies(Species species) async {
    await _service.deleteSpecies(species);
    _species = await _service.getSpecies(); // Refresh the cache
  }
} 