import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final spellServiceProvider = Provider<SpellService>((ref) => SpellService());

/// Service for managing spell components and spells
/// Following BR-14: Custom spell components instead of DnD spells
class SpellService {
  // TODO: Replace with actual API endpoint when available
  static const String _baseUrl = 'https://api.example.com/spell-components';

  /// Fetches available spell components from the API
  /// Currently a placeholder for future implementation
  Future<void> fetchSpellComponents() async {
    // Placeholder for future API integration
    // Will fetch custom spell components as per BR-14
    throw UnimplementedError('Spell components API not yet implemented');
  }

  /// Creates a new spell using the provided components
  /// Currently a placeholder for future implementation
  Future<void> createSpell({
    required String name,
    required List<String> componentIds,
    String? description,
  }) async {
    // Placeholder for future API integration
    // Will create spells using custom components as per BR-14
    throw UnimplementedError('Spell creation not yet implemented');
  }
} 