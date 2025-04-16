import 'package:flutter/services.dart';
import 'dart:convert';

class NameDataRepository {
  static const String _nameDataAssetPath = 'assets/data/names.json';

  Future<Map<String, dynamic>> getNameData() async {
    try {
      final String jsonString = await rootBundle.loadString(_nameDataAssetPath);
      return json.decode(jsonString);
    } catch (e) {
      // Fallback to default name data if file can't be loaded
      return {
        'human': {
          'firstNames': ['John', 'Jane', 'Michael', 'Sarah', 'David'],
          'lastNames': ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones']
        },
        'dwarf': {
          'firstNames': ['Thorin', 'Gimli', 'Balin', 'Dwalin', 'Ori'],
          'lastNames': ['Stonehelm', 'Ironfist', 'Goldbeard', 'Steelaxe', 'Rockbreaker']
        },
        'elf': {
          'firstNames': ['Legolas', 'Arwen', 'Elrond', 'Galadriel', 'Thranduil'],
          'lastNames': ['Greenleaf', 'Evenstar', 'Halfelven', 'Light', 'Star']
        },
        'gnome': {
          'firstNames': ['Pip', 'Nim', 'Tock', 'Fizz', 'Bim'],
          'lastNames': ['Gearspark', 'Cogwheel', 'Springcoil', 'Windup', 'Clockwork']
        },
        'tiefling': {
          'firstNames': ['Zariel', 'Mephisto', 'Baal', 'Asmodeus', 'Belial'],
          'lastNames': ['Hellfire', 'Shadow', 'Night', 'Demon', 'Inferno']
        }
      };
    }
  }
} 