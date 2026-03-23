import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/core/utils/widgets/app_map_legend_item.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map/general_user_map_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map/general_user_map_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map/general_user_map_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class GeneralUserMapPage extends StatefulWidget {
  const GeneralUserMapPage({super.key});

  @override
  State<GeneralUserMapPage> createState() => _GeneralUserMapPageState();
}

class _GeneralUserMapPageState extends State<GeneralUserMapPage> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: BlocListener<GeneralUserMapBloc, GeneralUserMapState>(
        listenWhen: (previous, current) {
          return previous.zoom != current.zoom &&
              current.status == GeneralUserMapStatus.loaded;
        },
        listener: (_, state) {
          final currentCenter = _safeMapCenter();
          _mapController.move(currentCenter, state.zoom);
        },
        child: BlocBuilder<GeneralUserMapBloc, GeneralUserMapState>(
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
                          onTap: () => context.go(AppRoutes.dashboardPath),
                          icon: Icons.arrow_back,
                        ),
                        const Spacer(),
                        AppIconCircleButton(
                          onTap: () => context.push(AppRoutes.mapSearchPath),
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
                        ? () => context.read<GeneralUserMapBloc>().add(
                            const ZoomInMap(),
                          )
                        : null,
                    onZoomOut: state.canZoomOut
                        ? () => context.read<GeneralUserMapBloc>().add(
                            const ZoomOutMap(),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  left: 40,
                  right: 40,
                  bottom: state.isFilterPanelExpanded ? 220 : 124,
                  child: _MapLegendCard(
                    isActiveVisible: state.showActive,
                    isOfflineVisible: state.showOffline,
                    isBatteryVisible: state.showBatteryLow,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _FilterPanel(
                    state: state,
                    titleStyle: textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF2D3238),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapLayer(BuildContext context, GeneralUserMapState state) {
    if (state.status == GeneralUserMapStatus.loading ||
        state.status == GeneralUserMapStatus.initial) {
      return const AppLoader();
    }

    if (state.status == GeneralUserMapStatus.error) {
      return AppErrorView(
        message: state.message,
        onRetry: () {
          context.read<GeneralUserMapBloc>().add(const LoadGeneralUserMap());
        },
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: DummyBuoyMapView(
            mapController: _mapController,
            interactive: true,
            showLabels: true,
            initialZoom: state.zoom,
            buoys: state.filteredBuoys,
            onBuoyTap: (_) => context.go(AppRoutes.mapBuoyDetailsPath),
          ),
        ),
        if (state.filteredBuoys.isEmpty)
          Align(
            alignment: const Alignment(0, 0.56),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'No buoys for selected filters.',
                style: TextStyle(
                  color: Color(0xFF2E343A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
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
  final bool isActiveVisible;
  final bool isOfflineVisible;
  final bool isBatteryVisible;

  const _MapLegendCard({
    required this.isActiveVisible,
    required this.isOfflineVisible,
    required this.isBatteryVisible,
  });

  @override
  Widget build(BuildContext context) {
    final disabledColor = Colors.grey.shade400;

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
            color: isActiveVisible ? const Color(0xFF4CAF50) : disabledColor,
          ),
          AppMapLegendItem(
            icon: Icons.wifi_off,
            label: 'Offline',
            color: isOfflineVisible ? const Color(0xFFE74C3C) : disabledColor,
          ),
          AppMapLegendItem(
            icon: Icons.battery_1_bar,
            label: 'Battery Low',
            color: isBatteryVisible ? const Color(0xFF4F95DA) : disabledColor,
          ),
        ],
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  final GeneralUserMapState state;
  final TextStyle? titleStyle;

  const _FilterPanel({required this.state, this.titleStyle});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
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
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                context.go(AppRoutes.mapFiltersPath);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Icon(
                  state.isFilterPanelExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  size: 22,
                  color: const Color(0xFF2E343A),
                ),
              ),
            ),
            Text('Toggles and Filters', style: titleStyle),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: state.isFilterPanelExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(height: 18),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 8),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusFilterChip(
                          icon: Icons.wifi,
                          label: 'Active',
                          selected: state.showActive,
                          color: const Color(0xFF4CAF50),
                          onTap: () => context.read<GeneralUserMapBloc>().add(
                            const ToggleBuoyStatusFilter(BuoyStatus.active),
                          ),
                        ),
                        _StatusFilterChip(
                          icon: Icons.wifi_off,
                          label: 'Offline',
                          selected: state.showOffline,
                          color: const Color(0xFFE74C3C),
                          onTap: () => context.read<GeneralUserMapBloc>().add(
                            const ToggleBuoyStatusFilter(BuoyStatus.offline),
                          ),
                        ),
                        _StatusFilterChip(
                          icon: Icons.battery_1_bar,
                          label: 'Battery Low',
                          selected: state.showBatteryLow,
                          color: const Color(0xFF4F95DA),
                          onTap: () => context.read<GeneralUserMapBloc>().add(
                            const ToggleBuoyStatusFilter(BuoyStatus.batteryLow),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.read<GeneralUserMapBloc>().add(
                            const ResetBuoyFilters(),
                          );
                        },
                        child: const Text('Reset filters'),
                      ),
                    ),
                  ],
                ),
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

class _StatusFilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Icon(icon, size: 16, color: selected ? Colors.white : color),
      label: Text(label),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF2E343A),
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: selected ? color : const Color(0xFFD1D5DA)),
      backgroundColor: Colors.white,
      selectedColor: color,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    );
  }
}
