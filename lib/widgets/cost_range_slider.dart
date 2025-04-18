import 'package:flutter/material.dart';

class CostRangeSlider extends StatelessWidget {
  final double maxCost;
  final RangeValues currentRange;
  final Function(RangeValues) onChanged;

  const CostRangeSlider({
    super.key,
    required this.maxCost,
    required this.currentRange,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Cost: ${currentRange.start.toInt()} - ${currentRange.end.toInt()}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('0'),
            Expanded(
              child: RangeSlider(
                values: currentRange,
                min: 0,
                max: maxCost,
                divisions: maxCost.toInt(),
                labels: RangeLabels(
                  currentRange.start.toInt().toString(),
                  currentRange.end.toInt().toString(),
                ),
                onChanged: onChanged,
              ),
            ),
            Text(maxCost.toInt().toString()),
          ],
        ),
      ],
    );
  }
} 