import 'package:flutter/material.dart';

enum GeneralUserBottomNavTab { buoys, map, export }

class AppGeneralUserBottomNav extends StatelessWidget {
  final GeneralUserBottomNavTab selectedTab;
  final ValueChanged<GeneralUserBottomNavTab> onTap;

  const AppGeneralUserBottomNav({
    super.key,
    required this.selectedTab,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFDDE1E4),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      child: Row(
        children: [
          _BottomNavItem(
            icon: Icons.anchor_outlined,
            label: "Buoy's",
            selected: selectedTab == GeneralUserBottomNavTab.buoys,
            onTap: () => onTap(GeneralUserBottomNavTab.buoys),
          ),
          _BottomNavItem(
            icon: Icons.map_outlined,
            label: 'Map',
            selected: selectedTab == GeneralUserBottomNavTab.map,
            onTap: () => onTap(GeneralUserBottomNavTab.map),
          ),
          _BottomNavItem(
            icon: Icons.file_download_outlined,
            label: 'Export',
            selected: selectedTab == GeneralUserBottomNavTab.export,
            onTap: () => onTap(GeneralUserBottomNavTab.export),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF246CBD);
    final inactiveColor = const Color(0xFF2A2F34);
    final color = selected ? activeColor : inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
