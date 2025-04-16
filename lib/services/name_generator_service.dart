import 'package:ttrpg_character_manager/repositories/name_data_repository.dart';
import 'dart:math';

class NameGeneratorService {
  final NameDataRepository _nameDataRepository;
  final Random _random = Random();

  NameGeneratorService(this._nameDataRepository);

  Future<String> generateName(String species) async {
    final nameData = await _nameDataRepository.getNameData();
    final speciesData = nameData[species.toLowerCase()] ?? nameData['human']!;
    
    final firstName = _getRandomElement(speciesData['firstNames'] as List);
    final lastName = _getRandomElement(speciesData['lastNames'] as List);
    
    return '$firstName $lastName';
  }

  String _getRandomElement(List list) {
    return list[_random.nextInt(list.length)];
  }
} 