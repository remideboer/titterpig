import 'package:flutter/material.dart';
import 'character_sheet_screen.dart';
import 'character_list_screen.dart';
import 'spell_list_screen.dart';
import 'spells_admin_screen.dart';
import '../models/character.dart';
import '../repositories/local_character_repository.dart';
import '../repositories/last_selected_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Character? _selectedCharacter;
  final LocalCharacterRepository _characterRepository = LocalCharacterRepository();
  late final LastSelectedRepository _lastSelectedRepository;

  @override
  void initState() {
    super.initState();
    _initializeRepositories();
  }

  Future<void> _initializeRepositories() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSelectedRepository = LastSelectedRepository(prefs);
    await _loadLastSelectedCharacter();
  }

  Future<void> _loadLastSelectedCharacter() async {
    final lastSelectedId = _lastSelectedRepository.getLastSelectedCharacterId();
    if (lastSelectedId != null) {
      final character = await _characterRepository.getCharacter(lastSelectedId);
      if (character != null) {
        setState(() {
          _selectedCharacter = character;
          _selectedIndex = 1; // Switch to character sheet tab
        });
      }
    }
  }

  void _onCharacterSelected(Character character) async {
    await _lastSelectedRepository.setLastSelectedCharacterId(character.id);
    setState(() {
      _selectedCharacter = character;
      _selectedIndex = 1; // Switch to character sheet tab
    });
  }

  void _onCharacterUpdated(Character character) {
    setState(() {
      _selectedCharacter = character;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            CharacterListScreen(
              onCharacterSelected: _onCharacterSelected,
            ),
            if (_selectedCharacter != null)
              CharacterSheetScreen(
                character: _selectedCharacter!,
                onCharacterUpdated: _onCharacterUpdated,
              )
            else
              const Center(
                child: Text(
                  'Select a character from the list',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            const SpellsAdminScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 1 && _selectedCharacter == null) {
              // Don't allow navigation to character sheet without a selected character
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a character first'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Characters',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Character Sheet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome),
              label: 'Spells',
            ),
          ],
        ),
      ),
    );
  }
} 