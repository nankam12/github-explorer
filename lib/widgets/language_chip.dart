import 'package:flutter/material.dart';

class LanguageChip extends StatelessWidget {
  const LanguageChip({
    super.key,
    required this.name,
    required this.percent,
  });

  final String name;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Text('${percent.toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0, 1),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
