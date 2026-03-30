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
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_view/general_user_trajectory_view_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_view/general_user_trajectory_view_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_view/general_user_trajectory_view_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/google_trajectory_live_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class GeneralUserTrajectoryViewPage extends StatefulWidget {
  const GeneralUserTrajectoryViewPage({super.key});

  @override
  State<GeneralUserTrajectoryViewPage> createState() =>
      _GeneralUserTrajectoryViewPageState();
}

class _GeneralUserTrajectoryViewPageState
    extends State<GeneralUserTrajectoryViewPage> {
  gmaps.GoogleMapController? _mapController;

  void _openFiltersSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: const Color(0x66000000),
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<GeneralUserTrajectoryFiltersBloc>(),
          child: const _TrajectoryFiltersSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          BlocListener<
            GeneralUserTrajectoryViewBloc,
            GeneralUserTrajectoryViewState
          >(
            listenWhen: (previous, current) =>
                previous.zoom != current.zoom &&
                current.status == GeneralUserTrajectoryViewStatus.loaded,
            listener: (_, state) {
              _mapController?.animateCamera(
                gmaps.CameraUpdate.zoomTo(state.zoom.clamp(3, 17)),
              );
            },
            child:
                BlocBuilder<
                  GeneralUserTrajectoryViewBloc,
                  GeneralUserTrajectoryViewState
                >(
                  builder: (context, state) {
                    final filters = context.watch<GeneralUserTrajectoryFiltersBloc>().state;
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: _buildMapLayer(context, state, filters),
                        ),
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
                                      context.go(AppRoutes.buoyOverviewPath);
                                    }
                                  },
                                  icon: Icons.arrow_back,
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
                                      .read<GeneralUserTrajectoryViewBloc>()
                                      .add(
                                        const ZoomInGeneralUserTrajectoryView(),
                                      )
                                : null,
                            onZoomOut: state.canZoomOut
                                ? () => context
                                      .read<GeneralUserTrajectoryViewBloc>()
                                      .add(
                                        const ZoomOutGeneralUserTrajectoryView(),
                                      )
                                : null,
                          ),
                        ),
                        const Positioned(
                          left: 40,
                          right: 40,
                          bottom: 124,
                          child: _MapLegendCard(),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: _BottomTogglePanel(
                            onTap: _openFiltersSheet,
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
    GeneralUserTrajectoryViewState state,
    GeneralUserTrajectoryFiltersState filters,
  ) {
    final hasPrimaryPoints = state.trajectoryPoints.isNotEmpty;
    final hasFilterPoints = filters.trajectoryPoints.isNotEmpty;
    final shouldBlockForInitialLoad =
        (state.status == GeneralUserTrajectoryViewStatus.loading ||
            state.status == GeneralUserTrajectoryViewStatus.initial) &&
        !hasPrimaryPoints &&
        !hasFilterPoints;

    if (shouldBlockForInitialLoad) {
      return const AppLoader();
    }

    if (state.status == GeneralUserTrajectoryViewStatus.error) {
      return AppErrorView(
        message: state.message,
        onRetry: () {
          context.read<GeneralUserTrajectoryViewBloc>().add(
            LoadGeneralUserTrajectoryView(buoyId: state.buoyId),
          );
        },
      );
    }

    final points =
        (filters.status == GeneralUserTrajectoryFiltersStatus.loaded &&
            filters.trajectoryPoints.isNotEmpty)
        ? filters.displayedPoints
        : state.trajectoryPoints;

    final showInlineLoader =
        state.status == GeneralUserTrajectoryViewStatus.loading ||
        filters.status == GeneralUserTrajectoryFiltersStatus.loading;

    return Stack(
      children: [
        Positioned.fill(
          child: GoogleTrajectoryLiveMapView(
            points: points,
            initialZoom: state.zoom,
            showLabels: filters.status == GeneralUserTrajectoryFiltersStatus.loaded
                ? filters.gpsCoordinatesEnabled
                : true,
            showSecondaryLabels:
                filters.status == GeneralUserTrajectoryFiltersStatus.loaded
                ? filters.timestampsEnabled
                : false,
            interactive: true,
            onControllerReady: (c) => _mapController = c,
          ),
        ),
        if (showInlineLoader)
          const Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Center(child: AppLoader()),
            ),
          ),
      ],
    );
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
            icon: Icons.wifi_off,
            label: 'Offline',
            color: Color(0xFFE74C3C),
          ),
          AppMapLegendItem(
            svgAssetPath: AppAssets.icBatteryLow,
            label: 'Battery Low',
            color: Color(0xFF4F95DA),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF2D3238),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrajectoryFiltersSheet extends StatelessWidget {
  const _TrajectoryFiltersSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      GeneralUserTrajectoryFiltersBloc,
      GeneralUserTrajectoryFiltersState
    >(
      builder: (context, state) {
        if (state.status == GeneralUserTrajectoryFiltersStatus.loading ||
            state.status == GeneralUserTrajectoryFiltersStatus.initial) {
          return _TrajectoryFiltersBottomSheetContainer(
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: AppLoader(),
            ),
          );
        }

        if (state.status == GeneralUserTrajectoryFiltersStatus.error) {
          return _TrajectoryFiltersBottomSheetContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: AppErrorView(
                message: state.message,
                onRetry: () {
                  context.read<GeneralUserTrajectoryFiltersBloc>().add(
                    LoadGeneralUserTrajectoryFilters(buoyId: state.buoyId),
                  );
                },
              ),
            ),
          );
        }

        return _TrajectoryFiltersBottomSheetContainer(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 1),
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
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFD2D2D2), thickness: 1),
                const SizedBox(height: 8),
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TrajectoryFiltersBottomSheetContainer extends StatelessWidget {
  const _TrajectoryFiltersBottomSheetContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height * 0.34,
        maxHeight: MediaQuery.sizeOf(context).height * 0.52,
      ),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}
