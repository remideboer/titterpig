import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spell.dart';
import '../viewmodels/spell_list_viewmodel.dart';
import 'spell_detail_screen.dart';
import 'spell_edit_screen.dart';

class SpellListScreen extends StatefulWidget {
  const SpellListScreen({Key? key}) : super(key: key);

  @override
  _SpellListScreenState createState() => _SpellListScreenState();
}

class _SpellListScreenState extends State<SpellListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  RangeValues _costRange = const RangeValues(0, 10); // Default cost range

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    // Load spells when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpellListViewModel>().loadSpells();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Spell> _filterSpells(List<Spell> spells) {
    return spells.where((spell) {
      final matchesSearch = _searchQuery.isEmpty ||
          spell.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          spell.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCost = spell.cost >= _costRange.start && spell.cost <= _costRange.end;
      
      return matchesSearch && matchesCost;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SpellListViewModel>();
    final spells = _filterSpells(viewModel.allSpells);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spells'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.refreshSpells(clearCache: true),
            tooltip: 'Reset and Refresh Spells',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
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
                const SizedBox(height: 8),
                // Cost Range Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spell Cost Range: ${_costRange.start.round()} - ${_costRange.end.round()}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    RangeSlider(
                      values: _costRange,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      labels: RangeLabels(
                        _costRange.start.round().toString(),
                        _costRange.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _costRange = values;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (viewModel.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (spells.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No spells found'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: spells.length,
                itemBuilder: (context, index) {
                  final spell = spells[index];
                  return ListTile(
                    title: Text(spell.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spell.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Type: ${spell.type} | Range: ${spell.range}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Cost: ${spell.cost}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpellDetailScreen(spell: spell),
                      ),
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