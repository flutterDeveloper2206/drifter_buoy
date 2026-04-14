import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Logo + notifications + profile menu — use on every general-user main tab
/// so the top bar stays consistent when switching bottom navigation.
class AppGeneralUserMainAppBar extends StatelessWidget {
  const AppGeneralUserMainAppBar({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 4, 0),
    this.extraActions = const [],
  });

  final EdgeInsetsGeometry padding;

  /// Extra icons after notification + menu (e.g. map search).
  final List<Widget> extraActions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Image.asset(
            AppAssets.icLogo,
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.push(AppRoutes.alertsPath),
            icon: const Icon(Icons.notifications_none_rounded),
            color: const Color(0xFF2A2F34),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.profilePath),
            icon: const Icon(Icons.menu_rounded),
            color: const Color(0xFF2A2F34),
          ),
          ...extraActions,
        ],
      ),
    );
  }
}
