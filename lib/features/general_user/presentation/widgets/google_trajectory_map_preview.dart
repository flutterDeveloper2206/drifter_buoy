import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:drifter_buoy/core/utils/google_maps_camera_utils.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as ll;

/// Non-interactive trajectory preview using Google Maps.
///
/// Shows:
/// - buoy custom marker (green/red/yellow png) + buoy id label
/// - dashed trajectory polyline
/// - faded end marker for the latest point
class GoogleTrajectoryMapPreview extends StatefulWidget {
  const GoogleTrajectoryMapPreview({
    super.key,
    required this.trajectoryPoints,
    required this.buoy,
    this.boundsPaddingPx = 96,
    this.fitBoundsLatitudeExpansionDeg = 0.006,
    this.showEmbeddedZoomControls = true,
    this.showFitAllControl = true,
  });

  final List<ll.LatLng> trajectoryPoints;
  final DummyBuoy buoy;
  final double boundsPaddingPx;
  final double fitBoundsLatitudeExpansionDeg;
  final bool showEmbeddedZoomControls;
  final bool showFitAllControl;

  @override
  State<GoogleTrajectoryMapPreview> createState() =>
      _GoogleTrajectoryMapPreviewState();
}

class _GoogleTrajectoryMapPreviewState
    extends State<GoogleTrajectoryMapPreview> {
  GoogleMapController? _controller;
  bool _didFit = false;

  BitmapDescriptor? _activeIcon;
  BitmapDescriptor? _offlineIcon;
  BitmapDescriptor? _batteryLowIcon;
  BitmapDescriptor? _fadedIcon;
  BitmapDescriptor? _labeledBuoyIcon;

  ui.Image? _greenImage;
  ui.Image? _redImage;
  ui.Image? _yellowImage;

  static const _assetGreen = 'assets/images/green.png';
  static const _assetRed = 'assets/images/red.png';
  static const _assetYellow = 'assets/images/yellow.png';
  static const _trajectoryPreviewMapStyle = '''
[
  {
    "featureType": "all",
    "elementType": "labels",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "poi",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "transit",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "administrative",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#B4D77A"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#7CC5D8"}]
  }
]
''';

  @override
  void initState() {
    super.initState();
    _scheduleLoadIcons();
  }

  @override
  void didUpdateWidget(covariant GoogleTrajectoryMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final buoyChanged = oldWidget.buoy != widget.buoy;
    final pathChanged = oldWidget.trajectoryPoints != widget.trajectoryPoints;
    if (buoyChanged) {
      _labeledBuoyIcon = null;
      _scheduleLoadIcons();
    }
    if (pathChanged) {
      _didFit = false;
      _scheduleFit();
    }
  }

  void _scheduleLoadIcons() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _loadIcons();
    });
  }

  Future<void> _loadIcons() async {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cfg = ImageConfiguration(devicePixelRatio: dpr);
    try {
      _activeIcon ??= await BitmapDescriptor.asset(
        cfg,
        _assetGreen,
        width: 52,
        height: 52,
      );
      _offlineIcon ??= await BitmapDescriptor.asset(
        cfg,
        _assetRed,
        width: 52,
        height: 52,
      );
      _batteryLowIcon ??= await BitmapDescriptor.asset(
        cfg,
        _assetYellow,
        width: 52,
        height: 52,
      );
      _fadedIcon ??= await BitmapDescriptor.asset(
        cfg,
        _assetGreen,
        width: 30,
        height: 30,
      );

      _greenImage ??= await _loadUiImage(_assetGreen);
      _redImage ??= await _loadUiImage(_assetRed);
      _yellowImage ??= await _loadUiImage(_assetYellow);

      _labeledBuoyIcon ??= await _buildLabeledMainMarker();
    } on Object {
      // Fallback to default marker if image loading fails.
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<ui.Image> _loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<BitmapDescriptor?> _buildLabeledMainMarker() async {
    final base = switch (widget.buoy.status) {
      BuoyStatus.active => _greenImage,
      BuoyStatus.offline => _redImage,
      BuoyStatus.batteryLow => _yellowImage,
    };
    if (base == null) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const pinW = 44.0;
    const pinH = 60.0;
    const labelTopGap = 2.0;
    const textStyle = TextStyle(
      color: Color(0xFF1C2227),
      fontWeight: FontWeight.w800,
      fontSize: 11.5,
      letterSpacing: 0.2,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: widget.buoy.id, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final width = (textPainter.width + 12) > pinW
        ? (textPainter.width + 12)
        : pinW;
    final height = pinH + labelTopGap + textPainter.height + 4;
    final size = Size(width, height);

    final pinRect = Rect.fromLTWH((width - pinW) / 2, 0, pinW, pinH);
    paintImage(
      canvas: canvas,
      rect: pinRect,
      image: base,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    final labelLeft = (width - textPainter.width) / 2;
    final labelTop = pinH + labelTopGap;
    final shadowPainter = TextPainter(
      text: TextSpan(
        text: widget.buoy.id,
        style: textStyle.copyWith(color: Colors.white.withValues(alpha: 0.9)),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    shadowPainter.paint(canvas, Offset(labelLeft + 0.8, labelTop + 0.8));
    textPainter.paint(canvas, Offset(labelLeft, labelTop));

    final image = await recorder.endRecording().toImage(
      size.width.ceil(),
      size.height.ceil(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return null;
    return BitmapDescriptor.bytes(bytes.buffer.asUint8List());
  }

  BitmapDescriptor _iconForStatus(BuoyStatus status) {
    return switch (status) {
      BuoyStatus.active =>
        _activeIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      BuoyStatus.offline =>
        _offlineIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      BuoyStatus.batteryLow =>
        _batteryLowIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    };
  }

  Set<Marker> _buildMarkers() {
    final buoyPos = LatLng(
      widget.buoy.position.latitude,
      widget.buoy.position.longitude,
    );
    final markers = <Marker>{
      Marker(
        markerId: MarkerId('main_${widget.buoy.id}'),
        position: buoyPos,
        zIndexInt: 3,
        icon: _labeledBuoyIcon ?? _iconForStatus(widget.buoy.status),
      ),
    };

    if (widget.trajectoryPoints.length > 1) {
      final end = widget.trajectoryPoints.last;
      markers.add(
        Marker(
          markerId: const MarkerId('trajectory_end'),
          position: LatLng(end.latitude, end.longitude),
          zIndexInt: 1,
          alpha: 0.52,
          icon: _fadedIcon ?? _iconForStatus(widget.buoy.status),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (widget.trajectoryPoints.length < 2) return const {};
    final points = _buildCurvedTrajectoryPoints(
      widget.trajectoryPoints
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList(growable: false),
    );
    return {
      Polyline(
        polylineId: const PolylineId('trajectory_preview'),
        points: points,
        width: 5,
        color: const Color(0xFF1E5FBF),
        geodesic: true,
        patterns: [PatternItem.dash(16), PatternItem.gap(10)],
      ),
    };
  }

  List<LatLng> _buildCurvedTrajectoryPoints(List<LatLng> raw) {
    if (raw.length < 2) {
      return raw;
    }
    if (raw.length == 2) {
      return _quadraticCurveForTwoPoints(raw.first, raw.last);
    }
    const samplesPerSegment = 8;
    final smooth = <LatLng>[raw.first];

    for (int i = 0; i < raw.length - 1; i++) {
      final p0 = i == 0 ? raw[i] : raw[i - 1];
      final p1 = raw[i];
      final p2 = raw[i + 1];
      final p3 = i + 2 < raw.length ? raw[i + 2] : raw[i + 1];

      for (int j = 1; j <= samplesPerSegment; j++) {
        final t = j / samplesPerSegment;
        final t2 = t * t;
        final t3 = t2 * t;

        final lat =
            0.5 *
            ((2 * p1.latitude) +
                (-p0.latitude + p2.latitude) * t +
                (2 * p0.latitude -
                        5 * p1.latitude +
                        4 * p2.latitude -
                        p3.latitude) *
                    t2 +
                (-p0.latitude +
                        3 * p1.latitude -
                        3 * p2.latitude +
                        p3.latitude) *
                    t3);
        final lng =
            0.5 *
            ((2 * p1.longitude) +
                (-p0.longitude + p2.longitude) * t +
                (2 * p0.longitude -
                        5 * p1.longitude +
                        4 * p2.longitude -
                        p3.longitude) *
                    t2 +
                (-p0.longitude +
                        3 * p1.longitude -
                        3 * p2.longitude +
                        p3.longitude) *
                    t3);
        smooth.add(LatLng(lat, lng));
      }
    }
    return smooth;
  }

  List<LatLng> _quadraticCurveForTwoPoints(LatLng start, LatLng end) {
    const samples = 24;
    final midLat = (start.latitude + end.latitude) / 2;
    final midLng = (start.longitude + end.longitude) / 2;

    final dLat = end.latitude - start.latitude;
    final dLng = end.longitude - start.longitude;
    final distance = math.sqrt(dLat * dLat + dLng * dLng);
    final curveOffset = (distance * 0.35).clamp(0.0015, 0.012);

    // Perpendicular control-point offset to make a smooth bow-like curve.
    final norm = (distance == 0) ? 1.0 : distance;
    final perpLat = -dLng / norm;
    final perpLng = dLat / norm;
    final control = LatLng(
      midLat + perpLat * curveOffset,
      midLng + perpLng * curveOffset,
    );

    final curved = <LatLng>[start];
    for (int i = 1; i <= samples; i++) {
      final t = i / samples;
      final oneMinusT = 1 - t;
      final lat =
          oneMinusT * oneMinusT * start.latitude +
          2 * oneMinusT * t * control.latitude +
          t * t * end.latitude;
      final lng =
          oneMinusT * oneMinusT * start.longitude +
          2 * oneMinusT * t * control.longitude +
          t * t * end.longitude;
      curved.add(LatLng(lat, lng));
    }
    return curved;
  }

  List<LatLng> _cameraPoints() {
    final raw = widget.trajectoryPoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList(growable: false);
    final pts = _buildCurvedTrajectoryPoints(raw).toList(growable: true);
    final buoyPos = LatLng(
      widget.buoy.position.latitude,
      widget.buoy.position.longitude,
    );
    final hasNearBuoy = raw.any(
      (p) =>
          (p.latitude - buoyPos.latitude).abs() < 0.00001 &&
          (p.longitude - buoyPos.longitude).abs() < 0.00001,
    );
    if (!hasNearBuoy) {
      pts.add(buoyPos);
    }
    return pts;
  }

  void _scheduleFit() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _fit();
    });
  }

  Future<void> _fit() async {
    final c = _controller;
    if (c == null || _didFit) return;
    final points = _cameraPoints();
    if (points.isEmpty) return;
    _didFit = true;
    try {
      final rawCount = widget.trajectoryPoints.length;
      final isTwoPointTrajectory = widget.trajectoryPoints.length == 2;
      final isSinglePointTrajectory = rawCount <= 1;
      await fitGoogleMapToPoints(
        controller: c,
        points: points,
        // Keep preview more "map-like" (similar to reference) for sparse data.
        paddingPx: isTwoPointTrajectory
            ? widget.boundsPaddingPx + 12
            : widget.boundsPaddingPx,
        singlePointZoom: isSinglePointTrajectory
            ? 10.2
            : (isTwoPointTrajectory ? 11.2 : 12.1),
        expandLatitudeDeg: isSinglePointTrajectory
            ? widget.fitBoundsLatitudeExpansionDeg * 1.35
            : (isTwoPointTrajectory
                  ? widget.fitBoundsLatitudeExpansionDeg * 1.2
                  : widget.fitBoundsLatitudeExpansionDeg),
      );
    } on Object {
      _didFit = false;
    }
  }

  Future<void> _nudgeZoom(double delta) async {
    final c = _controller;
    if (c == null) {
      return;
    }
    try {
      await c.animateCamera(CameraUpdate.zoomBy(delta));
    } on Object catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final initial = LatLng(
      widget.buoy.position.latitude,
      widget.buoy.position.longitude,
    );

    final map = GoogleMap(
      initialCameraPosition: CameraPosition(target: initial, zoom: 10.8),
      mapType: MapType.normal,
      style: _trajectoryPreviewMapStyle,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      tiltGesturesEnabled: false,
      minMaxZoomPreference: const MinMaxZoomPreference(14, 21),
      markers: _buildMarkers(),
      polylines: _buildPolylines(),
      onMapCreated: (controller) {
        _controller = controller;
        _didFit = false;
        _scheduleFit();
      },
    );

    return IgnorePointer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            map,
            // if (widget.showEmbeddedZoomControls || widget.showFitAllControl)
            //   Positioned(
            //     right: 6,
            //     top: 6,
            //     child: Material(
            //       color: Colors.white.withValues(alpha: 0.92),
            //       elevation: 2,
            //       borderRadius: BorderRadius.circular(10),
            //       child: Column(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           if (widget.showEmbeddedZoomControls) ...[
            //             IconButton(
            //               visualDensity: VisualDensity.compact,
            //               tooltip: 'Zoom in',
            //               onPressed: () => _nudgeZoom(1),
            //               icon: const Icon(Icons.add, size: 20),
            //               color: const Color(0xFF23282D),
            //             ),
            //             const SizedBox(height: 2),
            //             IconButton(
            //               visualDensity: VisualDensity.compact,
            //               tooltip: 'Zoom out',
            //               onPressed: () => _nudgeZoom(-1),
            //               icon: const Icon(Icons.remove, size: 20),
            //               color: const Color(0xFF23282D),
            //             ),
            //           ],
            //           if (widget.showFitAllControl) ...[
            //             if (widget.showEmbeddedZoomControls)
            //               const SizedBox(height: 4),
            //             IconButton(
            //               visualDensity: VisualDensity.compact,
            //               tooltip: 'Fit trajectory',
            //               onPressed: () {
            //                 _didFit = false;
            //                 _scheduleFit();
            //               },
            //               icon: const Icon(Icons.my_location, size: 20),
            //               color: const Color(0xFF23282D),
            //             ),
            //           ],
            //         ],
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
