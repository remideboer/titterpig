import 'package:flutter/material.dart';
import '../models/character.dart';
import '../repositories/local_character_repository.dart';
import '../widgets/character_list_item.dart';
import 'character_creation_screen.dart';
import 'character_sheet_screen.dart';

class CharacterOverviewScreen extends StatefulWidget {
  const CharacterOverviewScreen({Key? key}) : super(key: key);

  @override
  State<CharacterOverviewScreen> createState() => _CharacterOverviewScreenState();
}

class _CharacterOverviewScreenState extends State<CharacterOverviewScreen> {
  final LocalCharacterRepository _repository = LocalCharacterRepository();
  List<Character> _characters = [];

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    print('Loading characters...');
    final chars = await _repository.getAllCharacters();
    if (mounted) {  // Check if widget is still mounted
      setState(() {
        // Sort characters: first by life status (alive first), then by first name
        _characters = chars..sort((a, b) {
          // First sort by life status (alive characters first)
          final aIsDead = a.lifeStat.current == 0;
          final bIsDead = b.lifeStat.current == 0;
          if (aIsDead != bIsDead) {
            return aIsDead ? 1 : -1;
          }
          // Then sort by first name
          final aFirstName = a.name.split(' ').first;
          final bFirstName = b.name.split(' ').first;
          return aFirstName.compareTo(bFirstName);
        });
        print('Characters loaded: ${_characters.length}');
      });
    }
  }

  Future<void> _navigateToCreateCharacter() async {
    print('Navigating to character creation...');
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const CharacterCreationScreen(),
      ),
    );
    
    if (result == true) {
      print('Character was created, reloading list...');
      await _loadCharacters();
    }
  }

  Future<void> _deleteCharacter(Character character) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Character'),
        content: Text('Are you sure you want to delete ${character.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _repository.deleteCharacter(character.id);
      await _loadCharacters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTRPG Character Manager'),
      ),
      body: _characters.isEmpty
          ? const Center(
              child: Text('No characters yet. Create one by tapping the + button!'),
            )
          : ListView.builder(
              itemCount: _characters.length,
              itemBuilder: (context, index) {
                final character = _characters[index];
                return CharacterListItem(
                  character: character,
                  onEdit: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CharacterCreationScreen(
                          character: character,
                        ),
                      ),
                    ).then((_) => _loadCharacters());
                  },
                  onDelete: () => _deleteCharacter(character),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CharacterSheetScreen(
                          character: character,
                          onCharacterUpdated: (updatedCharacter) async {
                            await _repository.updateCharacter(updatedCharacter);
                            await _loadCharacters();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateCharacter,
        child: const Icon(Icons.add),
        tooltip: 'Add Character',
      ),
    );
  }
} 