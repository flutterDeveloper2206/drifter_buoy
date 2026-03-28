import 'package:drifter_buoy/core/constants/app_assets.dart';
import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/core/utils/widgets/app_map_legend_item.dart';
import 'package:drifter_buoy/core/utils/widgets/app_settings_tiles.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_filters/general_user_trajectory_filters_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_filters/general_user_trajectory_filters_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_filters/general_user_trajectory_filters_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_trajectory_live_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class GeneralUserTrajectoryFiltersPage extends StatefulWidget {
  const GeneralUserTrajectoryFiltersPage({super.key});

  @override
  State<GeneralUserTrajectoryFiltersPage> createState() =>
      _GeneralUserTrajectoryFiltersPageState();
}

class _GeneralUserTrajectoryFiltersPageState
    extends State<GeneralUserTrajectoryFiltersPage> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          BlocListener<
            GeneralUserTrajectoryFiltersBloc,
            GeneralUserTrajectoryFiltersState
          >(
            listenWhen: (previous, current) =>
                previous.zoom != current.zoom &&
                current.status == GeneralUserTrajectoryFiltersStatus.loaded,
            listener: (_, state) {
              _mapController.move(_safeMapCenter(), state.zoom);
            },
            child:
                BlocBuilder<
                  GeneralUserTrajectoryFiltersBloc,
                  GeneralUserTrajectoryFiltersState
                >(
                  builder: (context, state) {
                    return Stack(
                      children: [
                        Positioned.fill(child: _buildMapLayer(context, state)),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                            child: Row(
                              children: [
                                AppIconCircleButton(
                                  onTap: () {
                                    if (GoRouter.of(context).canPop()) {
                                      context.pop();
                                    } else {
                                      context.go(
                                        AppRoutes.trajectoryViewPath,
                                        extra: state.buoyId,
                                      );
                                    }
                                  },
                                  icon: Icons.arrow_back,
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Trajectory View',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: const Color(0xFF1E252C),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 48),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + 95,
                          right: 16,
                          child: _MapZoomControl(
                            onZoomIn: state.canZoomIn
                                ? () => context
                                      .read<GeneralUserTrajectoryFiltersBloc>()
                                      .add(
                                        const ZoomInGeneralUserTrajectoryFilters(),
                                      )
                                : null,
                            onZoomOut: state.canZoomOut
                                ? () => context
                                      .read<GeneralUserTrajectoryFiltersBloc>()
                                      .add(
                                        const ZoomOutGeneralUserTrajectoryFilters(),
                                      )
                                : null,
                          ),
                        ),
                        const Positioned(
                          left: 40,
                          right: 40,
                          bottom: 250,
                          child: _MapLegendCard(),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: _FiltersPanel(
                            state: state,
                            onCollapseTap: () {
                              if (GoRouter.of(context).canPop()) {
                                context.pop();
                              } else {
                                context.go(
                                  AppRoutes.trajectoryViewPath,
                                  extra: state.buoyId,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
          ),
    );
  }

  Widget _buildMapLayer(
    BuildContext context,
    GeneralUserTrajectoryFiltersState state,
  ) {
    if (state.status == GeneralUserTrajectoryFiltersStatus.loading ||
        state.status == GeneralUserTrajectoryFiltersStatus.initial) {
      return const AppLoader();
    }

    if (state.status == GeneralUserTrajectoryFiltersStatus.error) {
      return AppErrorView(
        message: state.message,
        onRetry: () {
          context.read<GeneralUserTrajectoryFiltersBloc>().add(
            LoadGeneralUserTrajectoryFilters(buoyId: state.buoyId),
          );
        },
      );
    }

    final points = state.displayedPoints;
    final center = points.isNotEmpty
        ? points[points.length ~/ 2].position
        : const LatLng(37.7749, -122.4194);

    return DummyTrajectoryLiveMapView(
      mapController: _mapController,
      points: points,
      initialZoom: state.zoom,
      initialCenter: center,
      showLabels: state.gpsCoordinatesEnabled,
      showSecondaryLabels: state.showSecondaryLabels,
      interactive: true,
    );
  }

  LatLng _safeMapCenter() {
    try {
      return _mapController.camera.center;
    } catch (_) {
      return const LatLng(37.7749, -122.4194);
    }
  }
}

class _MapZoomControl extends StatelessWidget {
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;

  const _MapZoomControl({this.onZoomIn, this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          IconButton(
            onPressed: onZoomIn,
            icon: const Icon(Icons.add, size: 30, color: Color(0xFF2A2F34)),
          ),
          Container(
            width: 28,
            height: 1,
            color: const Color(0xFFD7DBDF),
            margin: const EdgeInsets.symmetric(vertical: 2),
          ),
          IconButton(
            onPressed: onZoomOut,
            icon: const Icon(Icons.remove, size: 30, color: Color(0xFF2A2F34)),
          ),
        ],
      ),
    );
  }
}

class _MapLegendCard extends StatelessWidget {
  const _MapLegendCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppMapLegendItem(
            icon: Icons.wifi,
            label: 'Active',
            color: Color(0xFF4CAF50),
          ),
          AppMapLegendItem(
            svgAssetPath: AppAssets.icBatteryLow,
            label: 'Battery Low',
            color: Color(0xFF4F95DA),
          ),
          AppMapLegendItem(
            icon: Icons.wifi_off,
            label: 'Offline',
            color: Color(0xFFE74C3C),
          ),
        ],
      ),
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  final GeneralUserTrajectoryFiltersState state;
  final VoidCallback onCollapseTap;

  const _FiltersPanel({required this.state, required this.onCollapseTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onCollapseTap,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 24,
                  color: Color(0xFF2E343A),
                ),
              ),
            ),
            Text(
              'Toggles and Filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF2D2D2D),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFD2D2D2), thickness: 1),
            const SizedBox(height: 12),
            AppSwitchSettingTile(
              label: 'GPS coordinates',
              value: state.gpsCoordinatesEnabled,
              onChanged: (_) {
                context.read<GeneralUserTrajectoryFiltersBloc>().add(
                  const ToggleGpsCoordinatesFilter(),
                );
              },
            ),
            AppSwitchSettingTile(
              label: 'Timestamps',
              value: state.timestampsEnabled,
              onChanged: (_) {
                context.read<GeneralUserTrajectoryFiltersBloc>().add(
                  const ToggleTimestampsFilter(),
                );
              },
            ),
            AppSwitchSettingTile(
              label: 'Battery logs',
              value: state.batteryLogsEnabled,
              onChanged: (_) {
                context.read<GeneralUserTrajectoryFiltersBloc>().add(
                  const ToggleBatteryLogsFilter(),
                );
              },
            ),
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 130,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
