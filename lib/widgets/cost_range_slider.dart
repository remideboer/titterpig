import 'package:flutter/material.dart';

class CostRangeSlider extends StatelessWidget {
  final RangeValues values;
  final double min;
  final double max;
  final ValueChanged<RangeValues> onChanged;
  final String? label;

  const CostRangeSlider({
    Key? key,
    required this.values,
    required this.min,
    required this.max,
    required this.onChanged,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          labels: RangeLabels(
            values.start.toInt().toString(),
            values.end.toInt().toString(),
          ),
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cost: ${values.start.toInt()}'),
              Text('to ${values.end.toInt()}'),
            ],
          ),
        ),
      ],
    );
  }
} 