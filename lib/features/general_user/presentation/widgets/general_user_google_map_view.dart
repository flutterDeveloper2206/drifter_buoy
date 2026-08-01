import 'package:drifter_buoy/core/utils/google_maps_camera_utils.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_event.dart';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Google Map layer for the general-user map screen: buoy markers, selection,
/// and camera sync with [zoomLevel] from [GeneralUserMapBloc].
class GeneralUserGoogleMapView extends StatefulWidget {
  const GeneralUserGoogleMapView({
    super.key,
    required this.buoys,
    required this.zoomLevel,
    required this.mapType,
    this.fitBuoys,
    this.showDeviceName = true,
    this.showBatteryStatus = false,
    this.selectedBuoy,
    this.onBuoyTap,
    this.onMapTap,
    this.onControllerReady,
    this.boundsPaddingPx = 64,
    this.fitBoundsLatitudeExpansionDeg = 0,
    this.showEmbeddedZoomControls = false,
    this.showNativeZoomControls = false,
    this.showFitAllBuoysControl = false,
    this.focusBuoysOnLoad = false,
    this.interactive = true,
    this.focusControlBottomPadding = 10,
  });

  final List<DummyBuoy> buoys;
  final double zoomLevel;
  final MapDisplayType mapType;

  /// Buoys used to frame the camera. Defaults to [buoys]. Pass all buoys when
  /// [buoys] is a filtered subset so the map stays near real marker locations.
  final List<DummyBuoy>? fitBuoys;

  final bool showDeviceName;
  final bool showBatteryStatus;
  final DummyBuoy? selectedBuoy;
  final ValueChanged<DummyBuoy>? onBuoyTap;
  final VoidCallback? onMapTap;
  final ValueChanged<GoogleMapController>? onControllerReady;
  final double boundsPaddingPx;

  /// Extra north/south span for [fitGoogleMapToPoints] so bottom-anchored
  /// custom markers (pin + label) are not clipped at the map edge.
  final double fitBoundsLatitudeExpansionDeg;

  /// Inset +/- buttons (works on all platforms; use in small previews).
  final bool showEmbeddedZoomControls;

  /// Android-only native zoom buttons (often redundant with [showEmbeddedZoomControls]).
  final bool showNativeZoomControls;

  /// Shows a control that refits the camera to all [buoys] (dashboard preview).
  final bool showFitAllBuoysControl;

  /// When true, the map stays hidden until the camera is focused on all
  /// [buoys] (used on the home page preview).
  final bool focusBuoysOnLoad;

  /// Enables pan/zoom gestures. Use [gestureRecognizers] when embedded in a
  /// scroll view (e.g. home page preview).
  final bool interactive;

  /// Bottom inset for the focus-on-buoys control (clears bottom sheets/overlays).
  final double focusControlBottomPadding;

  @override
  State<GeneralUserGoogleMapView> createState() =>
      _GeneralUserGoogleMapViewState();
}

