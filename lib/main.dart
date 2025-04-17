import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/character.dart';
import 'models/spell.dart';
import 'screens/character_list_screen.dart';
import 'screens/character_sheet_screen.dart';
import 'screens/spell_list_screen.dart';
import 'viewmodels/character_list_viewmodel.dart';
import 'viewmodels/spell_list_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterListViewModel()),
        ChangeNotifierProvider(create: (_) => SpellListViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTRPG Character Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Character? _selectedCharacter;

  @override
  void initState() {
    super.initState();
    // Load characters and find the last visited one
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CharacterListViewModel>().loadCharacters();
      final characters = context.read<CharacterListViewModel>().characters;
      if (characters.isNotEmpty) {
        // Find the character with the most recent lastUsed date
        final lastVisited = characters.reduce((a, b) => 
          a.lastUsed.isAfter(b.lastUsed) ? a : b
        );
        setState(() {
          _selectedCharacter = lastVisited;
          _selectedIndex = 1; // Switch to character sheet
        });
      }
    });
  }

  void _onCharacterSelected(Character character) {
    setState(() {
      _selectedCharacter = character;
      _selectedIndex = 1; // Switch to character sheet
    });
  }

  void _onCharacterUpdated(Character character) {
    setState(() {
      _selectedCharacter = character;
    });
    context.read<CharacterListViewModel>().loadCharacters();
  }

  void _onSpellSelected(Spell spell) {
    // TODO: Handle spell selection
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      // If not on the home screen, go back to home screen
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }

    // If on home screen, show exit confirmation
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ?? false;

    return shouldExit;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
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
              const Center(child: Text('Select a character to view their sheet')),
            SpellListScreen(
              onSpellSelected: _onSpellSelected,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Characters',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Sheet',
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
