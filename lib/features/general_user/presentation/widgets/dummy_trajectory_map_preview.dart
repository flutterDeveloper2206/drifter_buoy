import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DummyTrajectoryMapPreview extends StatelessWidget {
  final List<LatLng> trajectoryPoints;
  final DummyBuoy buoy;

  const DummyTrajectoryMapPreview({
    super.key,
    required this.trajectoryPoints,
    required this.buoy,
  });

  @override
  Widget build(BuildContext context) {
    final center = trajectoryPoints.isNotEmpty
        ? trajectoryPoints[trajectoryPoints.length ~/ 2]
        : buoy.position;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 10.9,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.none,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.azista.drifter_buoy',
          ),
          if (trajectoryPoints.length > 1)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: trajectoryPoints,
                  strokeWidth: 4,
                  color: const Color(0xFF1675C7),
                  pattern: StrokePattern.dashed(segments: const [8, 8]),
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              Marker(
                point: buoy.position,
                width: 72,
                height: 82,
                child: _PreviewBuoyMarker(id: buoy.id, status: buoy.status),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewBuoyMarker extends StatelessWidget {
  final String id;
  final BuoyStatus status;

  const _PreviewBuoyMarker({required this.id, required this.status});

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
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(height: 2),
        Container(
          width: 24,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD9D9D9)),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 24,
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
        const SizedBox(height: 2),
        Text(
          id,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: const Color(0xFF1D2329),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
