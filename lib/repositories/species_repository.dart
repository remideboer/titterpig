import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/species.dart';

class SpeciesRepository {
  static const String _speciesAssetPath = 'assets/data/species.json';
  List<Species> _species = [];

  Future<List<Species>> getSpecies() async {
    if (_species.isEmpty) {
      try {
        final String jsonString = await rootBundle.loadString(_speciesAssetPath);
        final List<dynamic> jsonList = json.decode(jsonString);
        _species = jsonList.map((item) => Species.fromJson(item)).toList();
      } catch (e) {
        // Fallback to default species if file can't be loaded
        _species = [
          const Species(name: 'Human', icon: 'human-face.svg'),
          const Species(name: 'Dwarf', icon: 'dwarf-face.svg'),
          const Species(name: 'Elf', icon: 'elf-face.svg'),
          const Species(name: 'Gnome', icon: 'gnome-face.svg'),
          const Species(name: 'Tiefling', icon: 'tiefling-face.svg'),
        ];
      }
    }
    return _species;
  }
} 