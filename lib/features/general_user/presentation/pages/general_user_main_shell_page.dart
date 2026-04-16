import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/storage/auth_session_store.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_register_device_token.dart';
import 'package:drifter_buoy/core/utils/widgets/app_general_user_bottom_nav.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_devices/general_user_setup_devices_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_devices/general_user_setup_devices_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Hosts the general-user bottom navigation once; tab content is switched via
/// [StatefulNavigationShell] (indexed stack) instead of separate full routes.
class GeneralUserMainShellPage extends StatefulWidget {
  const GeneralUserMainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static GeneralUserBottomNavTab tabForBranchIndex(int index) {
    return switch (index) {
      0 => GeneralUserBottomNavTab.home,
      1 => GeneralUserBottomNavTab.buoys,
      2 => GeneralUserBottomNavTab.export,
      3 => GeneralUserBottomNavTab.setup,
      _ => GeneralUserBottomNavTab.home,
    };
  }

  static int? branchIndexForTab(GeneralUserBottomNavTab tab) {
    return switch (tab) {
      GeneralUserBottomNavTab.home => 0,
      GeneralUserBottomNavTab.buoys => 1,
      GeneralUserBottomNavTab.export => 2,
      GeneralUserBottomNavTab.setup => 3,
      GeneralUserBottomNavTab.map => null,
    };
  }

  @override
  State<GeneralUserMainShellPage> createState() =>
      _GeneralUserMainShellPageState();
}

class _GeneralUserMainShellPageState extends State<GeneralUserMainShellPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _dispatchLoadForShellIndex(widget.navigationShell.currentIndex);
    });
  }

  @override
  void didUpdateWidget(GeneralUserMainShellPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
        widget.navigationShell.currentIndex) {
      _dispatchLoadForShellIndex(widget.navigationShell.currentIndex);
    }
  }

  void _dispatchLoadForShellIndex(int index) {
    final isAdmin = sl<AuthSessionStore>().cachedIsAdmin ?? false;
    switch (index) {
      case 0:
        _registerDeviceTokenForHomeDashboard();
        context.read<GeneralUserDashboardBloc>().add(
              LoadGeneralUserDashboard(isAdmin: isAdmin),
            );
        return;
      case 1:
        context.read<GeneralUserBuoysBloc>().add(const LoadGeneralUserBuoys());
        return;
      case 2:
        context.read<GeneralUserExportSelectionBloc>().add(
              const LoadGeneralUserExportSelection(),
            );
        return;
      case 3:
        context.read<GeneralUserSetupDevicesBloc>().add(
              const LoadGeneralUserSetupDevices(),
            );
        return;
      default:
        return;
    }
  }

  /// Home tab hosts [GeneralUserDashboardPage]; register FCM token when user
  /// lands on home / dashboard (including switching back from other tabs).
  void _registerDeviceTokenForHomeDashboard() {
    sl<GeneralUserRegisterDeviceToken>()().then((result) {
      result.fold(
        (failure) => AppLogger.w(
          'Device token registration skipped or failed: ${failure.message}',
        ),
        (_) => AppLogger.i('Device token registered with backend'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: widget.navigationShell,
      bottomNavigationBar: AppGeneralUserBottomNavForSession(
        selectedTab: GeneralUserMainShellPage.tabForBranchIndex(
          widget.navigationShell.currentIndex,
        ),
        onTap: (tab) {
          final idx = GeneralUserMainShellPage.branchIndexForTab(tab);
          if (idx != null) {
            widget.navigationShell.goBranch(
              idx,
              initialLocation: idx == widget.navigationShell.currentIndex,
            );
            return;
          }
          if (tab == GeneralUserBottomNavTab.map) {
            context.push(AppRoutes.trajectoryViewPath);
          }
        },
      ),
    );
  }
}
