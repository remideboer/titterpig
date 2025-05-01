import 'package:flutter/foundation.dart';
import '../models/species.dart';
import '../services/species_service.dart';

class SpeciesListViewModel extends ChangeNotifier {
  final SpeciesService _speciesService;
  List<Species> _species = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int _minCost = 0;
  int _maxCost = 10;

  SpeciesListViewModel(this._speciesService);

  List<Species> get species => _species;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int get minCost => _minCost;
  int get maxCost => _maxCost;
  List<Species> get filteredSpecies => getFilteredSpecies();

  Future<void> loadSpecies() async {
    _isLoading = true;
    notifyListeners();

    try {
      _species = await _speciesService.getSpecies();
    } catch (e) {
      debugPrint('Error loading species: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    _searchQuery = '';
    notifyListeners();
  }

  void setCostRange(int min, int max) {
    _minCost = min;
    _maxCost = max;
    notifyListeners();
  }

  List<Species> getFilteredSpecies() {
    return _species.where((species) {
      final matchesSearch = species.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  Future<void> addSpecies(Species species) async {
    try {
      await _speciesService.addSpecies(species);
      await loadSpecies();
    } catch (e) {
      debugPrint('Error adding species: $e');
    }
  }

  Future<void> updateSpecies(Species species) async {
    try {
      await _speciesService.updateSpecies(species);
      await loadSpecies();
    } catch (e) {
      debugPrint('Error updating species: $e');
    }
  }

  Future<void> deleteSpecies(Species species) async {
    try {
      await _speciesService.deleteSpecies(species);
      await loadSpecies();
    } catch (e) {
      debugPrint('Error deleting species: $e');
    }
  }

  Future<void> removeSpecies(Species species) async {
    await deleteSpecies(species);
  }
} 