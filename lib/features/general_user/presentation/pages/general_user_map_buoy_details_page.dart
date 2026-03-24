import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_info_metric_item.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/core/utils/widgets/app_map_legend_item.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_buoy_details/general_user_map_buoy_details_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_buoy_details/general_user_map_buoy_details_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_buoy_details/general_user_map_buoy_details_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class GeneralUserMapBuoyDetailsPage extends StatefulWidget {
  const GeneralUserMapBuoyDetailsPage({super.key});

  @override
  State<GeneralUserMapBuoyDetailsPage> createState() =>
      _GeneralUserMapBuoyDetailsPageState();
}

class _GeneralUserMapBuoyDetailsPageState
    extends State<GeneralUserMapBuoyDetailsPage> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          BlocListener<
            GeneralUserMapBuoyDetailsBloc,
            GeneralUserMapBuoyDetailsState
          >(
            listenWhen: (previous, current) {
              return (previous.zoom != current.zoom ||
                      previous.selectedIndex != current.selectedIndex) &&
                  current.status == GeneralUserMapBuoyDetailsStatus.loaded;
            },
            listener: (_, state) {
              final center =
                  state.selectedDetail?.buoy.position ?? _safeMapCenter();
              _mapController.move(center, state.zoom);
            },
            child:
                BlocBuilder<
                  GeneralUserMapBuoyDetailsBloc,
                  GeneralUserMapBuoyDetailsState
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
                                  onTap: () => context.go(AppRoutes.mapPath),
                                  icon: Icons.arrow_back,
                                ),
                                const Spacer(),
                                AppIconCircleButton(
                                  onTap: () =>
                                      context.go(AppRoutes.mapPathOpenSearch),
                                  icon: Icons.search,
                                ),
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
                                      .read<GeneralUserMapBuoyDetailsBloc>()
                                      .add(const ZoomInGeneralUserMapBuoy())
                                : null,
                            onZoomOut: state.canZoomOut
                                ? () => context
                                      .read<GeneralUserMapBuoyDetailsBloc>()
                                      .add(const ZoomOutGeneralUserMapBuoy())
                                : null,
                          ),
                        ),
                        if (state.status ==
                                GeneralUserMapBuoyDetailsStatus.loaded &&
                            state.selectedDetail != null)
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 165,
                            child: _BuoyDetailsCard(
                              detail: state.selectedDetail!,
                              onTap: () => context.push(
                                AppRoutes.buoyOverviewPath,
                                extra: state.selectedDetail!.buoy.id,
                              ),
                            ),
                          ),
                        Positioned(
                          left: 40,
                          right: 40,
                          bottom: 124,
                          child: _MapLegendCard(
                            selectedDetail: state.selectedDetail,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: _BottomTogglePanel(
                            onTap: () => context.go(AppRoutes.mapFiltersPath),
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
    GeneralUserMapBuoyDetailsState state,
  ) {
    if (state.status == GeneralUserMapBuoyDetailsStatus.loading ||
        state.status == GeneralUserMapBuoyDetailsStatus.initial) {
      return const AppLoader();
    }

    if (state.status == GeneralUserMapBuoyDetailsStatus.error) {
      return AppErrorView(
        message: state.message,
        onRetry: () {
          context.read<GeneralUserMapBuoyDetailsBloc>().add(
            const LoadGeneralUserMapBuoyDetails(),
          );
        },
      );
    }

    return DummyBuoyMapView(
      mapController: _mapController,
      interactive: true,
      showLabels: true,
      initialZoom: state.zoom,
      buoys: state.buoys,
      selectedBuoy: state.selectedDetail?.buoy,
      onBuoyTap: (buoy) {
        context.read<GeneralUserMapBuoyDetailsBloc>().add(
          SelectGeneralUserMapBuoy(buoy),
        );
      },
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

class _BuoyDetailsCard extends StatelessWidget {
  final GeneralUserBuoyDetail detail;
  final VoidCallback onTap;

  const _BuoyDetailsCard({required this.detail, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (detail.buoy.status) {
      BuoyStatus.active => const Color(0xFF2CC66A),
      BuoyStatus.offline => const Color(0xFFE74C3C),
      BuoyStatus.batteryLow => const Color(0xFF4F95DA),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    detail.buoy.id,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF2E2E2E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.wifi, color: statusColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    detail.statusLabel,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Last Update : ${detail.lastUpdate}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF6A6A6A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AppInfoMetricItem(
                      icon: Icons.battery_6_bar,
                      value: detail.batteryVoltage,
                      label: 'Battery',
                    ),
                  ),
                  Expanded(
                    child: AppInfoMetricItem(
                      icon: Icons.gps_fixed,
                      value: detail.gpsValue,
                      label: 'GPS',
                    ),
                  ),
                  Expanded(
                    child: AppInfoMetricItem(
                      icon: Icons.network_cell,
                      value: detail.signalValue,
                      label: 'Signal',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapLegendCard extends StatelessWidget {
  final GeneralUserBuoyDetail? selectedDetail;

  const _MapLegendCard({required this.selectedDetail});

  @override
  Widget build(BuildContext context) {
    final selectedStatus = selectedDetail?.buoy.status;

    Color legendColor(BuoyStatus status, Color defaultColor) {
      if (selectedStatus == null || selectedStatus == status) {
        return defaultColor;
      }
      return Colors.grey.shade400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppMapLegendItem(
            icon: Icons.wifi,
            label: 'Active',
            color: legendColor(BuoyStatus.active, const Color(0xFF4CAF50)),
          ),
          AppMapLegendItem(
            icon: Icons.wifi_off,
            label: 'Offline',
            color: legendColor(BuoyStatus.offline, const Color(0xFFE74C3C)),
          ),
          AppMapLegendItem(
            icon: Icons.battery_1_bar,
            label: 'Battery Low',
            color: legendColor(BuoyStatus.batteryLow, const Color(0xFF4F95DA)),
          ),
        ],
      ),
    );
  }
}

class _BottomTogglePanel extends StatelessWidget {
  final VoidCallback onTap;

  const _BottomTogglePanel({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Icon(
                  Icons.keyboard_arrow_up,
                  size: 22,
                  color: Color(0xFF2E343A),
                ),
              ),
            ),
            Text(
              'Toggles and Filters',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF2D3238),
                fontWeight: FontWeight.w700,
              ),
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
