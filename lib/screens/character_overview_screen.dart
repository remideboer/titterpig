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
    final characters = await _repository.getAllCharacters();
    if (mounted) {  // Check if widget is still mounted
      setState(() {
        _characters = characters..sort((a, b) {
          // First sort by life status (alive before dead)
          final aIsDead = a.lifeStat.current == 0;
          final bIsDead = b.lifeStat.current == 0;
          
          // If one is dead and the other isn't, dead character goes last
          if (aIsDead != bIsDead) {
            return aIsDead ? 1 : -1;
          }
          
          // Split names into parts
          final aNameParts = a.name.split(' ');
          final bNameParts = b.name.split(' ');
          
          // Compare first names
          final firstNameComparison = aNameParts.first.compareTo(bNameParts.first);
          if (firstNameComparison != 0) return firstNameComparison;
          
          // Compare last names if they exist
          if (aNameParts.length > 1 && bNameParts.length > 1) {
            final lastNameComparison = aNameParts.last.compareTo(bNameParts.last);
            if (lastNameComparison != 0) return lastNameComparison;
          }
          
          // Finally compare species
          return a.species.name.compareTo(b.species.name);
        });
        print('Characters loaded: ${_characters.length}');
        print('First character life status: ${_characters.first.lifeStat.current}');
        print('Last character life status: ${_characters.last.lifeStat.current}');
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