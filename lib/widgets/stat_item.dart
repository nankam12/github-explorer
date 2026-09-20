import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  const StatItem({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(height: 4),
        ],
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
