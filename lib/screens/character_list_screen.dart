import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          final isDead = character.lifeStat.current == 0;
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      character.name,
                      style: AppTheme.titleStyle,
                    ),
                  ),
                  if (isDead)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SvgPicture.asset(
                        'assets/svg/death-skull.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                ],
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