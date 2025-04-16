import 'package:flutter/material.dart';
import 'character_sheet_screen.dart';
import 'character_list_screen.dart';
import 'spell_list_screen.dart';
import '../models/character.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Character? _selectedCharacter;

  void _onCharacterSelected(Character character) {
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
    return Scaffold(
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
          if (_selectedCharacter != null)
            SpellListScreen(character: _selectedCharacter!)
          else
            const Center(
              child: Text(
                'Select a character from the list',
                style: TextStyle(fontSize: 18),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index > 0 && _selectedCharacter == null) {
            // Don't allow navigation to character sheet or spells without a selected character
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
    );
  }
} 