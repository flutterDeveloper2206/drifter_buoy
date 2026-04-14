import 'package:drifter_buoy/core/constants/app_assets.dart';
import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/storage/auth_session_store.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:drifter_buoy/core/utils/widgets/app_general_user_bottom_nav.dart';
import 'package:drifter_buoy/core/utils/widgets/app_general_user_main_app_bar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_shimmer.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/general_user_back_navigation_scope.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_state.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_map_dashboard_get_buoy_dashboard_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_map_dashboard_get_buoy_map_dashboard_response.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/general_user_google_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_event.dart';

class GeneralUserDashboardPage extends StatelessWidget {
  const GeneralUserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<GeneralUserDashboardBloc, GeneralUserDashboardState>(
      builder: (context, state) {
        final showSetup = switch (state) {
          GeneralUserDashboardInitial() =>
            sl<AuthSessionStore>().cachedIsAdmin ?? false,
          _ => state.isAdmin,
        };

        Widget body;
        if (state is GeneralUserDashboardLoaded) {
          final loadedState = state;
          final dashboardData = loadedState.data;
          final summary = dashboardData.summary;
          body = RefreshIndicator(
            color: const Color(0xFF1F88D1),
            onRefresh: () async {
              final bloc = context.read<GeneralUserDashboardBloc>();
              bloc.add(LoadGeneralUserDashboard(isAdmin: loadedState.isAdmin));
              await bloc.stream.firstWhere(
                (s) => s is! GeneralUserDashboardLoading,
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: textTheme.titleLarge?.copyWith(
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
                  GestureDetector(
                  onTap: (){
                    context.go(
                      AppRoutes.mapPath,
                      extra: loadedState.mapData,
                    );
                  },
                  child:Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 2, right: 4),
                          child: Row(
                            children: [
                              Text(
                                "Buoy's Map View",
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2E343A),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  context.go(
                                    AppRoutes.mapPath,
                                    extra: loadedState.mapData,
                                  );
                                },
                                icon: const Icon(Icons.arrow_forward, size: 22),
                                color: const Color(0xFF23282D),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _MapPreviewCard(
                          dashboardData: dashboardData,
                          mapData: loadedState.mapData,
                        ),
                      ],
                    ),
                  ),
                ),],
              ),
            ),
          );
        } else if (state is GeneralUserDashboardError) {
          body = AppErrorView(
            message: state.message,
            onRetry: () {
              context.read<GeneralUserDashboardBloc>().add(
                LoadGeneralUserDashboard(isAdmin: state.isAdmin),
              );
            },
          );
        } else {
          body = _DashboardShimmer();
        }

        return PopScope(
          canPop: GoRouter.of(context).canPop(),
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) {
              return;
            }
            await handleGeneralUserDashboardBack(context);
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFD9DEE2),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppGeneralUserMainAppBar(),
                  Expanded(child: body),
                  AppGeneralUserBottomNav(
                    selectedTab: GeneralUserBottomNavTab.home,
                    onTap: (tab) {
                      switch (tab) {
                        case GeneralUserBottomNavTab.home:
                          context.go(AppRoutes.dashboardPath);
                        case GeneralUserBottomNavTab.buoys:
                          context.go(AppRoutes.buoysPath);
                        case GeneralUserBottomNavTab.map:
                          if (state is GeneralUserDashboardLoaded &&
                              state.mapData.isNotEmpty) {
                            context.push(
                              AppRoutes.trajectoryViewPath,
                              extra: state.mapData.first.buoyId,
                            );
                          } else {
                            context.push(AppRoutes.trajectoryViewPath);
                          }
                        case GeneralUserBottomNavTab.export:
                          context.push(AppRoutes.exportSelectionPath);
                        case GeneralUserBottomNavTab.setup:
                          context.push(AppRoutes.setupPath);
                      }
                    },
                    showSetup: showSetup,
                  ),
                ],
              ),
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
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

  const _MapPreviewCard({required this.dashboardData, required this.mapData});

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 360,
        width: double.infinity,
        child: GeneralUserGoogleMapView(
          buoys: buoyMarkers,
          zoomLevel: _calculatePreviewZoom(buoyMarkers),
          mapType: MapDisplayType.terrain,
          showDeviceName: true,
          showBatteryStatus: false,
          selectedBuoy: null,
          boundsPaddingPx: 100,
          fitBoundsLatitudeExpansionDeg: 0.003,
          showEmbeddedZoomControls: true,
          showFitAllBuoysControl: true,
        ),
      ),
    );
  }

  double _calculatePreviewZoom(List<DummyBuoy> buoys) {
    if (buoys.isEmpty) {
      return 10.3;
    }
    if (buoys.length == 1) {
      return 13.0;
    }

    var minLat = buoys.first.position.latitude;
    var maxLat = buoys.first.position.latitude;
    var minLng = buoys.first.position.longitude;
    var maxLng = buoys.first.position.longitude;

    for (final b in buoys.skip(1)) {
      final lat = b.position.latitude;
      final lng = b.position.longitude;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    final latSpan = (maxLat - minLat).abs();
    final lngSpan = (maxLng - minLng).abs();
    final span = latSpan > lngSpan ? latSpan : lngSpan;

    if (span <= 0.01) return 13.2;
    if (span <= 0.03) return 12.3;
    if (span <= 0.06) return 11.6;
    if (span <= 0.12) return 10.8;
    if (span <= 0.22) return 10.0;
    return 9.4;
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
