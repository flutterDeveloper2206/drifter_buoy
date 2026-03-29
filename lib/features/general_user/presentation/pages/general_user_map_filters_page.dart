import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/core/utils/widgets/app_settings_tiles.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class GeneralUserMapFiltersPage extends StatelessWidget {
  const GeneralUserMapFiltersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<GeneralUserMapFiltersBloc, GeneralUserMapFiltersState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == GeneralUserMapFiltersStatus.error,
        listener: (context, state) {
          if (state.message.isNotEmpty) {
            AppFlushbar.error(state.message, context: context);
          }
        },
        child:
            BlocBuilder<GeneralUserMapFiltersBloc, GeneralUserMapFiltersState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: DummyBuoyMapView(
                        interactive: false,
                        showLabels: false,
                        buoys: const [],
                        initialCenter: const LatLng(37.812, -122.455),
                        initialZoom: 11.0,
                      ),
                    ),
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
                      child: _SingleZoomControl(
                        onTap: () {
                          AppFlushbar.info(
                            'Zoom control is visible in this prototype state.',
                            context: context,
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildSheetByState(context, state),
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }

  Widget _buildSheetByState(
    BuildContext context,
    GeneralUserMapFiltersState state,
  ) {
    if (state.status == GeneralUserMapFiltersStatus.loading ||
        state.status == GeneralUserMapFiltersStatus.initial) {
      return _AppSheetContainer(
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: AppLoader(),
        ),
      );
    }

    if (state.status == GeneralUserMapFiltersStatus.error) {
      return _AppSheetContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: AppErrorView(
            message: state.message,
            onRetry: () {
              context.read<GeneralUserMapFiltersBloc>().add(
                const LoadGeneralUserMapFilters(),
              );
            },
          ),
        ),
      );
    }

    return _AppSheetContainer(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 22,
                color: Color(0xFF282828),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Toggles and Filters',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF2D2D2D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFD2D2D2), thickness: 1),
            const SizedBox(height: 14),
            _SectionTitle(label: 'Toggles'),
            const SizedBox(height: 8),
            AppSwitchSettingTile(
              label: 'Trajectory',
              value: state.trajectoryEnabled,
              onChanged: (_) {
                context.read<GeneralUserMapFiltersBloc>().add(
                  const ToggleTrajectory(),
                );
              },
            ),
            AppSwitchSettingTile(
              label: 'GPS points',
              value: state.gpsPointsEnabled,
              onChanged: (_) {
                context.read<GeneralUserMapFiltersBloc>().add(
                  const ToggleGpsPoints(),
                );
              },
            ),
            AppSwitchSettingTile(
              label: 'Battery status',
              value: state.batteryStatusEnabled,
              onChanged: (_) {
                context.read<GeneralUserMapFiltersBloc>().add(
                  const ToggleBatteryStatus(),
                );
              },
            ),
            AppSwitchSettingTile(
              label: 'GPRS signal',
              value: state.gprsSignalEnabled,
              onChanged: (_) {
                context.read<GeneralUserMapFiltersBloc>().add(
                  const ToggleGprsSignal(),
                );
              },
            ),
            const SizedBox(height: 10),
            const Divider(color: Color(0xFFD2D2D2), thickness: 1),
            const SizedBox(height: 14),
            _SectionTitle(label: 'Filters'),
            const SizedBox(height: 8),
            AppCheckboxSettingTile(
              label: 'Status (Online / Offline)',
              selected: state.statusFilterEnabled,
              onTap: () {
                context.read<GeneralUserMapFiltersBloc>().add(
                  const ToggleStatusFilter(),
                );
              },
            ),
            AppCheckboxSettingTile(
              label: 'Signal strength',
              selected: state.signalStrengthEnabled,
              onTap: () {
                context.read<GeneralUserMapFiltersBloc>().add(
                  const ToggleSignalStrengthFilter(),
                );
              },
            ),
            AppCheckboxSettingTile(
              label: 'Location / Zone',
              selected: state.locationZoneFilterEnabled,
              onTap: () {
                context.read<GeneralUserMapFiltersBloc>().add(
                  const ToggleLocationZoneFilter(),
                );
              },
            ),
            const SizedBox(height: 10),
            const Divider(color: Color(0xFFD2D2D2), thickness: 1),
            const SizedBox(height: 14),
            _SectionTitle(label: 'Map Type'),
            const SizedBox(height: 8),
            AppRadioSettingTile(
              label: 'Satellite',
              selected: state.mapType == MapDisplayType.satellite,
              onTap: () {
                context.read<GeneralUserMapFiltersBloc>().add(
                  const ChangeMapDisplayType(MapDisplayType.satellite),
                );
              },
            ),
            AppRadioSettingTile(
              label: 'Terrain',
              selected: state.mapType == MapDisplayType.terrain,
              onTap: () {
                context.read<GeneralUserMapFiltersBloc>().add(
                  const ChangeMapDisplayType(MapDisplayType.terrain),
                );
              },
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 128,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SingleZoomControl extends StatelessWidget {
  final VoidCallback onTap;

  const _SingleZoomControl({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 88,
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
      child: IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.add, size: 30, color: Color(0xFF2A2F34)),
      ),
    );
  }
}

class _AppSheetContainer extends StatelessWidget {
  final Widget child;

  const _AppSheetContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height * 0.77,
        maxHeight: MediaQuery.sizeOf(context).height * 0.84,
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

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: const Color(0xFF333333),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
