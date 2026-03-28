import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppMapLegendItem extends StatelessWidget {
  final IconData? icon;
  final String? svgAssetPath;
  final String label;
  final Color color;

  const AppMapLegendItem({
    super.key,
    this.icon,
    this.svgAssetPath,
    required this.label,
    required this.color,
  }) : assert(icon != null || svgAssetPath != null);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (svgAssetPath != null)
          SvgPicture.asset(
            svgAssetPath!,
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          )
        else
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
