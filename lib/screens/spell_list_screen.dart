import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/spell_list_viewmodel.dart';
import '../models/spell.dart';
import '../services/dnd_spell_converter.dart';
import 'spell_detail_screen.dart';
import '../widgets/hexagon_shape.dart';
import '../theme/app_theme.dart';

class SpellListScreen extends StatefulWidget {
  final Function(Spell) onSpellSelected;

  const SpellListScreen({Key? key, required this.onSpellSelected}) : super(key: key);

  @override
  State<SpellListScreen> createState() => _SpellListScreenState();
}

class _SpellListScreenState extends State<SpellListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DndSpellConverter _converter = DndSpellConverter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpellListViewModel>().loadSpells();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spells'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SpellListViewModel>().loadSpells(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Spells',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                context.read<SpellListViewModel>().filterSpells(value);
              },
            ),
          ),
          Expanded(
            child: Consumer<SpellListViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${viewModel.error}'),
                        ElevatedButton(
                          onPressed: () => viewModel.loadSpells(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final spells = viewModel.filteredSpells;
                if (spells.isEmpty) {
                  return const Center(child: Text('No spells found'));
                }

                return ListView.builder(
                  itemCount: spells.length,
                  itemBuilder: (context, index) {
                    final spell = spells[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        leading: _buildHexagon(spell.cost.toString(), ''),
                        title: Text(spell.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (spell.damage.isNotEmpty)
                              Text('${spell.damage} ${spell.effect}'),
                            Text('${spell.type} • Range: ${spell.range}'),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpellDetailScreen(
                                spell: spell,
                                onSpellSelected: widget.onSpellSelected,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHexagon(String value, String label) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          HexagonContainer(
            size: 40,
            fillColor: AppTheme.primaryColor,
            borderColor: AppTheme.highlightColor,
            borderWidth: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (label.isNotEmpty)
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 