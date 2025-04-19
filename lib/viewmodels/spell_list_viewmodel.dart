import 'package:flutter/foundation.dart';
import '../models/spell.dart';
import '../repositories/spell_repository.dart';

class SpellListViewModel extends ChangeNotifier {
  final SpellRepository _repository;
  List<Spell> _spells = [];
  String _searchQuery = '';
  bool _isLoading = false;

  SpellListViewModel(this._repository) {
    loadSpells();
  }

  List<Spell> get allSpells => _spells;
  bool get isLoading => _isLoading;
  
  List<Spell> get filteredSpells {
    if (_searchQuery.isEmpty) return _spells;
    return _spells.where((spell) => 
      spell.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      spell.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  String get searchQuery => _searchQuery;

  Future<void> loadSpells() async {
    try {
      _isLoading = true;
      notifyListeners();
      debugPrint('Loading spells in ViewModel...');
      _spells = await _repository.getSpells();
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

  Future<void> addSpell(Spell spell) async {
    debugPrint('Adding spell in ViewModel: ${spell.name}');
    await _repository.addSpell(spell);
    await loadSpells();
  }

  Future<void> removeSpell(Spell spell) async {
    debugPrint('Removing spell in ViewModel: ${spell.name}');
    await _repository.removeSpell(spell);
    await loadSpells();
  }

  Future<void> updateSpell(Spell spell) async {
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

  @override
  void dispose() {
    super.dispose();
  }
} 