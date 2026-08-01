import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_view/general_user_trajectory_view_mapper.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_trajectory_live_map_view.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserTrajectoryFiltersStatus { initial, loading, loaded, error }

class GeneralUserTrajectoryFiltersState extends Equatable {
  final GeneralUserTrajectoryFiltersStatus status;
  final String buoyId;
  final List<TrajectoryBuoyPoint> trajectoryPoints;
  final bool gpsCoordinatesEnabled;
  final bool timestampsEnabled;
  final bool batteryLogsEnabled;
  final MapDisplayType mapType;
  final double zoom;
  final String message;

  const GeneralUserTrajectoryFiltersState({
    required this.status,
    required this.buoyId,
    required this.trajectoryPoints,
    required this.gpsCoordinatesEnabled,
    required this.timestampsEnabled,
    required this.batteryLogsEnabled,
    required this.mapType,
    required this.zoom,
    required this.message,
  });

  const GeneralUserTrajectoryFiltersState.initial()
    : status = GeneralUserTrajectoryFiltersStatus.initial,
      buoyId = 'buyos123',
      trajectoryPoints = const [],
      gpsCoordinatesEnabled = false,
      timestampsEnabled = false,
      batteryLogsEnabled = false,
      mapType = MapDisplayType.terrain,
      zoom = 10.3,
      message = '';

  bool get canZoomIn => zoom < 17;

  bool get canZoomOut => zoom > 3;

  bool get showSecondaryLabels => gpsCoordinatesEnabled && timestampsEnabled;

  List<TrajectoryBuoyPoint> get displayedPoints {
    return applyTrajectoryBatteryDisplayFilter(
      trajectoryPoints,
      batteryLogsEnabled: batteryLogsEnabled,
    );
  }

  GeneralUserTrajectoryFiltersState copyWith({
    GeneralUserTrajectoryFiltersStatus? status,
    String? buoyId,
    List<TrajectoryBuoyPoint>? trajectoryPoints,
    bool? gpsCoordinatesEnabled,
    bool? timestampsEnabled,
    bool? batteryLogsEnabled,
    MapDisplayType? mapType,
    double? zoom,
    String? message,
  }) {
    return GeneralUserTrajectoryFiltersState(
      status: status ?? this.status,
      buoyId: buoyId ?? this.buoyId,
      trajectoryPoints: trajectoryPoints ?? this.trajectoryPoints,
      gpsCoordinatesEnabled:
          gpsCoordinatesEnabled ?? this.gpsCoordinatesEnabled,
      timestampsEnabled: timestampsEnabled ?? this.timestampsEnabled,
      batteryLogsEnabled: batteryLogsEnabled ?? this.batteryLogsEnabled,
      mapType: mapType ?? this.mapType,
      zoom: zoom ?? this.zoom,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [
    status,
    buoyId,
    trajectoryPoints,
    gpsCoordinatesEnabled,
    timestampsEnabled,
    batteryLogsEnabled,
    mapType,
    zoom,
    message,
  ];
}
