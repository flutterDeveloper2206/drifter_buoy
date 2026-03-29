import 'package:drifter_buoy/core/utils/google_maps_camera_utils.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Google Map layer for the general-user map screen: buoy markers, selection,
/// and camera sync with [zoomLevel] from [GeneralUserMapBloc].
class GeneralUserGoogleMapView extends StatefulWidget {
  const GeneralUserGoogleMapView({
    super.key,
    required this.buoys,
    required this.zoomLevel,
    required this.mapType,
    this.selectedBuoy,
    this.onBuoyTap,
    this.onMapTap,
    this.onControllerReady,
    this.boundsPaddingPx = 64,
  });

  final List<DummyBuoy> buoys;
  final double zoomLevel;
  final MapDisplayType mapType;
  final DummyBuoy? selectedBuoy;
  final ValueChanged<DummyBuoy>? onBuoyTap;
  final VoidCallback? onMapTap;
  final ValueChanged<GoogleMapController>? onControllerReady;
  final double boundsPaddingPx;

  @override
  State<GeneralUserGoogleMapView> createState() =>
      _GeneralUserGoogleMapViewState();
}

class _GeneralUserGoogleMapViewState extends State<GeneralUserGoogleMapView> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  bool _didInitialFit = false;

  @override
  void initState() {
    super.initState();
    _markers = _buildMarkers();
  }

  @override
  void didUpdateWidget(covariant GeneralUserGoogleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.buoys, widget.buoys) ||
        oldWidget.selectedBuoy?.id != widget.selectedBuoy?.id) {
      _markers = _buildMarkers();
      if (!listEquals(oldWidget.buoys, widget.buoys)) {
        _didInitialFit = false;
        _scheduleFitCamera();
      } else {
        setState(() {});
      }
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
      return Marker(
        markerId: MarkerId(b.id),
        position: pos,
        zIndexInt: isSelected ? 2 : 1,
        infoWindow: InfoWindow(
          title: b.id,
          snippet: _snippetForStatus(b.status),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(_hueForStatus(b.status)),
        onTap: () => widget.onBuoyTap?.call(b),
      );
    }).toSet();
  }

  double _hueForStatus(BuoyStatus status) {
    return switch (status) {
      BuoyStatus.active => BitmapDescriptor.hueGreen,
      BuoyStatus.offline => BitmapDescriptor.hueRed,
      BuoyStatus.batteryLow => BitmapDescriptor.hueOrange,
    };
  }

  String _snippetForStatus(BuoyStatus status) {
    return switch (status) {
      BuoyStatus.active => 'Active',
      BuoyStatus.offline => 'Offline',
      BuoyStatus.batteryLow => 'Battery low',
    };
  }

  MapType _googleMapType() {
    return widget.mapType == MapDisplayType.satellite
        ? MapType.satellite
        : MapType.terrain;
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
    if (c == null || widget.buoys.isEmpty || _didInitialFit) {
      return;
    }
    final points = widget.buoys
        .map((b) => LatLng(b.position.latitude, b.position.longitude))
        .toList(growable: false);
    try {
      await fitGoogleMapToPoints(
        controller: c,
        points: points,
        paddingPx: widget.boundsPaddingPx,
        singlePointZoom: widget.zoomLevel.clamp(3, 17),
      );
      _didInitialFit = true;
    } on Object catch (_) {
      _didInitialFit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = widget.buoys.isNotEmpty
        ? widget.buoys.first
        : null;
    final initial = first != null
        ? LatLng(first.position.latitude, first.position.longitude)
        : const LatLng(20.5937, 78.9629);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initial,
        zoom: widget.zoomLevel.clamp(3, 17),
      ),
      mapType: _googleMapType(),
      markers: _markers,
      compassEnabled: false,
      mapToolbarEnabled: false,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      tiltGesturesEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) {
        _controller = controller;
        widget.onControllerReady?.call(controller);
        _didInitialFit = false;
        _scheduleFitCamera();
      },
      onTap: (_) {
        widget.onMapTap?.call();
      },
    );
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }
}
