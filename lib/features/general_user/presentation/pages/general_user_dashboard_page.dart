import 'package:drifter_buoy/core/constants/app_assets.dart';
import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_general_user_bottom_nav.dart';
import 'package:drifter_buoy/core/utils/widgets/app_general_user_main_app_bar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_shimmer.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_state.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_map_dashboard_get_buoy_dashboard_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_map_dashboard_get_buoy_map_dashboard_response.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class GeneralUserDashboardPage extends StatelessWidget {
  const GeneralUserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<GeneralUserDashboardBloc, GeneralUserDashboardState>(
      builder: (context, state) {
        if (state is GeneralUserDashboardLoading ||
            state is GeneralUserDashboardInitial) {
          return Scaffold(
            backgroundColor: Color(0xFFD9DEE2),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppGeneralUserMainAppBar(),
                  Expanded(child: _DashboardShimmer()),
                ],
              ),
            ),
          );
        }

        if (state is GeneralUserDashboardError) {
          return Scaffold(
            backgroundColor: const Color(0xFFD9DEE2),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppGeneralUserMainAppBar(),
                  Expanded(
                    child: AppErrorView(
                      message: state.message,
                      onRetry: () {
                        context.read<GeneralUserDashboardBloc>().add(
                          LoadGeneralUserDashboard(isAdmin: state.isAdmin),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final loadedState = state as GeneralUserDashboardLoaded;
        final dashboardData = loadedState.data;
        final summary = dashboardData.summary;

        return Scaffold(
          backgroundColor: const Color(0xFFD9DEE2),
          body: SafeArea(
            child: Column(
              children: [
                const AppGeneralUserMainAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF23282D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last Update : 10:20 AM',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F88D1),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatItem(
                                  icon: Icons.wifi,
                                  iconColor: Color(0xFF4AAF5D),
                                  title: 'Active Buoys',
                                  value: summary.activeBuoys.toString(),
                                  total: '/${summary.totalBuoys}',
                                ),
                              ),
                              Expanded(
                                child: _StatItem(
                                  icon: Icons.wifi_off,
                                  iconColor: Color(0xFFE85A54),
                                  title: 'Offline Buoys',
                                  value: summary.offlineBuoys.toString(),
                                  total: '/${summary.totalBuoys}',
                                ),
                              ),
                              Expanded(
                                child: _StatItem(
                                  svgAssetPath: AppAssets.icBatteryLow,
                                  iconColor: Color(0xFF4F95DA),
                                  title: 'Battery Low',
                                  value: summary.batteryLowBuoys.toString(),
                                  total: '/${summary.totalBuoys}',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Buoy's Map View",
                                      style: textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF2E343A),
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        context.go(
                                          AppRoutes.mapPath,
                                          extra: loadedState.mapData,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.arrow_forward,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              _MapPreviewCard(
                                dashboardData: dashboardData,
                                mapData: loadedState.mapData,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppGeneralUserBottomNav(
                  selectedTab: GeneralUserBottomNavTab.home,
                  onTap: (tab) {
                    switch (tab) {
                      case GeneralUserBottomNavTab.home:
                        context.go(AppRoutes.dashboardPath);
                      case GeneralUserBottomNavTab.buoys:
                        context.go(AppRoutes.buoysPath);
                      case GeneralUserBottomNavTab.map:
                        context.go(
                          AppRoutes.mapPath,
                          extra: loadedState.mapData,
                        );
                      case GeneralUserBottomNavTab.export:
                        context.push(AppRoutes.exportSelectionPath);
                      case GeneralUserBottomNavTab.setup:
                        context.push(AppRoutes.setupPath);
                    }
                  },
                  showSetup: loadedState.isAdmin,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData? icon;
  final String? svgAssetPath;
  final Color iconColor;
  final String title;
  final String value;
  final String total;

  const _StatItem({
    this.icon,
    this.svgAssetPath,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.total,
  }) : assert(icon != null || svgAssetPath != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (svgAssetPath != null)
          SvgPicture.asset(
            svgAssetPath!,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          )
        else
          Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3D4349),
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF20262B),
              ),
            ),
            Text(
              total,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF646B71),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  final UserMapDashboardGetBuoyDashboardResult dashboardData;
  final List<UserMapDashboardGetBuoyMapDashboardItem> mapData;

  const _MapPreviewCard({
    required this.dashboardData,
    required this.mapData,
  });

  @override
  Widget build(BuildContext context) {
    final summary = dashboardData.summary;
    final locations = mapData.isNotEmpty
        ? mapData
            .map(
              (e) => UserMapDashboardGetBuoyDashboardLocation(
                buoyId: e.buoyId,
                latitude: e.latitude,
                longitude: e.longitude,
              ),
            )
            .toList(growable: false)
        : dashboardData.buoyLocations;

    // Assign marker colors using the server summary counts.
    final activeCount = summary.activeBuoys.clamp(0, locations.length);
    final offlineCount = summary.offlineBuoys.clamp(
      0,
      locations.length - activeCount,
    );
    final batteryLowCount = (locations.length - activeCount - offlineCount)
        .clamp(0, summary.batteryLowBuoys);

    final buoyMarkers = <DummyBuoy>[];

    for (int i = 0; i < locations.length; i++) {
      final location = locations[i];
      final latLng = LatLng(location.latitude, location.longitude);

      final status = i < activeCount
          ? BuoyStatus.active
          : i < activeCount + offlineCount
          ? BuoyStatus.offline
          : i < activeCount + offlineCount + batteryLowCount
          ? BuoyStatus.batteryLow
          : BuoyStatus.offline;

      buoyMarkers.add(
        DummyBuoy(id: location.buoyId, position: latLng, status: status),
      );
    }

    final initialCenter = locations.isNotEmpty
        ? LatLng(locations.first.latitude, locations.first.longitude)
        : const LatLng(37.7749, -122.4194);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        height: 360,
        child: DummyBuoyMapView(
          interactive: false,
          showLabels: false,
          initialCenter: initialCenter,
          initialZoom: 10.3,
          buoys: buoyMarkers,
        ),
      ),
    );
  }
}

class _DashboardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: MediaQuery.of(context).size.width * 0.45,
              color: Colors.white,
            ),
            const SizedBox(height: 6),
            Container(
              height: 14,
              width: MediaQuery.of(context).size.width * 0.65,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Expanded(child: _StatShimmerItem()),
                  Expanded(child: _StatShimmerItem()),
                  Expanded(child: _StatShimmerItem()),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 18,
                        width: MediaQuery.of(context).size.width * 0.48,
                        color: Colors.white,
                      ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: const SizedBox(
                      width: double.infinity,
                      height: 360,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatShimmerItem extends StatelessWidget {
  const _StatShimmerItem();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 14,
            width: MediaQuery.of(context).size.width * 0.2,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Container(
            height: 16,
            width: MediaQuery.of(context).size.width * 0.22,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
