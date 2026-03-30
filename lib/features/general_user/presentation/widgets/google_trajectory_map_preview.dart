import 'dart:ui' as ui;

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
  });

  final List<ll.LatLng> trajectoryPoints;
  final DummyBuoy buoy;

  @override
  State<GoogleTrajectoryMapPreview> createState() =>
      _GoogleTrajectoryMapPreviewState();
}

class _GoogleTrajectoryMapPreviewState extends State<GoogleTrajectoryMapPreview> {
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
      _activeIcon ??=
          await BitmapDescriptor.asset(cfg, _assetGreen, width: 52, height: 52);
      _offlineIcon ??=
          await BitmapDescriptor.asset(cfg, _assetRed, width: 52, height: 52);
      _batteryLowIcon ??=
          await BitmapDescriptor.asset(cfg, _assetYellow, width: 52, height: 52);
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

    final width = (textPainter.width + 12) > pinW ? (textPainter.width + 12) : pinW;
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
        _activeIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      BuoyStatus.offline =>
        _offlineIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      BuoyStatus.batteryLow =>
        _batteryLowIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    };
  }

  Set<Marker> _buildMarkers() {
    final buoyPos = LatLng(widget.buoy.position.latitude, widget.buoy.position.longitude);
    final markers = <Marker>{
      Marker(
        markerId: MarkerId('main_${widget.buoy.id}'),
        position: buoyPos,
        zIndexInt: 3,
        icon: _labeledBuoyIcon ?? _iconForStatus(widget.buoy.status),
        infoWindow: InfoWindow(title: widget.buoy.id),
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
    final points = widget.trajectoryPoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList(growable: false);
    return {
      Polyline(
        polylineId: const PolylineId('trajectory_preview'),
        points: points,
        width: 4,
        color: const Color(0xFF1E5FBF),
        patterns: [PatternItem.dash(18), PatternItem.gap(10)],
      ),
    };
  }

  List<LatLng> _cameraPoints() {
    final pts = widget.trajectoryPoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList(growable: true);
    pts.add(LatLng(widget.buoy.position.latitude, widget.buoy.position.longitude));
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
      await fitGoogleMapToPoints(
        controller: c,
        points: points,
        paddingPx: 28,
        singlePointZoom: 12.8,
      );
    } on Object {
      _didFit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = LatLng(widget.buoy.position.latitude, widget.buoy.position.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: IgnorePointer(
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: initial, zoom: 10.8),
          mapType: MapType.normal,
          style: _trajectoryPreviewMapStyle,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
          tiltGesturesEnabled: false,
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          onMapCreated: (controller) {
            _controller = controller;
            _didFit = false;
            _scheduleFit();
          },
        ),
      ),
    );
  }
}

