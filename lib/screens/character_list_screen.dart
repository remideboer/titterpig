import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/character.dart';
import '../repositories/local_character_repository.dart';
import '../theme/app_theme.dart';
import 'character_creation_screen.dart';

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
      _characters = characters..sort((a, b) {
        // First sort by life status (alive before dead)
        if (a.lifeStat.current == 0 && b.lifeStat.current > 0) return 1;
        if (a.lifeStat.current > 0 && b.lifeStat.current == 0) return -1;
        // Then sort by name within each group
        return a.name.compareTo(b.name);
      });
    });
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

  Future<void> _editCharacter(Character character) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterCreationScreen(
          character: character,
          onCharacterSaved: (updatedCharacter) {
            setState(() {
              final index = _characters.indexWhere((c) => c.id == updatedCharacter.id);
              if (index != -1) {
                _characters[index] = updatedCharacter;
              }
            });
          },
        ),
      ),
    );

    if (result == true) {
      await _loadCharacters();
    }
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
          final isDead = character.lifeStat.current == 0;
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDead ? Colors.grey[100] : null,
            child: ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      character.name,
                      style: AppTheme.titleStyle.copyWith(
                        color: isDead ? Colors.grey[600] : null,
                      ),
                    ),
                  ),
                  if (isDead)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SvgPicture.asset(
                        'assets/svg/death-skull.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          Colors.grey[600]!,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                character.species.name,
                style: AppTheme.bodyStyle.copyWith(
                  color: isDead ? Colors.grey[500] : null,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: isDead ? Colors.grey[600] : null,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editCharacter(character);
                          break;
                        case 'delete':
                          _deleteCharacter(character);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: isDead ? Colors.grey[600] : null,
                  ),
                ],
              ),
              onTap: () => widget.onCharacterSelected(character),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CharacterCreationScreen(
                onCharacterSaved: (character) async {
                  await _loadCharacters();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 