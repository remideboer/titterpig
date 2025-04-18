import 'package:flutter/foundation.dart';
import '../models/spell.dart';
import '../repositories/dnd_spell_repository.dart';
import 'package:http/http.dart' as http;

class SpellListViewModel extends ChangeNotifier {
  final List<Spell> _localSpells = [];
  final List<Spell> _dndSpells = [];
  late final DndSpellRepository _dndSpellRepository;
  bool _isLoading = false;
  bool _isSyncing = false;

  SpellListViewModel() {
    _dndSpellRepository = DndSpellRepository(http.Client());
  }

  List<Spell> get allSpells => [..._localSpells, ..._dndSpells];
  List<Spell> get dndSpells => _dndSpells;
  List<Spell> get localSpells => _localSpells;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;

  Future<void> loadSpells() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load D&D spells
      final dndSpells = await _dndSpellRepository.getSpells();
      _dndSpells.clear();
      _dndSpells.addAll(dndSpells);

      // Load local spells
      _localSpells.clear();
      _localSpells.addAll(Spell.availableSpells);
    } catch (e) {
      print('Error loading spells: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSpell(Spell spell) {
    _localSpells.add(spell);
    notifyListeners();
    return Future.value();
  }

  Future<void> removeSpell(Spell spell) {
    if (spell.isDndSpell) {
      _dndSpells.remove(spell);
    } else {
      _localSpells.remove(spell);
    }
    notifyListeners();
    return Future.value();
  }

  Future<void> updateSpell(Spell oldSpell, Spell newSpell) {
    if (oldSpell.isDndSpell) {
      final index = _dndSpells.indexOf(oldSpell);
      if (index != -1) {
        _dndSpells[index] = newSpell;
      }
    } else {
      final index = _localSpells.indexOf(oldSpell);
      if (index != -1) {
        _localSpells[index] = newSpell;
      }
    }
    notifyListeners();
    return Future.value();
  }

  Future<void> checkForUpdates() async {
    _isSyncing = true;
    notifyListeners();

    try {
      await _dndSpellRepository.updateSpells();
      await loadSpells();
    } catch (e) {
      print('Error checking for updates: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> purgeDndSpells() async {
    _dndSpells.clear();
    notifyListeners();
    await _dndSpellRepository.purgeSpells();
  }

  @override
  void dispose() {
    _dndSpellRepository.dispose();
    super.dispose();
  }
} 