import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

enum BuoyStatus { active, offline, batteryLow }

class DummyBuoy extends Equatable {
  final String id;
  final LatLng position;
  final BuoyStatus status;
  final String battery;
  final String gps;
  final String signal;

  DummyBuoy({
    required Object? id,
    required this.position,
    required this.status,
    Object? battery = '—',
    Object? gps = '—',
    Object? signal = '—',
  })  : id = _safeLabel(id, fallback: 'DB - --'),
        battery = _safeLabel(battery, fallback: '—'),
        gps = _safeLabel(gps, fallback: '—'),
        signal = _safeLabel(signal, fallback: '—');

  @override
  List<Object> get props => [
        id,
        position.latitude,
        position.longitude,
        status,
        battery,
        gps,
        signal,
      ];
}

class DummyBuoyMapView extends StatelessWidget {
  final bool interactive;
  final bool showLabels;
  final LatLng initialCenter;
  final double initialZoom;
  final List<DummyBuoy> buoys;
  final MapController? mapController;
  final ValueChanged<DummyBuoy>? onBuoyTap;
  final DummyBuoy? selectedBuoy;
  final VoidCallback? onMapTap;

  DummyBuoyMapView({
    super.key,
    this.interactive = false,
    this.showLabels = false,
    this.initialCenter = const LatLng(37.7749, -122.4194),
    this.initialZoom = 10.3,
    List<DummyBuoy>? buoys,
    this.mapController,
    this.onBuoyTap,
    this.selectedBuoy,
    this.onMapTap,
  }) : buoys = buoys ?? defaultBuoys;

  static final List<DummyBuoy> defaultBuoys = [
    DummyBuoy(
      id: 'DB - 01',
      position: LatLng(37.7955, -122.4312),
      status: BuoyStatus.active,
      battery: '11.8 v',
      gps: '15°40\'51.0"N',
      signal: '79%',
    ),
    DummyBuoy(
      id: 'DB - 01',
      position: LatLng(37.7570, -122.4010),
      status: BuoyStatus.active,
      battery: '12.1 v',
      gps: '15°41\'02.1"N',
      signal: '82%',
    ),
    DummyBuoy(
      id: 'DB - 01',
      position: LatLng(37.7688, -122.3820),
      status: BuoyStatus.active,
      battery: '10.9 v',
      gps: '15°39\'48.5"N',
      signal: '71%',
    ),
    DummyBuoy(
      id: 'DB - 01',
      position: LatLng(37.7860, -122.3738),
      status: BuoyStatus.batteryLow,
      battery: '9.8 v',
      gps: '15°38\'22.0"N',
      signal: '54%',
    ),
    DummyBuoy(
      id: 'DB - 01',
      position: LatLng(37.7775, -122.3562),
      status: BuoyStatus.offline,
      battery: '—',
      gps: '—',
      signal: '—',
    ),
    DummyBuoy(
      id: 'DB - 01',
      position: LatLng(37.7414, -122.4098),
      status: BuoyStatus.active,
      battery: '11.2 v',
      gps: '15°40\'15.0"N',
      signal: '65%',
    ),
    DummyBuoy(
      id: 'DB - 01',
      position: LatLng(37.7244, -122.3875),
      status: BuoyStatus.active,
      battery: '12.4 v',
      gps: '15°42\'11.5"N',
      signal: '88%',
    ),
    DummyBuoy(
      id: 'DB - 01',
      position: LatLng(37.7128, -122.3518),
      status: BuoyStatus.active,
      battery: '11.0 v',
      gps: '15°37\'39.2"N',
      signal: '73%',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: initialZoom,
          onTap: (_, __) => onMapTap?.call(),
          interactionOptions: InteractionOptions(
            flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.azista.drifter_buoy',
          ),
          MarkerLayer(
            markers: buoys
                .map(
                  (buoy) => Marker(
                    point: buoy.position,
                    width: showLabels ? 88 : 48,
                    height: showLabels ? 98 : 62,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onBuoyTap == null ? null : () => onBuoyTap!(buoy),
                      child: Transform.scale(
                        scale: _isSameBuoy(selectedBuoy, buoy) ? 1.28 : 1,
                        alignment: Alignment.bottomCenter,
                        child: _BuoyMarker(
                          id: buoy.id,
                          status: buoy.status,
                          showLabel: showLabels,
                          isSelected: _isSameBuoy(selectedBuoy, buoy),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// Matches buoy ids ignoring spaces (e.g. `DB-01` vs `DB - 01`).
bool _isSameBuoy(DummyBuoy? selected, DummyBuoy buoy) {
  if (selected == null) {
    return false;
  }
  // IDs are not unique in our dummy data (many markers share the same `DB - 01`),
  // so we also compare the marker position to ensure only one buoy highlights.
  final idMatch =
      _normalizeBuoyId(selected.id) == _normalizeBuoyId(buoy.id);
  final latMatch = (selected.position.latitude - buoy.position.latitude).abs() <
      1e-9;
  final lonMatch =
      (selected.position.longitude - buoy.position.longitude).abs() < 1e-9;
  return idMatch && latMatch && lonMatch;
}

String _normalizeBuoyId(String id) =>
    id.toLowerCase().replaceAll(RegExp(r'\s+'), '');

String _safeLabel(Object? value, {required String fallback}) {
  final text = value?.toString() ?? '';
  final trimmed = text.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

class _BuoyMarker extends StatelessWidget {
  final String id;
  final BuoyStatus status;
  final bool showLabel;
  final bool isSelected;

  const _BuoyMarker({
    required this.id,
    required this.status,
    required this.showLabel,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
      BuoyStatus.active => const Color(0xFF4CAF50),
      BuoyStatus.offline => const Color(0xFFE74C3C),
      BuoyStatus.batteryLow => const Color(0xFFF4B400),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isSelected ? 10 : 8,
          height: isSelected ? 10 : 8,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(height: 2),
        Container(
          width: isSelected ? 24 : 22,
          height: isSelected ? 26 : 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD9D9D9)),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: isSelected ? 24 : 22,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
          ),
        ),
        if (showLabel || isSelected) ...[
          const SizedBox(height: 2),
          Text(
            id,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF1D2329),
              fontWeight: FontWeight.w700,
              fontSize: isSelected ? 15 : 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
