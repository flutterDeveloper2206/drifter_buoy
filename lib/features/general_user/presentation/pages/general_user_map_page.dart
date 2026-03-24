import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/core/utils/widgets/app_map_legend_item.dart';
import 'package:drifter_buoy/core/utils/widgets/app_settings_tiles.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map/general_user_map_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map/general_user_map_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map/general_user_map_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class GeneralUserMapPage extends StatefulWidget {
  const GeneralUserMapPage({super.key, this.initialSearchOpen = false});

  final bool initialSearchOpen;

  @override
  State<GeneralUserMapPage> createState() => _GeneralUserMapPageState();
}

class _GeneralUserMapPageState extends State<GeneralUserMapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late bool _mapSearchOpen;

  @override
  void initState() {
    super.initState();
    _mapSearchOpen = widget.initialSearchOpen;
    if (_mapSearchOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _closeMapSearch() {
    setState(() {
      _mapSearchOpen = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _applySearchFromField() {
    if (!mounted) {
      return;
    }
    final mapState = context.read<GeneralUserMapBloc>().state;
    setState(() {});
    final selected = _searchSelectedBuoyForState(mapState);
    if (selected != null && mapState.status == GeneralUserMapStatus.loaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(selected.position, mapState.zoom);
        }
      });
    }
  }

  DummyBuoy? _searchSelectedBuoyForState(GeneralUserMapState state) {
    if (!_mapSearchOpen) {
      return null;
    }
    final q = _searchController.text.trim();
    if (q.isEmpty) {
      return null;
    }
    final matches = _filterMapBuoysByQuery(state.filteredBuoys, q);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              fit: StackFit.expand,
              children: [
                Positioned.fill(child: _buildMapLayer(context, state)),
                if (!_mapSearchOpen)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        MediaQuery.paddingOf(context).top + 10,
                        16,
                        0,
                      ),
                      child: Row(
                        children: [
                          AppIconCircleButton(
                            onTap: () => context.go(AppRoutes.dashboardPath),
                            icon: Icons.arrow_back,
                          ),
                          const Spacer(),
                          AppIconCircleButton(
                            onTap: () {
                              setState(() {
                                _mapSearchOpen = true;
                              });
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  _searchFocusNode.requestFocus();
                                }
                              });
                            },
                            icon: Icons.search,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_mapSearchOpen)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        14,
                        MediaQuery.paddingOf(context).top + 12,
                        14,
                        0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppIconCircleButton(
                            onTap: _closeMapSearch,
                            icon: Icons.close,
                            iconSize: 26,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _MapSearchInputCard(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: (_) => _applySearchFromField(),
                              onSearchTap: () {
                                _applySearchFromField();
                                FocusScope.of(context).unfocus();
                              },
                            ),
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
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DummyBuoyMapView(
            mapController: _mapController,
            interactive: true,
            showLabels: true,
            initialZoom: state.zoom,
            buoys: state.filteredBuoys,
            selectedBuoy: _searchSelectedBuoyForState(state),
            onBuoyTap: (buoy) {
              if (_mapSearchOpen) {
                _searchController.text = buoy.id;
                _searchController.selection = TextSelection.collapsed(
                  offset: buoy.id.length,
                );
                _applySearchFromField();
              } else {
                context.go(AppRoutes.mapBuoyDetailsPath);
              }
            },
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

String _normalizeMapSearchId(String id) =>
    id.toLowerCase().replaceAll(RegExp(r'\s+'), '');

List<DummyBuoy> _filterMapBuoysByQuery(List<DummyBuoy> source, String query) {
  final raw = query.trim();
  if (raw.isEmpty) {
    return source;
  }
  final nq = _normalizeMapSearchId(raw);
  return source
      .where((b) => _normalizeMapSearchId(b.id).contains(nq))
      .toList(growable: false);
}

class _MapSearchInputCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearchTap;

  const _MapSearchInputCard({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.fromLTRB(16, 0, 5, 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF31363A),
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search with Buoy ID',
                hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF9A9FA4),
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSearchTap,
              customBorder: const CircleBorder(),
              child: Ink(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF007BC2),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
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
  final TextStyle? titleStyle;

  const _FilterPanel({this.titleStyle});

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
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  barrierColor: const Color(0x66000000),
                  backgroundColor: Colors.transparent,
                  builder: (_) {
                    return BlocProvider<GeneralUserMapFiltersBloc>(
                      create: (_) =>
                          sl<GeneralUserMapFiltersBloc>()
                            ..add(const LoadGeneralUserMapFilters()),
                      child: const _MapFilterSettingsSheet(),
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Icon(
                  Icons.keyboard_arrow_up,
                  size: 22,
                  color: const Color(0xFF2E343A),
                ),
              ),
            ),
            Text('Toggles and Filters', style: titleStyle),
            const SizedBox(height: 18),
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

class _MapFilterSettingsSheet extends StatelessWidget {
  const _MapFilterSettingsSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeneralUserMapFiltersBloc, GeneralUserMapFiltersState>(
      builder: (context, state) {
        if (state.status == GeneralUserMapFiltersStatus.loading ||
            state.status == GeneralUserMapFiltersStatus.initial) {
          return _MapFiltersBottomSheetContainer(
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: AppLoader(),
            ),
          );
        }

        if (state.status == GeneralUserMapFiltersStatus.error) {
          return _MapFiltersBottomSheetContainer(
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

        return _MapFiltersBottomSheetContainer(
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF2D2D2D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(color: Color(0xFFD2D2D2), thickness: 1),
                const SizedBox(height: 14),
                const _SheetSectionTitle(label: 'Toggles'),
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
                const _SheetSectionTitle(label: 'Filters'),
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
                  selected: state.locationZoneEnabled,
                  onTap: () {
                    context.read<GeneralUserMapFiltersBloc>().add(
                      const ToggleLocationZoneFilter(),
                    );
                  },
                ),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFD2D2D2), thickness: 1),
                const SizedBox(height: 14),
                const _SheetSectionTitle(label: 'Map Type'),
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapFiltersBottomSheetContainer extends StatelessWidget {
  final Widget child;

  const _MapFiltersBottomSheetContainer({required this.child});

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

class _SheetSectionTitle extends StatelessWidget {
  final String label;

  const _SheetSectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: const Color(0xFF333333),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
