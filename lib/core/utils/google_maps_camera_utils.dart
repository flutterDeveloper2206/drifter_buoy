import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Centroid and a zoom level that roughly frames all [points].
///
/// Used for [GoogleMap.initialCameraPosition] so the map starts focused on
/// buoy markers before the controller is ready.
/// Returns null when [points] is empty — callers must not fall back to a fixed
/// country; show a placeholder or wait for real buoy coordinates instead.
({LatLng target, double zoom})? cameraTargetAndZoomForPoints(
  List<LatLng> points, {
  double singlePointZoom = 13.0,
}) {
  if (points.isEmpty) {
    return null;
  }
  if (points.length == 1) {
    return (target: points.first, zoom: singlePointZoom);
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

  final target = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);

  final latSpan = (maxLat - minLat).abs();
  final lngSpan = (maxLng - minLng).abs();
  final span = latSpan > lngSpan ? latSpan : lngSpan;

  final zoom = switch (span) {
    <= 0.01 => 13.2,
    <= 0.03 => 12.3,
    <= 0.06 => 11.6,
    <= 0.12 => 10.8,
    <= 0.22 => 10.0,
    _ => 9.4,
  };

  return (target: target, zoom: zoom);
}

bool isValidMapCoordinate(double latitude, double longitude) {
  if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
    return false;
  }
  if (latitude.abs() < 0.0001 && longitude.abs() < 0.0001) {
    return false;
  }
  return true;
}

/// Fits the map camera so all [points] are visible with [paddingPx] inset.
/// For a single point, uses [singlePointZoom] instead of bounds.
///
/// [expandLatitudeDeg] nudges the bounds north/south: custom markers are
/// anchored at the bottom, so graphics extend above the northernmost
/// [LatLng]; a small expansion avoids clipping at the top edge.
///
/// Set [animate] to false for the first load fit so markers are in frame
/// immediately without a visible camera transition.
Future<void> fitGoogleMapToPoints({
  required GoogleMapController controller,
  required List<LatLng> points,
  double paddingPx = 48,
  double singlePointZoom = 11,
  double expandLatitudeDeg = 0,
  bool animate = true,
}) async {
  if (points.isEmpty) {
    return;
  }

  Future<void> applyUpdate(CameraUpdate update) {
    return animate
        ? controller.animateCamera(update)
        : controller.moveCamera(update);
  }

  if (points.length == 1) {
    await applyUpdate(
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

  try {
    await applyUpdate(CameraUpdate.newLatLngBounds(bounds, paddingPx));
  } on Object {
    final camera = cameraTargetAndZoomForPoints(
      points,
      singlePointZoom: singlePointZoom,
    );
    if (camera == null) {
      return;
    }
    await applyUpdate(
      CameraUpdate.newLatLngZoom(
        camera.target,
        camera.zoom.clamp(3, 17).toDouble(),
      ),
    );
  }
}
