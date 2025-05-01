import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/species.dart';

class SpeciesService {
  static const String _fileName = 'species.json';
  static const String _assetPath = 'assets/data/species.json';

  Future<List<Species>> getSpecies() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        final species = jsonList.map((json) => Species.fromJson(json)).toList();
        return species;
      }
    } catch (e) {
    }

    try {
      final String contents = await rootBundle.loadString(_assetPath);
      final List<dynamic> jsonList = json.decode(contents);
      final species = jsonList.map((json) => Species.fromJson(json)).toList();
      return species;
    } catch (e) {
      return [];
    }
  }

  Future<void> addSpecies(Species species) async {
    final speciesList = await getSpecies();
    speciesList.add(species);
    await _saveSpecies(speciesList);
  }

  Future<void> updateSpecies(Species species) async {
    final speciesList = await getSpecies();
    final index = speciesList.indexWhere((s) => s.name == species.name);
    if (index != -1) {
      speciesList[index] = species;
      await _saveSpecies(speciesList);
    }
  }

  Future<void> deleteSpecies(Species species) async {
    final speciesList = await getSpecies();
    speciesList.removeWhere((s) => s.name == species.name);
    await _saveSpecies(speciesList);
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<void> _saveSpecies(List<Species> species) async {
    try {
      final file = await _getLocalFile();
      final jsonList = species.map((s) => s.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      rethrow;
    }
  }
} 