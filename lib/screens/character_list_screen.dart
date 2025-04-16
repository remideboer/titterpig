import 'package:flutter/material.dart';
import '../models/character.dart';
import '../repositories/local_character_repository.dart';
import '../theme/app_theme.dart';

class CharacterListScreen extends StatefulWidget {
  final Function(Character) onCharacterSelected;

  const CharacterListScreen({
    super.key,
    required this.onCharacterSelected,
  });

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  final LocalCharacterRepository _repository = LocalCharacterRepository();
  List<Character> _characters = [];

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    final characters = await _repository.getAllCharacters();
    setState(() {
      _characters = characters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Characters'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: _characters.length,
        itemBuilder: (context, index) {
          final character = _characters[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                character.name,
                style: AppTheme.titleStyle,
              ),
              subtitle: Text(
                character.species.name,
                style: AppTheme.bodyStyle,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => widget.onCharacterSelected(character),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to character creation
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 