import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spell.dart';
import '../viewmodels/spell_list_viewmodel.dart';
import 'spell_edit_screen.dart';

class SpellsAdminScreen extends StatefulWidget {
  const SpellsAdminScreen({Key? key}) : super(key: key);

  @override
  _SpellsAdminScreenState createState() => _SpellsAdminScreenState();
}

class _SpellsAdminScreenState extends State<SpellsAdminScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Spell> _filterSpells(List<Spell> spells) {
    if (_searchQuery.isEmpty) return spells;
    return spells.where((spell) =>
      spell.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      spell.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SpellListViewModel>();
    final spells = _filterSpells(viewModel.allSpells);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Spells'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.refreshSpells(),
            tooltip: 'Refresh Spells',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Spells',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: spells.length,
              itemBuilder: (context, index) {
                final spell = spells[index];
                return ListTile(
                  title: Text(spell.name),
                  subtitle: Text(
                    spell.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Cost: ${spell.cost}'),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpellEditScreen(spell: spell),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => viewModel.removeSpell(spell),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SpellEditScreen(),
          ),
        ),
        tooltip: 'Add Spell',
        child: const Icon(Icons.add),
      ),
    );
  }
} 