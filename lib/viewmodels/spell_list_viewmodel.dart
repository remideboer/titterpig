import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/spell.dart';
import '../repositories/spell_repository.dart';

class SpellListViewModel extends ChangeNotifier {
  final SpellRepository _repository;
  List<Ability> _spells = [];
  String _searchQuery = '';
  bool _isLoading = false;
  late RangeValues _costRange;
  Set<String> _selectedTypes = {};

  SpellListViewModel(this._repository) {
    loadSpells();
    _costRange = const RangeValues(0, 10); // Default range
  }

  List<Ability> get allSpells => _spells;
  bool get isLoading => _isLoading;
  RangeValues get costRange => _costRange;
  Set<String> get selectedTypes => _selectedTypes;
  
  Set<String> get availableTypes {
    return _spells.map((s) => s.type).toSet();
  }
  
  double get maxSpellCost {
    if (_spells.isEmpty) return 10;
    return _spells.map((s) => s.cost.toDouble()).reduce((a, b) => a > b ? a : b);
  }
  
  List<Ability> get filteredSpells {
    return _spells.where((spell) {
      final matchesSearch = _searchQuery.isEmpty ||
          spell.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          spell.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCost = spell.cost >= _costRange.start && 
                         spell.cost <= _costRange.end;
      
      final matchesType = _selectedTypes.isEmpty || _selectedTypes.contains(spell.type);
      
      return matchesSearch && matchesCost && matchesType;
    }).toList();
  }

  String get searchQuery => _searchQuery;

  Future<void> loadSpells() async {
    try {
      _isLoading = true;
      notifyListeners();
      debugPrint('Loading spells in ViewModel...');
      _spells = await _repository.getSpells();
      // Update cost range max if needed
      if (_costRange.end > maxSpellCost) {
        _costRange = RangeValues(_costRange.start, maxSpellCost);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSpells({bool clearCache = false}) async {
    if (clearCache) {
      await _repository.clearSpells();
    }
    await loadSpells();
  }

  Future<void> addSpell(Ability spell) async {
    debugPrint('Adding spell in ViewModel: ${spell.name}');
    await _repository.addSpell(spell);
    await loadSpells();
  }

  Future<void> removeSpell(Ability spell) async {
    debugPrint('Removing spell in ViewModel: ${spell.name}');
    await _repository.removeSpell(spell);
    await loadSpells();
  }

  Future<void> updateSpell(Ability spell) async {
    debugPrint('Updating spell in ViewModel: ${spell.name}');
    await _repository.updateSpell(spell);
    await loadSpells();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    _searchQuery = '';
    notifyListeners();
  }

  void setCostRange(RangeValues range) {
    _costRange = range;
    notifyListeners();
  }

  void toggleType(String type) {
    if (_selectedTypes.contains(type)) {
      _selectedTypes.remove(type);
    } else {
      _selectedTypes.add(type);
    }
    notifyListeners();
  }

  void clearSelectedTypes() {
    _selectedTypes.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
} 