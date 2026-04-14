import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrajectoryBuoyPoint extends Equatable {
  final LatLng position;
  final BuoyStatus status;
  final String label;
  final String? secondaryLabel;
  final String gpsLabel;
  final String timestampLabel;
  final String batteryLabel;

  const TrajectoryBuoyPoint({
    required this.position,
    required this.status,
    required this.label,
    this.secondaryLabel,
    required this.gpsLabel,
    required this.timestampLabel,
    required this.batteryLabel,
  });

  TrajectoryBuoyPoint copyWith({
    LatLng? position,
    BuoyStatus? status,
    String? label,
    String? secondaryLabel,
    String? gpsLabel,
    String? timestampLabel,
    String? batteryLabel,
  }) {
    return TrajectoryBuoyPoint(
      position: position ?? this.position,
      status: status ?? this.status,
      label: label ?? this.label,
      secondaryLabel: secondaryLabel ?? this.secondaryLabel,
      gpsLabel: gpsLabel ?? this.gpsLabel,
      timestampLabel: timestampLabel ?? this.timestampLabel,
      batteryLabel: batteryLabel ?? this.batteryLabel,
    );
  }

  @override
  List<Object> get props => [
    position.latitude,
    position.longitude,
    status,
    label,
    secondaryLabel ?? '',
    gpsLabel,
    timestampLabel,
    batteryLabel,
  ];
}

class DummyTrajectoryLiveMapView extends StatelessWidget {
  final MapController? mapController;
  final List<TrajectoryBuoyPoint> points;
  final bool interactive;
  final double initialZoom;
  final LatLng initialCenter;
  final bool showLabels;
  final bool showSecondaryLabels;

  const DummyTrajectoryLiveMapView({
    super.key,
    this.mapController,
    required this.points,
    this.interactive = true,
    this.initialZoom = 10.3,
    this.initialCenter = const LatLng(37.7749, -122.4194),
    this.showLabels = true,
    this.showSecondaryLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final polylinePoints = points.map((point) => point.position).toList();

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.azista.drifter_buoy',
        ),
        if (polylinePoints.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: polylinePoints,
                strokeWidth: 4,
                color: const Color(0xFF1675C7),
                pattern: StrokePattern.dashed(segments: const [8, 8]),
              ),
            ],
          ),
        MarkerLayer(
          markers: points
              .map(
                (point) => Marker(
                  point: point.position,
                  width: showLabels ? 118 : 28,
                  height: 74,
                  child: _TrajectoryBuoyMapMarker(
                    point: point,
                    showLabels: showLabels,
                    showSecondaryLabels: showSecondaryLabels,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _TrajectoryBuoyMapMarker extends StatelessWidget {
  final TrajectoryBuoyPoint point;
  final bool showLabels;
  final bool showSecondaryLabels;

  const _TrajectoryBuoyMapMarker({
    required this.point,
    required this.showLabels,
    required this.showSecondaryLabels,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (point.status) {
      BuoyStatus.active => const Color(0xFF4CAF50),
      BuoyStatus.offline => const Color(0xFFE74C3C),
      BuoyStatus.batteryLow => const Color(0xFFF4B400),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 20,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD9D9D9)),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 20,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showLabels) ...[
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              _markerLabel(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF3F4B54),
                fontWeight: FontWeight.w700,
                fontSize: 10,
                height: 1.18,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _markerLabel() {
    if (!showSecondaryLabels || point.secondaryLabel == null) {
      return point.label;
    }

    return '${point.label}\n${point.secondaryLabel!}';
  }
}
