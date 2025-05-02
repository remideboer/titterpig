import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';

class SvgService {
  static const String _selectableSvgPath = 'assets/svg/selectable';

  Future<List<String>> getSelectableSvgs() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent) as Map<String, dynamic>;
      
      // Filter for SVG files in the selectable directory
      final svgFiles = manifestMap.keys.where((String key) {
        return key.startsWith(_selectableSvgPath) && key.endsWith('.svg');
      }).map((String key) {
        // Return just the filename without the directory path
        return path.basename(key);
      }).toList();

      return svgFiles;
    } catch (e) {
      print('Error loading selectable SVGs: $e');
      return [];
    }
  }
} 