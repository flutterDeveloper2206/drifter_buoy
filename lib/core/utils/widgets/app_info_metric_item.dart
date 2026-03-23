import 'package:flutter/material.dart';

class AppInfoMetricItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const AppInfoMetricItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor = const Color(0xFF4A4A4A),
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF2C2C2C),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF616161),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
