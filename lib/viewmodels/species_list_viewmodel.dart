import 'package:flutter/foundation.dart';
import '../models/species.dart';
import '../repositories/species_repository.dart';

class SpeciesListViewModel extends ChangeNotifier {
  final SpeciesRepository _repository = SpeciesRepository();
  List<Species> _species = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int _minCost = 0;
  int _maxCost = 10;
  String? _error;
  bool _isInitialized = false;

  List<Species> get species => _species;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int get minCost => _minCost;
  int get maxCost => _maxCost;
  List<Species> get filteredSpecies => getFilteredSpecies();
  String? get error => _error;

  Future<void> loadSpecies() async {
    // If already loading, don't load again
    if (_isLoading) {
      print('Skipping load - already loading');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Loading species in view model...');
      final loadedSpecies = await _repository.getSpecies();
      print('Loaded ${loadedSpecies.length} species in view model');
      
      // Update the species list and mark as initialized
      _species = loadedSpecies;
      _isInitialized = true;
      print('Updated view model with ${_species.length} species');
      
      // Force a rebuild after updating the species
      notifyListeners();
      
    } catch (e, stackTrace) {
      print('Error loading species in view model: $e');
      print('Stack trace: $stackTrace');
      _error = 'Failed to load species: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    print('Filtering species - total: ${_species.length}, query: $_searchQuery');
    final filtered = _species.where((species) {
      final matchesSearch = species.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
    print('Filtered to ${filtered.length} species');
    return filtered;
  }

  Future<void> addSpecies(Species species) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.addSpecies(species);
      _species = await _repository.getSpecies(); // Refresh the list
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add species: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSpecies(Species species) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateSpecies(species);
      _species = await _repository.getSpecies(); // Refresh the list
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update species: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSpecies(Species species) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteSpecies(species);
      _species = await _repository.getSpecies(); // Refresh the list
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete species: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeSpecies(Species species) async {
    await deleteSpecies(species);
  }
} 