import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../repositories/local_character_repository.dart';
import '../theme/app_theme.dart';
import '../viewmodels/character_list_viewmodel.dart';
import 'character_creation_screen.dart';
import 'character_sheet_screen.dart';
import '../utils/name_formatter.dart';
import '../widgets/character_list_item.dart';

enum SortOption {
  lifeStatus,
  name,
  species,
  creationDate,
  lastUsed,
}

class SortCriteria {
  final SortOption option;
  final bool ascending;

  SortCriteria(this.option, {this.ascending = true});
}

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
  List<SortCriteria> _sortCriteria = [
    SortCriteria(SortOption.lifeStatus),
    SortCriteria(SortOption.name),
  ];
  bool _showSortOptions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterListViewModel>().loadCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Characters'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              setState(() {
                _showSortOptions = !_showSortOptions;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          if (_showSortOptions)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort Characters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Selected sort criteria with reordering
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sortCriteria.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final item = _sortCriteria.removeAt(oldIndex);
                        _sortCriteria.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final criteria = _sortCriteria[index];
                      return ReorderableDragStartListener(
                        key: ValueKey(criteria),
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FilterChip(
                                label: Text(_getSortOptionText(criteria.option)),
                                selected: true,
                                onSelected: (selected) {
                                  setState(() {
                                    _sortCriteria.removeAt(index);
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  criteria.ascending ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _sortCriteria[index] = SortCriteria(
                                      criteria.option,
                                      ascending: !criteria.ascending,
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // Available sort options
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: SortOption.values.map((option) {
                      final isSelected = _sortCriteria.any((c) => c.option == option);
                      if (isSelected) return const SizedBox.shrink();
                      return FilterChip(
                        label: Text(_getSortOptionText(option)),
                        selected: false,
                        onSelected: (selected) {
                          setState(() {
                            _sortCriteria.add(SortCriteria(option));
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Consumer<CharacterListViewModel>(
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
                          onPressed: () => viewModel.loadCharacters(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final characters = viewModel.characters;
                if (characters.isEmpty) {
                  return const Center(child: Text('No characters found'));
                }

                // Sort characters based on criteria
                final sortedCharacters = List<Character>.from(characters);
                for (final criteria in _sortCriteria.reversed) {
                  sortedCharacters.sort((a, b) {
                    var comparison = _compareByCriteria(a, b, criteria);
                    return criteria.ascending ? comparison : -comparison;
                  });
                }

                return ListView.builder(
                  itemCount: sortedCharacters.length,
                  itemBuilder: (context, index) {
                    final character = sortedCharacters[index];
                    return CharacterListItem(
                      character: character,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CharacterCreationScreen(
                              character: character,
                              onCharacterSaved: (updatedCharacter) {
                                viewModel.loadCharacters();
                              },
                            ),
                          ),
                        );
                      },
                      onDelete: () async {
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
                          viewModel.loadCharacters();
                        }
                      },
                      onTap: () {
                        widget.onCharacterSelected(character);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateCharacter,
        child: const Icon(Icons.add),
        tooltip: 'Add Character',
      ),
    );
  }

  Future<void> _navigateToCreateCharacter() async {
    final result = await Navigator.push<Character>(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterCreationScreen(
          onCharacterSaved: (character) {
            context.read<CharacterListViewModel>().loadCharacters();
          },
        ),
      ),
    );
    
    if (result != null) {
      await context.read<CharacterListViewModel>().loadCharacters();
      if (mounted) {
        // Navigate to the character sheet for the newly created character
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CharacterSheetScreen(
              character: result,
              onCharacterUpdated: (updatedCharacter) {
                context.read<CharacterListViewModel>().loadCharacters();
              },
            ),
          ),
        );
      }
    }
  }

  String _getSortOptionText(SortOption option) {
    switch (option) {
      case SortOption.lifeStatus:
        return 'Life Status';
      case SortOption.name:
        return 'Name';
      case SortOption.species:
        return 'Species';
      case SortOption.creationDate:
        return 'Creation Date';
      case SortOption.lastUsed:
        return 'Last Used';
    }
  }

  int _compareByCriteria(Character a, Character b, SortCriteria criteria) {
    switch (criteria.option) {
      case SortOption.lifeStatus:
        final aIsDead = a.isDead;
        final bIsDead = b.isDead;
        if (aIsDead != bIsDead) return aIsDead ? 1 : -1;
        return 0;
      case SortOption.name:
        return a.name.compareTo(b.name);
      case SortOption.species:
        return a.species.name.compareTo(b.species.name);
      case SortOption.creationDate:
        return a.createdAt.compareTo(b.createdAt);
      case SortOption.lastUsed:
        return a.lastUsed.compareTo(b.lastUsed);
    }
  }
} 