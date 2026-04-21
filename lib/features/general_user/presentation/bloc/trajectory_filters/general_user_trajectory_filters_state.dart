import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
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
  final double zoom;
  final String message;

  const GeneralUserTrajectoryFiltersState({
    required this.status,
    required this.buoyId,
    required this.trajectoryPoints,
    required this.gpsCoordinatesEnabled,
    required this.timestampsEnabled,
    required this.batteryLogsEnabled,
    required this.zoom,
    required this.message,
  });

  const GeneralUserTrajectoryFiltersState.initial()
    : status = GeneralUserTrajectoryFiltersStatus.initial,
      buoyId = 'DB-01',
      trajectoryPoints = const [],
      gpsCoordinatesEnabled = false,
      timestampsEnabled = false,
      batteryLogsEnabled = false,
      zoom = 10.3,
      message = '';

  bool get canZoomIn => zoom < 17;

  bool get canZoomOut => zoom > 3;

  bool get showSecondaryLabels => gpsCoordinatesEnabled && timestampsEnabled;

  List<TrajectoryBuoyPoint> get displayedPoints {
    if (batteryLogsEnabled) {
      return trajectoryPoints;
    }

    return trajectoryPoints
        .map(
          (point) => point.status == BuoyStatus.batteryLow
              ? point.copyWith(status: BuoyStatus.active)
              : point,
        )
        .toList(growable: false);
  }

  GeneralUserTrajectoryFiltersState copyWith({
    GeneralUserTrajectoryFiltersStatus? status,
    String? buoyId,
    List<TrajectoryBuoyPoint>? trajectoryPoints,
    bool? gpsCoordinatesEnabled,
    bool? timestampsEnabled,
    bool? batteryLogsEnabled,
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
    zoom,
    message,
  ];
}
