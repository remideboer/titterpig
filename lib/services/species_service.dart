import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/species.dart';

class SpeciesService {
  static const String _speciesPath = 'assets/data/species.json';

  Future<List<Species>> getSpecies() async {
    try {
      final String jsonString = await rootBundle.loadString(_speciesPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Species.fromJson(json)).toList();
    } catch (e) {
      print('Error loading species: $e');
      return [];
    }
  }

  Future<void> addSpecies(Species species) async {
    try {
      final List<Species> currentSpecies = await getSpecies();
      currentSpecies.add(species);
      await _saveSpecies(currentSpecies);
    } catch (e) {
      print('Error adding species: $e');
    }
  }

  Future<void> updateSpecies(Species species) async {
    try {
      final List<Species> currentSpecies = await getSpecies();
      final index = currentSpecies.indexWhere((s) => s.name == species.name);
      if (index != -1) {
        currentSpecies[index] = species;
        await _saveSpecies(currentSpecies);
      }
    } catch (e) {
      print('Error updating species: $e');
    }
  }

  Future<void> deleteSpecies(Species species) async {
    try {
      final List<Species> currentSpecies = await getSpecies();
      currentSpecies.removeWhere((s) => s.name == species.name);
      await _saveSpecies(currentSpecies);
    } catch (e) {
      print('Error deleting species: $e');
    }
  }

  Future<void> _saveSpecies(List<Species> species) async {
    try {
      final jsonList = species.map((s) => s.toJson()).toList();
      final jsonString = json.encode(jsonList);
      // Note: In a real app, you would need to implement a way to save to the filesystem
      // For now, we'll just print the JSON to demonstrate the structure
      print('Species JSON to save: $jsonString');
    } catch (e) {
      print('Error saving species: $e');
    }
  }
} 