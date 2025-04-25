import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HealDamageInput extends StatelessWidget {
  final int value;
  final Function(int) onValueChanged;
  final VoidCallback onClear;

  const HealDamageInput({
    super.key,
    required this.value,
    required this.onValueChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.highlightColor,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Minus button
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              icon: const Icon(Icons.remove, size: 16),
              onPressed: () => onValueChanged(value - 1),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          // Number input
          Expanded(
            child: TextField(
              controller: TextEditingController(text: value.toString()),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (text) {
                if (text.isEmpty) {
                  onValueChanged(1);
                  return;
                }
                final newValue = int.tryParse(text);
                if (newValue != null && newValue > 0) {
                  onValueChanged(newValue);
                }
              },
              onSubmitted: (value) {
                onClear();
              },
            ),
          ),
          // Plus button
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              icon: const Icon(Icons.add, size: 16),
              onPressed: () => onValueChanged(value + 1),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
} 