import 'dart:ui' as ui;

import 'package:drifter_buoy/core/utils/google_maps_camera_utils.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_trajectory_live_map_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleTrajectoryLiveMapView extends StatefulWidget {
  const GoogleTrajectoryLiveMapView({
    super.key,
    required this.points,
    required this.initialZoom,
    this.showGpsCoordinates = false,
    this.showTimestamps = false,
    this.showBatteryLogs = false,
    this.interactive = true,
    this.onControllerReady,
    this.onMapZoomChanged,
  });

  final List<TrajectoryBuoyPoint> points;
  final double initialZoom;
  final bool showGpsCoordinates;
  final bool showTimestamps;
  final bool showBatteryLogs;
  final bool interactive;
  final ValueChanged<GoogleMapController>? onControllerReady;

  /// Called after the camera is idle (pinch, pan, fit bounds, +/-) with the
  /// current zoom level so UI state can track limits.
  final ValueChanged<double>? onMapZoomChanged;

  @override
  State<GoogleTrajectoryLiveMapView> createState() =>
      _GoogleTrajectoryLiveMapViewState();
}

class _GoogleTrajectoryLiveMapViewState
    extends State<GoogleTrajectoryLiveMapView> {
  GoogleMapController? _controller;
  bool _didFit = false;
  bool _loading = false;
  final Map<String, BitmapDescriptor> _markerIconCache = {};

  ui.Image? _imgGreen;
  ui.Image? _imgRed;
  ui.Image? _imgYellow;

  static const _assetGreen = 'assets/images/green.png';
  static const _assetRed = 'assets/images/red.png';
  static const _assetYellow = 'assets/images/yellow.png';

  static const _mapStyle = '''
[
  {"featureType":"all","elementType":"labels","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"administrative","stylers":[{"visibility":"off"}]},
  {"featureType":"landscape.natural","elementType":"geometry.fill","stylers":[{"color":"#B4D77A"}]},
  {"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#7CC5D8"}]}
]
''';

  @override
  void initState() {
    super.initState();
    _schedulePrimeIcons();
  }

  @override
  void didUpdateWidget(covariant GoogleTrajectoryLiveMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pathChanged = !_sameTrajectoryPath(oldWidget.points, widget.points);
    final labelsChanged =
        oldWidget.showTimestamps != widget.showTimestamps ||
        oldWidget.showGpsCoordinates != widget.showGpsCoordinates ||
        oldWidget.showBatteryLogs != widget.showBatteryLogs;

    if (labelsChanged) {
      _markerIconCache.clear();
    }
    if (labelsChanged || pathChanged) {
      _schedulePrimeIcons();
    }
    if (pathChanged) {
      _didFit = false;
      _scheduleFit();
    }
  }

  bool _sameTrajectoryPath(
    List<TrajectoryBuoyPoint> a,
    List<TrajectoryBuoyPoint> b,
  ) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    const eps = 1e-7;
    for (var i = 0; i < a.length; i++) {
      if ((a[i].position.latitude - b[i].position.latitude).abs() > eps) {
        return false;
      }
      if ((a[i].position.longitude - b[i].position.longitude).abs() > eps) {
        return false;
      }
    }
    return true;
  }

  void _schedulePrimeIcons() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _primeIcons();
    });
  }

  Future<void> _primeIcons() async {
    if (_loading) return;
    _loading = true;
    try {
      _imgGreen ??= await _loadUiImage(_assetGreen);
      _imgRed ??= await _loadUiImage(_assetRed);
      _imgYellow ??= await _loadUiImage(_assetYellow);

      for (final p in widget.points) {
        await _ensureMarkerIcon(p);
      }
    } on Object {
      // ignore and fallback to default markers
    } finally {
      _loading = false;
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

  String _cacheKey(TrajectoryBuoyPoint p) {
    return '${p.status.name}|${p.gpsLabel}|${p.timestampLabel}|${p.batteryLabel}|${widget.showGpsCoordinates}|${widget.showTimestamps}|${widget.showBatteryLogs}';
  }

  Future<void> _ensureMarkerIcon(TrajectoryBuoyPoint p) async {
    final key = _cacheKey(p);
    if (_markerIconCache.containsKey(key)) return;
    if (_imgGreen == null || _imgRed == null || _imgYellow == null) return;

    final base = switch (p.status) {
      BuoyStatus.active => _imgGreen!,
      BuoyStatus.offline => _imgRed!,
      BuoyStatus.batteryLow => _imgYellow!,
    };

    final bytes = await _buildMarkerBytes(
      base: base,
      lines: _markerLinesForPoint(p),
    );
    if (bytes == null) return;
    _markerIconCache[key] = BitmapDescriptor.bytes(bytes);
  }

  Future<Uint8List?> _buildMarkerBytes({
    required ui.Image base,
    required List<String> lines,
  }) async {
    final pinW = 30.0;
    final pinH = 40.0;
    final labelStyle = const TextStyle(
      color: Color(0xFF3F4B54),
      fontWeight: FontWeight.w700,
      fontSize: 10,
      height: 1.15,
    );

    TextPainter? tp;
    if (lines.isNotEmpty) {
      final txt = lines.join('\n');
      tp = TextPainter(
        text: TextSpan(text: txt, style: labelStyle),
        textDirection: TextDirection.ltr,
        maxLines: 3,
      )..layout();
    }

    final textW = tp?.width ?? 0;
    final textH = tp?.height ?? 0;
    final width = (pinW + 4 + textW + 2).clamp(pinW, 160.0).toDouble();
    final height = (pinH > textH ? pinH : textH) + 2;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width, height);
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.transparent);

    final pinRect = Rect.fromLTWH(0, (height - pinH) / 2, pinW, pinH);
    paintImage(
      canvas: canvas,
      rect: pinRect,
      image: base,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (tp != null) {
      tp.paint(canvas, Offset(pinW + 4, (height - textH) / 2));
    }

    final img = await recorder.endRecording().toImage(
      size.width.ceil(),
      size.height.ceil(),
    );
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    return bd?.buffer.asUint8List();
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    final lastIndex = widget.points.length - 1;
    for (var i = 0; i < widget.points.length; i++) {
      final p = widget.points[i];
      final pos = LatLng(p.position.latitude, p.position.longitude);
      final key = _cacheKey(p);
      final icon = _markerIconCache[key];
      final isStart = i == 0;
      final isCurrent = i == lastIndex;
      markers.add(
        Marker(
          markerId: MarkerId('trajectory_$i'),
          position: pos,
          zIndexInt: isCurrent ? 3 : (isStart ? 2 : 1),
          icon: isCurrent
              ? BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet,
                )
              : isStart
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
              : (icon ??
                    BitmapDescriptor.defaultMarkerWithHue(
                      _hueForStatus(p.status),
                    )),
          infoWindow: InfoWindow(
            title: isCurrent
                ? 'Current Position'
                : (isStart ? 'Starting Position' : 'Movement'),
            snippet: _markerLinesForPoint(p).join(' | '),
          ),
        ),
      );
    }
    return markers;
  }

  List<String> _markerLinesForPoint(TrajectoryBuoyPoint point) {
    final lines = <String>[];
    if (widget.showGpsCoordinates) {
      lines.add(point.gpsLabel);
    }
    if (widget.showBatteryLogs) {
      lines.add('Battery: ${point.batteryLabel}');
    }
    if (widget.showTimestamps) {
      lines.add(point.timestampLabel);
    }
    return lines;
  }

  double _hueForStatus(BuoyStatus status) {
    return switch (status) {
      BuoyStatus.active => BitmapDescriptor.hueGreen,
      BuoyStatus.offline => BitmapDescriptor.hueRed,
      BuoyStatus.batteryLow => BitmapDescriptor.hueOrange,
    };
  }

  Set<Polyline> _buildPolylines() {
    if (widget.points.length < 2) return const {};
    final rawPoints = widget.points
        .map((e) => LatLng(e.position.latitude, e.position.longitude))
        .toList(growable: false);
    final points = _buildSmoothCurvePoints(rawPoints);
    return {
      Polyline(
        polylineId: const PolylineId('trajectory_path'),
        points: points,
        width: 4,
        color: const Color(0xFF1E5FBF),
        patterns: [PatternItem.dash(16), PatternItem.gap(10)],
      ),
    };
  }

  List<LatLng> _buildSmoothCurvePoints(List<LatLng> input) {
    if (input.length < 3) {
      return input;
    }
    final out = <LatLng>[];
    for (var i = 0; i < input.length - 1; i++) {
      final p0 = i == 0 ? input[i] : input[i - 1];
      final p1 = input[i];
      final p2 = input[i + 1];
      final p3 = i + 2 < input.length ? input[i + 2] : input[i + 1];

      const steps = 12;
      for (var s = 0; s < steps; s++) {
        final t = s / steps;
        final t2 = t * t;
        final t3 = t2 * t;

        // Catmull-Rom spline interpolation.
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

        out.add(LatLng(lat, lng));
      }
    }
    out.add(input.last);
    return out;
  }

  void _scheduleFit() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _fit();
    });
  }

  Future<void> _fit() async {
    final c = _controller;
    if (c == null || _didFit || widget.points.isEmpty) return;
    final points = widget.points
        .map((e) => LatLng(e.position.latitude, e.position.longitude))
        .toList(growable: false);
    _didFit = true;
    try {
      await fitGoogleMapToPoints(
        controller: c,
        points: points,
        paddingPx: 52,
        singlePointZoom: 12.5,
      );
      await _notifyMapZoomChanged();
    } on Object {
      _didFit = false;
    }
  }

  Future<void> _notifyMapZoomChanged() async {
    final c = _controller;
    final onZoom = widget.onMapZoomChanged;
    if (c == null || onZoom == null) {
      return;
    }
    try {
      final z = await c.getZoomLevel();
      if (mounted) {
        onZoom(z);
      }
    } on Object {
      // Non-fatal: zoom sync is best-effort.
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.points.isNotEmpty
        ? LatLng(
            widget.points.first.position.latitude,
            widget.points.first.position.longitude,
          )
        : const LatLng(37.7749, -122.4194);
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: target,
        zoom: widget.initialZoom,
      ),
      style: _mapStyle,
      mapType: MapType.normal,
      markers: _buildMarkers(),
      polylines: _buildPolylines(),
      minMaxZoomPreference: const MinMaxZoomPreference(3, 21),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: widget.interactive,
      zoomGesturesEnabled: widget.interactive,
      tiltGesturesEnabled: false,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
      },
      onCameraIdle: () {
        if (widget.onMapZoomChanged != null) {
          _notifyMapZoomChanged();
        }
      },
      onMapCreated: (controller) {
        _controller = controller;
        widget.onControllerReady?.call(controller);
        _didFit = false;
        _scheduleFit();
      },
    );
  }
}
