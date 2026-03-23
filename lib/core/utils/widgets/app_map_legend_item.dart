import 'package:flutter/material.dart';

class AppMapLegendItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const AppMapLegendItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFF36414B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