class _GeneralUserGoogleMapViewState extends State<GeneralUserGoogleMapView> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  bool _didInitialFit = false;
  bool _pendingLabelRefit = false;
  bool _buoyFocusReady = false;
  bool _userMovedCamera = false;
  bool _isProgrammaticCameraMove = false;

  // Custom marker icons from `assets/images/`.
  BitmapDescriptor? _activeIcon;
  BitmapDescriptor? _offlineIcon;
  BitmapDescriptor? _batteryLowIcon;
  BitmapDescriptor? _activeSelectedIcon;
  BitmapDescriptor? _offlineSelectedIcon;
  BitmapDescriptor? _batteryLowSelectedIcon;

  bool _iconsLoading = false;

  // Composite (pin + label) marker cache.
  final Map<String, BitmapDescriptor> _labelMarkerCache = {};
  ui.Image? _imgGreen;
  ui.Image? _imgRed;
  ui.Image? _imgYellow;

  @override
  void initState() {
    super.initState();
    _markers = _buildMarkers();
    _buoyFocusReady =
        !widget.focusBuoysOnLoad || _validFitLatLngs.isEmpty;
    _scheduleLoadIcons();
  }

  @override
  void didUpdateWidget(covariant GeneralUserGoogleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final buoysChanged = !listEquals(oldWidget.buoys, widget.buoys);
    final fitBuoysChanged = !listEquals(_fitBuoyListFor(oldWidget), _fitBuoyList);
    final selectedChanged =
        oldWidget.selectedBuoy?.id != widget.selectedBuoy?.id;
    final labelConfigChanged =
        oldWidget.showDeviceName != widget.showDeviceName ||
        oldWidget.showBatteryStatus != widget.showBatteryStatus;
    if (buoysChanged || fitBuoysChanged || selectedChanged) {
      if (buoysChanged || fitBuoysChanged) {
        _didInitialFit = false;
        _pendingLabelRefit = false;
        if (widget.focusBuoysOnLoad && _validFitLatLngs.isNotEmpty) {
          _buoyFocusReady = false;
          _userMovedCamera = false;
        }
      }
      _markers = _buildMarkers();
      setState(() {});
      if (buoysChanged || fitBuoysChanged) {
        _scheduleFitCamera();
      }
    }
    if (labelConfigChanged) {
      // Keep image cache, but rebuild marker bitmaps as content changed.
      _labelMarkerCache.clear();
      _markers = _buildMarkers();
      setState(() {});
    }
    if (oldWidget.mapType != widget.mapType) {
      setState(() {});
    }
  }

  Set<Marker> _buildMarkers() {
    final selectedId = widget.selectedBuoy?.id;
    return widget.buoys.map((b) {
      final pos = LatLng(b.position.latitude, b.position.longitude);
      final isSelected = b.id == selectedId;
      final icon = _markerIconFor(b, isSelected: isSelected);
      return Marker(
        markerId: MarkerId(b.id),
        position: pos,
        zIndexInt: isSelected ? 2 : 1,
        consumeTapEvents: false,
        infoWindow: InfoWindow(title: b.id),
        icon: icon,
        onTap: () => widget.onBuoyTap?.call(b),
      );
    }).toSet();
  }

  double _hueForStatus(BuoyStatus status) {
    return switch (status) {
      BuoyStatus.online => BitmapDescriptor.hueGreen,
      BuoyStatus.offline => BitmapDescriptor.hueRed,
      BuoyStatus.batteryLow => BitmapDescriptor.hueOrange,
      // TODO: Handle this case.
      BuoyStatus.active => throw UnimplementedError(),
    };
  }

  BitmapDescriptor _markerIconFor(DummyBuoy buoy, {required bool isSelected}) {
    if (widget.showDeviceName) {
      final cached = _labelMarkerCache[_labelMarkerCacheKey(buoy, isSelected)];
      if (cached != null) {
        return cached;
      }
      // We generate labeled markers async; until then, show normal pins.
    }

    // While icons are loading, fall back to default pins.
    if (isSelected) {
      return switch (buoy.status) {
        BuoyStatus.online =>
          _activeSelectedIcon ??
              BitmapDescriptor.defaultMarkerWithHue(_hueForStatus(buoy.status)),
        BuoyStatus.offline =>
          _offlineSelectedIcon ??
              BitmapDescriptor.defaultMarkerWithHue(_hueForStatus(buoy.status)),
        BuoyStatus.batteryLow =>
          _batteryLowSelectedIcon ??
              BitmapDescriptor.defaultMarkerWithHue(_hueForStatus(buoy.status)),
        // TODO: Handle this case.
        BuoyStatus.active => throw UnimplementedError(),
      };
    }

    return switch (buoy.status) {
      BuoyStatus.online =>
        _activeIcon ??
            BitmapDescriptor.defaultMarkerWithHue(_hueForStatus(buoy.status)),
      BuoyStatus.offline =>
        _offlineIcon ??
            BitmapDescriptor.defaultMarkerWithHue(_hueForStatus(buoy.status)),
      BuoyStatus.batteryLow =>
        _batteryLowIcon ??
            BitmapDescriptor.defaultMarkerWithHue(_hueForStatus(buoy.status)),
      // TODO: Handle this case.
      BuoyStatus.active => throw UnimplementedError(),
    };
  }

  MapType _googleMapType() {
    return widget.mapType == MapDisplayType.satellite
        ? MapType.satellite
        : MapType.terrain;
  }

  void _scheduleLoadIcons() {
    if (_iconsLoading) return;
    _iconsLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await _loadMarkerIcons();
    });
  }

  Future<void> _loadMarkerIcons() async {
    if (_activeIcon != null &&
        _offlineIcon != null &&
        _batteryLowIcon != null &&
        _activeSelectedIcon != null &&
        _offlineSelectedIcon != null &&
        _batteryLowSelectedIcon != null) {
      // Already loaded.
      return;
    }

    try {
      final dpr = MediaQuery.of(context).devicePixelRatio;
      final config = ImageConfiguration(devicePixelRatio: dpr);

      const assetActive = 'assets/images/green.png';
      const assetOffline = 'assets/images/red.png';
      const assetBatteryLow = 'assets/images/yellow.png';

      const normal = 40.0;
      const selected = 54.0;

      // Load base PNGs as ui.Image for compositing labels.
      _imgGreen ??= await _loadUiImage(assetActive);
      _imgRed ??= await _loadUiImage(assetOffline);
      _imgYellow ??= await _loadUiImage(assetBatteryLow);

      _activeIcon = await BitmapDescriptor.asset(
        config,
        assetActive,
        width: normal,
        height: normal,
      );
      _offlineIcon = await BitmapDescriptor.asset(
        config,
        assetOffline,
        width: normal,
        height: normal,
      );
      _batteryLowIcon = await BitmapDescriptor.asset(
        config,
        assetBatteryLow,
        width: normal,
        height: normal,
      );

      _activeSelectedIcon = await BitmapDescriptor.asset(
        config,
        assetActive,
        width: selected,
        height: selected,
      );
      _offlineSelectedIcon = await BitmapDescriptor.asset(
        config,
        assetOffline,
        width: selected,
        height: selected,
      );
      _batteryLowSelectedIcon = await BitmapDescriptor.asset(
        config,
        assetBatteryLow,
        width: selected,
        height: selected,
      );
    } on Object {
      // If icons fail to load for any reason, keep default marker pins.
    } finally {
      _iconsLoading = false;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _labelMarkerCache.clear();
      _markers = _buildMarkers();
    });
  }

  String _labelMarkerCacheKey(DummyBuoy buoy, bool isSelected) {
    final battery = widget.showBatteryStatus ? buoy.battery.trim() : '';
    return '${buoy.status.name}|$isSelected|${buoy.id}|$battery';
  }

  void _scheduleEnsureLabeledMarker(DummyBuoy buoy, bool isSelected) {
    if (!widget.showDeviceName) {
      return;
    }
    final key = _labelMarkerCacheKey(buoy, isSelected);
    if (_labelMarkerCache.containsKey(key)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await _ensureLabeledMarker(key, buoy, isSelected);
    });
  }

  Future<void> _ensureLabeledMarker(
    String key,
    DummyBuoy buoy,
    bool isSelected,
  ) async {
    if (_labelMarkerCache.containsKey(key)) {
      return;
    }
    // Ensure base images exist.
    if (_imgGreen == null || _imgRed == null || _imgYellow == null) {
      // Trigger icon loading if needed.
      _scheduleLoadIcons();
      return;
    }
    final baseImage = switch (buoy.status) {
      BuoyStatus.online => _imgGreen!,
      BuoyStatus.offline => _imgRed!,
      BuoyStatus.batteryLow => _imgYellow!,
      // TODO: Handle this case.
      BuoyStatus.active => throw UnimplementedError(),
    };

    final bytes = await _buildLabeledMarkerBytes(
      base: baseImage,
      label: buoy.id,
      battery: widget.showBatteryStatus ? buoy.battery : null,
      selected: isSelected,
    );
    if (bytes == null) {
      return;
    }
    _labelMarkerCache[key] = BitmapDescriptor.bytes(bytes);
    if (!mounted) {
      return;
    }
    setState(() {
      _markers = _buildMarkers();
    });
    // Labeled bitmaps are taller — refit once labels exist unless user moved.
    if (widget.showDeviceName &&
        _allLabeledMarkersReady() &&
        !_userMovedCamera) {
      _didInitialFit = false;
      _pendingLabelRefit = true;
      _scheduleFitCamera();
    }
  }

  bool _allLabeledMarkersReady() {
    if (!widget.showDeviceName || widget.buoys.isEmpty) {
      return true;
    }
    final selectedId = widget.selectedBuoy?.id;
    for (final b in widget.buoys) {
      final key = _labelMarkerCacheKey(b, b.id == selectedId);
      if (!_labelMarkerCache.containsKey(key)) {
        return false;
      }
    }
    return true;
  }

  Future<ui.Image> _loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<Uint8List?> _buildLabeledMarkerBytes({
    required ui.Image base,
    required String label,
    required bool selected,
    String? battery,
  }) async {
    // Slightly smaller than original so markers don’t dominate the map.
    final pinW = selected ? 62.0 : 48.0;
    final pinH = selected ? 82.0 : 66.0;
    final fontSize = selected ? 16.0 : 11.5;
    final batteryFont = selected ? 11.0 : 10.0;
    final paddingTop = 2.0;
    final paddingBottom = selected ? 5.0 : 4.0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1C2227),
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
    )..layout();

    final batteryPainter = (battery != null && battery.trim().isNotEmpty)
        ? (TextPainter(
            text: TextSpan(
              text: battery.trim(),
              style: TextStyle(
                fontSize: batteryFont,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E343A),
              ),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            maxLines: 1,
          )..layout())
        : null;

    final textW = textPainter.width;
    final batteryW = batteryPainter?.width ?? 0;
    final totalW = (pinW).clamp(0.0, double.infinity).toDouble();
    final desiredW = _max3(totalW, textW + 8, batteryW + 8);
    final labelH = textPainter.height + (batteryPainter?.height ?? 0);
    final totalH = pinH + paddingTop + labelH + paddingBottom;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(desiredW, totalH);

    // Transparent background.
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.transparent);

    // Draw pin image centered.
    final pinRect = Rect.fromLTWH(
      (desiredW - pinW) / 2,
      paddingTop,
      pinW,
      pinH,
    );
    paintImage(
      canvas: canvas,
      rect: pinRect,
      image: base,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    // Draw label centered under pin.
    final labelTop = paddingTop + pinH + 2;
    final labelLeft = (desiredW - textPainter.width) / 2;
    // Optional subtle white shadow for readability.
    final shadow = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: Colors.white.withValues(alpha: 0.85),
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
    )..layout();
    shadow.paint(canvas, Offset(labelLeft + 0.7, labelTop + 0.8));
    textPainter.paint(canvas, Offset(labelLeft, labelTop));

    if (batteryPainter != null) {
      final bTop = labelTop + textPainter.height + 1;
      final bLeft = (desiredW - batteryPainter.width) / 2;
      final bShadow = TextPainter(
        text: TextSpan(
          text: batteryPainter.text?.toPlainText() ?? '',
          style: TextStyle(
            fontSize: batteryFont,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 1,
      )..layout();
      bShadow.paint(canvas, Offset(bLeft + 0.6, bTop + 0.7));
      batteryPainter.paint(canvas, Offset(bLeft, bTop));
    }

    final img = await recorder.endRecording().toImage(
      size.width.ceil(),
      size.height.ceil(),
    );
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  double _max3(double a, double b, double c) {
    final ab = a > b ? a : b;
    return ab > c ? ab : c;
  }

  void _scheduleFitCamera() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _fitCamera(animate: _pendingLabelRefit);
    });
  }

  Future<void> _fitCamera({bool animate = false, int attempt = 0}) async {
    final c = _controller;
    if (c == null || _validFitLatLngs.isEmpty || _didInitialFit) {
      return;
    }
    final points = _validFitLatLngs;
    try {
      if (attempt == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 80));
        if (!mounted) {
          return;
        }
      }
      _isProgrammaticCameraMove = true;
      await fitGoogleMapToPoints(
        controller: c,
        points: points,
        paddingPx: widget.boundsPaddingPx,
        singlePointZoom: widget.zoomLevel.clamp(3, 17).toDouble(),
        expandLatitudeDeg: widget.fitBoundsLatitudeExpansionDeg,
        animate: animate,
      );
      _isProgrammaticCameraMove = false;
      if (!mounted) {
        return;
      }
      setState(() {
        _didInitialFit = true;
        _pendingLabelRefit = false;
        _buoyFocusReady = true;
      });
    } on Object catch (_) {
      _isProgrammaticCameraMove = false;
      if (attempt < 4) {
        await Future<void>.delayed(Duration(milliseconds: 120 + (attempt * 80)));
        if (mounted) {
          await _fitCamera(animate: animate, attempt: attempt + 1);
        }
        return;
      }
      if (mounted) {
        setState(() {
          _didInitialFit = false;
          _buoyFocusReady = true;
        });
      }
    }
  }

  void _refitAllBuoys() {
    _userMovedCamera = false;
    _didInitialFit = false;
    _pendingLabelRefit = false;
    _scheduleFitCamera();
  }

  Future<void> _nudgeZoom(int delta) async {
    final c = _controller;
    if (c == null) {
      return;
    }
    _userMovedCamera = true;
    _isProgrammaticCameraMove = true;
    try {
      final zoom = await c.getZoomLevel();
      await c.animateCamera(
        CameraUpdate.zoomTo((zoom + delta).clamp(3, 17).toDouble()),
      );
    } on Object catch (_) {
    } finally {
      _isProgrammaticCameraMove = false;
    }
  }

  Widget _buildFocusBuoysButton() {
    return Material(
      color: const Color(0xFF1C1C1C),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.28),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _validFitLatLngs.isEmpty ? null : _refitAllBuoys,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.my_location,
            color: widget.buoys.isEmpty && _validFitLatLngs.isEmpty
                ? Colors.white.withValues(alpha: 0.45)
                : Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Zoom in',
            onPressed: () => _nudgeZoom(1),
            icon: const Icon(Icons.add, size: 20),
            color: const Color(0xFF23282D),
          ),
          const SizedBox(height: 2),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Zoom out',
            onPressed: () => _nudgeZoom(-1),
            icon: const Icon(Icons.remove, size: 20),
            color: const Color(0xFF23282D),
          ),
        ],
      ),
    );
  }

  List<DummyBuoy> _fitBuoyListFor(GeneralUserGoogleMapView config) {
    return config.fitBuoys ?? config.buoys;
  }

  List<DummyBuoy> get _fitBuoyList => _fitBuoyListFor(widget);

  List<LatLng> get _validFitLatLngs => _fitBuoyList
      .map((b) => LatLng(b.position.latitude, b.position.longitude))
      .where((p) => isValidMapCoordinate(p.latitude, p.longitude))
      .toList(growable: false);

  CameraPosition? _initialCameraPosition() {
    final camera = cameraTargetAndZoomForPoints(
      _validFitLatLngs,
      singlePointZoom: widget.zoomLevel.clamp(3, 17).toDouble(),
    );
    if (camera == null) {
      return null;
    }
    return CameraPosition(
      target: camera.target,
      zoom: camera.zoom.clamp(3, 17).toDouble(),
    );
  }

  Widget _buildNoLocationPlaceholder() {
    return const ColoredBox(
      color: Color(0xFFE8EBED),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Buoy GPS coordinates could not be read from the server.\n'
            'The map needs valid latitude and longitude to show marker locations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6A7178),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_validFitLatLngs.isEmpty) {
      return _buildNoLocationPlaceholder();
    }

    final initialCamera = _initialCameraPosition();
    if (initialCamera == null) {
      return _buildNoLocationPlaceholder();
    }

    // Ensure labeled marker bitmaps exist for current visible buoys.
    if (widget.showDeviceName) {
      final selectedId = widget.selectedBuoy?.id;
      for (final b in widget.buoys) {
        _scheduleEnsureLabeledMarker(b, b.id == selectedId);
      }
    }

    final map = GoogleMap(
      initialCameraPosition: initialCamera,
      mapType: _googleMapType(),
      markers: _markers,
      compassEnabled: false,
      mapToolbarEnabled: false,
      rotateGesturesEnabled: widget.interactive,
      scrollGesturesEnabled: widget.interactive,
      zoomGesturesEnabled: widget.interactive,
      tiltGesturesEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: widget.showNativeZoomControls,
      minMaxZoomPreference: const MinMaxZoomPreference(3, 21),
      gestureRecognizers: widget.interactive
          ? <Factory<OneSequenceGestureRecognizer>>{
              Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
            }
          : const <Factory<OneSequenceGestureRecognizer>>{},
      onMapCreated: (controller) {
        _controller = controller;
        widget.onControllerReady?.call(controller);
        _didInitialFit = false;
        _pendingLabelRefit = false;
        _userMovedCamera = false;
        _scheduleFitCamera();
      },
      onCameraMoveStarted: () {
        if (!_isProgrammaticCameraMove) {
          _userMovedCamera = true;
        }
      },
      onTap: (_) {
        widget.onMapTap?.call();
      },
    );

    final mapLayer = widget.focusBuoysOnLoad
        ? Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              AnimatedOpacity(
                opacity: _buoyFocusReady ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: map,
              ),
              if (!_buoyFocusReady)
                const ColoredBox(
                  color: Color(0xFFE8EBED),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF1F88D1),
                      ),
                    ),
                  ),
                ),
            ],
          )
        : map;

    if (!widget.showEmbeddedZoomControls && !widget.showFitAllBuoysControl) {
      return mapLayer;
    }

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        mapLayer,
        if (widget.showEmbeddedZoomControls)
          Positioned(
            right: 6,
            top: 6,
            child: _buildMapControls(),
          ),
        if (widget.showFitAllBuoysControl)
          Positioned(
            right: 10,
            bottom: widget.focusControlBottomPadding,
            child: _buildFocusBuoysButton(),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }
}
