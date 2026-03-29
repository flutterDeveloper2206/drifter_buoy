import 'package:drifter_buoy/core/utils/google_maps_camera_utils.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Non-interactive Google Map preview showing buoy markers and fitting the
/// camera to include all points.
class GoogleMapsBuoyPreview extends StatefulWidget {
  const GoogleMapsBuoyPreview({
    super.key,
    required this.buoys,
    this.height = 360,
  });

  final List<DummyBuoy> buoys;
  final double height;

  @override
  State<GoogleMapsBuoyPreview> createState() => _GoogleMapsBuoyPreviewState();
}

class _GoogleMapsBuoyPreviewState extends State<GoogleMapsBuoyPreview> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  bool _didFitCamera = false;

  @override
  void didUpdateWidget(covariant GoogleMapsBuoyPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.buoys, widget.buoys)) {
      _didFitCamera = false;
      _markers = _buildMarkers(widget.buoys);
      _scheduleFitCamera();
    }
  }

  @override
  void initState() {
    super.initState();
    _markers = _buildMarkers(widget.buoys);
  }

  Set<Marker> _buildMarkers(List<DummyBuoy> buoys) {
    return buoys.map((b) {
      final gLatLng = LatLng(b.position.latitude, b.position.longitude);
      return Marker(
        markerId: MarkerId(b.id),
        position: gLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(_hueForStatus(b.status)),
      );
    }).toSet();
  }

  double _hueForStatus(BuoyStatus status) {
    switch (status) {
      case BuoyStatus.active:
        return BitmapDescriptor.hueGreen;
      case BuoyStatus.offline:
        return BitmapDescriptor.hueRed;
      case BuoyStatus.batteryLow:
        return BitmapDescriptor.hueOrange;
    }
  }

  void _scheduleFitCamera() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _fitCamera();
    });
  }

  Future<void> _fitCamera() async {
    final c = _controller;
    if (c == null || _didFitCamera) {
      return;
    }
    final points = widget.buoys
        .map((b) => LatLng(b.position.latitude, b.position.longitude))
        .toList(growable: false);
    if (points.isEmpty) {
      return;
    }
    _didFitCamera = true;
    try {
      await fitGoogleMapToPoints(
        controller: c,
        points: points,
        paddingPx: 44,
        singlePointZoom: 12,
      );
    } on Object catch (_) {
      _didFitCamera = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.buoys.isEmpty) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFE8EBED),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'No buoy locations to show',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF5C5C5C),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      );
    }

    final first = widget.buoys.first;
    final initial = LatLng(first.position.latitude, first.position.longitude);

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IgnorePointer(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initial,
              zoom: 10,
            ),
            markers: _markers,
            mapType: MapType.normal,
            compassEnabled: false,
            mapToolbarEnabled: false,
            rotateGesturesEnabled: false,
            scrollGesturesEnabled: false,
            zoomGesturesEnabled: false,
            tiltGesturesEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            liteModeEnabled: defaultTargetPlatform == TargetPlatform.android,
            onMapCreated: (controller) {
              _controller = controller;
              _didFitCamera = false;
              _scheduleFitCamera();
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }
}
