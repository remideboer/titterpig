import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/spell.dart';

class SpellRepository {
  final String baseUrl;
  final http.Client client;

  SpellRepository({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<List<Spell>> getSpells() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/spells'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Spell.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load spells: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load spells: $e');
    }
  }

  Future<Spell> getSpellById(String id) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/spells/$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Spell.fromJson(data);
      } else {
        throw Exception('Failed to load spell: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load spell: $e');
    }
  }

  void dispose() {
    client.close();
  }
} 