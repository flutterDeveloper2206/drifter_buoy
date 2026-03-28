import 'package:drifter_buoy/core/constants/app_assets.dart';
import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/storage/auth_session_store.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

enum GeneralUserBottomNavTab { home, buoys, map, export, setup }

class AppGeneralUserBottomNav extends StatelessWidget {
  final GeneralUserBottomNavTab selectedTab;
  final ValueChanged<GeneralUserBottomNavTab>? onTap;
  final bool showSetup;

  const AppGeneralUserBottomNav({
    super.key,
    required this.selectedTab,
    this.onTap,
    this.showSetup = true,
  });

  void _handleTap(BuildContext context, GeneralUserBottomNavTab tab) {
    if (tab == selectedTab) {
      return;
    }

    // Allow page-specific navigation overrides when needed.
    if (onTap != null) {
      onTap!(tab);
      return;
    }

    // Default navigation for the general-user bottom tabs.
    //
    // Rules:
    // - Home/Buoys/Map always use `go` (replace current tab page).
    // - Export/Setup use `push` when coming from a "main" tab (so back returns
    //   to that tab), otherwise `go` (replace) to keep the stack clean.
    final shouldPushForSecondaryTab = switch (selectedTab) {
      GeneralUserBottomNavTab.home ||
      GeneralUserBottomNavTab.buoys ||
      GeneralUserBottomNavTab.map => true,
      GeneralUserBottomNavTab.export || GeneralUserBottomNavTab.setup => false,
    };

    switch (tab) {
      case GeneralUserBottomNavTab.home:
        context.go(AppRoutes.dashboardPath);
      case GeneralUserBottomNavTab.buoys:
        context.go(AppRoutes.buoysPath);
      case GeneralUserBottomNavTab.map:
        context.go(AppRoutes.mapPath);
      case GeneralUserBottomNavTab.export:
        if (shouldPushForSecondaryTab) {
          context.push(AppRoutes.exportSelectionPath);
        } else {
          context.go(AppRoutes.exportSelectionPath);
        }
      case GeneralUserBottomNavTab.setup:
        if (shouldPushForSecondaryTab) {
          context.push(AppRoutes.setupPath);
        } else {
          context.go(AppRoutes.setupPath);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFDDE1E4),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, -2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      child: Row(
        children: [
          _BottomNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            selected: selectedTab == GeneralUserBottomNavTab.home,
            onTap: () => _handleTap(context, GeneralUserBottomNavTab.home),
          ),
          _BottomNavItem(
            svgAssetPath: AppAssets.icBuoys,
            label: "Buoy's",
            selected: selectedTab == GeneralUserBottomNavTab.buoys,
            onTap: () => _handleTap(context, GeneralUserBottomNavTab.buoys),
          ),
          _BottomNavItem(
            svgAssetPath: AppAssets.icMap,
            label: 'Map',
            selected: selectedTab == GeneralUserBottomNavTab.map,
            onTap: () => _handleTap(context, GeneralUserBottomNavTab.map),
          ),
          _BottomNavItem(
            svgAssetPath: AppAssets.icExport,
            label: 'Export',
            selected: selectedTab == GeneralUserBottomNavTab.export,
            onTap: () => _handleTap(context, GeneralUserBottomNavTab.export),
          ),
          if (showSetup)
            _BottomNavItem(
              icon: Icons.settings_outlined,
              label: 'Set Up',
              selected: selectedTab == GeneralUserBottomNavTab.setup,
              onTap: () => _handleTap(context, GeneralUserBottomNavTab.setup),
            ),
        ],
      ),
    );
  }
}

/// Bottom bar with **Set Up** tab only when stored session [roleName] is Admin.
///
/// Uses [AuthSessionStore.cachedIsAdmin] only (no [FutureBuilder]) so list API
/// or other rebuilds do not re-run async work and briefly hide the 5th tab.
class AppGeneralUserBottomNavForSession extends StatelessWidget {
  final GeneralUserBottomNavTab selectedTab;
  final ValueChanged<GeneralUserBottomNavTab>? onTap;

  const AppGeneralUserBottomNavForSession({
    super.key,
    required this.selectedTab,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showSetup = sl<AuthSessionStore>().cachedIsAdmin ?? false;
    return AppGeneralUserBottomNav(
      selectedTab: selectedTab,
      onTap: onTap,
      showSetup: showSetup,
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData? icon;
  final String? svgAssetPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    this.icon,
    this.svgAssetPath,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : assert(icon != null || svgAssetPath != null);

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF246CBD);
    final inactiveColor = const Color(0xFF2A2F34);
    final color = selected ? activeColor : inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0x1A246CBD) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                scale: selected ? 1.08 : 1,
                child: svgAssetPath != null
                    ? SvgPicture.asset(
                        svgAssetPath!,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      )
                    : Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
