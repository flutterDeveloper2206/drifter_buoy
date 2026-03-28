import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_event.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserMapFiltersStatus { initial, loading, loaded, error }

class GeneralUserMapFiltersState extends Equatable {
  final GeneralUserMapFiltersStatus status;
  final bool trajectoryEnabled;
  final bool gpsPointsEnabled;
  final bool batteryStatusEnabled;
  final bool gprsSignalEnabled;
  final bool statusFilterEnabled;
  final bool signalStrengthEnabled;
  final MapDisplayType mapType;
  final String message;

  const GeneralUserMapFiltersState({
    required this.status,
    required this.trajectoryEnabled,
    required this.gpsPointsEnabled,
    required this.batteryStatusEnabled,
    required this.gprsSignalEnabled,
    required this.statusFilterEnabled,
    required this.signalStrengthEnabled,
    required this.mapType,
    required this.message,
  });

  const GeneralUserMapFiltersState.initial()
    : status = GeneralUserMapFiltersStatus.initial,
      trajectoryEnabled = false,
      gpsPointsEnabled = true,
      batteryStatusEnabled = false,
      gprsSignalEnabled = false,
      statusFilterEnabled = true,
      signalStrengthEnabled = false,
      mapType = MapDisplayType.satellite,
      message = '';

  GeneralUserMapFiltersState copyWith({
    GeneralUserMapFiltersStatus? status,
    bool? trajectoryEnabled,
    bool? gpsPointsEnabled,
    bool? batteryStatusEnabled,
    bool? gprsSignalEnabled,
    bool? statusFilterEnabled,
    bool? signalStrengthEnabled,
    MapDisplayType? mapType,
    String? message,
  }) {
    return GeneralUserMapFiltersState(
      status: status ?? this.status,
      trajectoryEnabled: trajectoryEnabled ?? this.trajectoryEnabled,
      gpsPointsEnabled: gpsPointsEnabled ?? this.gpsPointsEnabled,
      batteryStatusEnabled: batteryStatusEnabled ?? this.batteryStatusEnabled,
      gprsSignalEnabled: gprsSignalEnabled ?? this.gprsSignalEnabled,
      statusFilterEnabled: statusFilterEnabled ?? this.statusFilterEnabled,
      signalStrengthEnabled:
          signalStrengthEnabled ?? this.signalStrengthEnabled,
      mapType: mapType ?? this.mapType,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [
    status,
    trajectoryEnabled,
    gpsPointsEnabled,
    batteryStatusEnabled,
    gprsSignalEnabled,
    statusFilterEnabled,
    signalStrengthEnabled,
    mapType,
    message,
  ];
}
