import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SpellTypeFilter extends StatelessWidget {
  final List<String> availableTypes;
  final Set<String> selectedTypes;
  final Function(Set<String>) onTypesChanged;

  const SpellTypeFilter({
    Key? key,
    required this.availableTypes,
    required this.selectedTypes,
    required this.onTypesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: availableTypes.map((type) {
        final isSelected = selectedTypes.contains(type);
        return FilterChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (bool selected) {
            final newSelection = Set<String>.from(selectedTypes);
            if (selected) {
              newSelection.add(type);
            } else {
              newSelection.remove(type);
            }
            onTypesChanged(newSelection);
          },
          selectedColor: AppTheme.highlightColor.withOpacity(0.2),
          checkmarkColor: AppTheme.highlightColor,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: isSelected ? AppTheme.highlightColor : Colors.grey,
            ),
          ),
        );
      }).toList(),
    );
  }
} 