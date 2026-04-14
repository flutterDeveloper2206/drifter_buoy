import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Fits the map camera so all [points] are visible with [paddingPx] inset.
/// For a single point, uses [singlePointZoom] instead of bounds.
///
/// [expandLatitudeDeg] nudges the bounds north/south: custom markers are
/// anchored at the bottom, so graphics extend above the northernmost
/// [LatLng]; a small expansion avoids clipping at the top edge.
Future<void> fitGoogleMapToPoints({
  required GoogleMapController controller,
  required List<LatLng> points,
  double paddingPx = 48,
  double singlePointZoom = 11,
  double expandLatitudeDeg = 0,
}) async {
  if (points.isEmpty) {
    return;
  }
  if (points.length == 1) {
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(points.first, singlePointZoom),
    );
    return;
  }

  var minLat = points.first.latitude;
  var maxLat = points.first.latitude;
  var minLng = points.first.longitude;
  var maxLng = points.first.longitude;
  for (final p in points.skip(1)) {
    minLat = math.min(minLat, p.latitude);
    maxLat = math.max(maxLat, p.latitude);
    minLng = math.min(minLng, p.longitude);
    maxLng = math.max(maxLng, p.longitude);
  }

  const minSpan = 0.008;
  if (maxLat - minLat < minSpan) {
    final mid = (maxLat + minLat) / 2;
    minLat = mid - minSpan / 2;
    maxLat = mid + minSpan / 2;
  }
  if (maxLng - minLng < minSpan) {
    final mid = (maxLng + minLng) / 2;
    minLng = mid - minSpan / 2;
    maxLng = mid + minSpan / 2;
  }

  final north = maxLat + expandLatitudeDeg;
  final south = minLat - expandLatitudeDeg;
  final bounds = LatLngBounds(
    southwest: LatLng(south, minLng),
    northeast: LatLng(north, maxLng),
  );

  await controller.animateCamera(
    CameraUpdate.newLatLngBounds(bounds, paddingPx),
  );
}
