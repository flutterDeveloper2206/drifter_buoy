import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_event.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserMapFiltersStatus { initial, loading, loaded, error }

class GeneralUserMapFiltersState extends Equatable {
  final GeneralUserMapFiltersStatus status;
  final bool trajectoryEnabled;
  final bool gpsPointsEnabled;
  final bool batteryStatusEnabled;
  final bool gprsSignalEnabled;
  final MapBuoyStatusFilter statusFilter;
  final bool locationZoneFilterEnabled;
  final MapDisplayType mapType;
  final String message;

  const GeneralUserMapFiltersState({
    required this.status,
    required this.trajectoryEnabled,
    required this.gpsPointsEnabled,
    required this.batteryStatusEnabled,
    required this.gprsSignalEnabled,
    required this.statusFilter,
    required this.locationZoneFilterEnabled,
    required this.mapType,
    required this.message,
  });

  const GeneralUserMapFiltersState.initial()
    : status = GeneralUserMapFiltersStatus.initial,
      trajectoryEnabled = false,
      gpsPointsEnabled = true,
      batteryStatusEnabled = false,
      gprsSignalEnabled = false,
      statusFilter = MapBuoyStatusFilter.both,
      locationZoneFilterEnabled = false,
      mapType = MapDisplayType.terrain,
      message = '';

  bool get showOnlineBuoys =>
      statusFilter == MapBuoyStatusFilter.online ||
      statusFilter == MapBuoyStatusFilter.both;

  bool get showOfflineBuoys =>
      statusFilter == MapBuoyStatusFilter.offline ||
      statusFilter == MapBuoyStatusFilter.both;

  GeneralUserMapFiltersState copyWith({
    GeneralUserMapFiltersStatus? status,
    bool? trajectoryEnabled,
    bool? gpsPointsEnabled,
    bool? batteryStatusEnabled,
    bool? gprsSignalEnabled,
    MapBuoyStatusFilter? statusFilter,
    bool? locationZoneFilterEnabled,
    MapDisplayType? mapType,
    String? message,
  }) {
    return GeneralUserMapFiltersState(
      status: status ?? this.status,
      trajectoryEnabled: trajectoryEnabled ?? this.trajectoryEnabled,
      gpsPointsEnabled: gpsPointsEnabled ?? this.gpsPointsEnabled,
      batteryStatusEnabled: batteryStatusEnabled ?? this.batteryStatusEnabled,
      gprsSignalEnabled: gprsSignalEnabled ?? this.gprsSignalEnabled,
      statusFilter: statusFilter ?? this.statusFilter,
      locationZoneFilterEnabled:
          locationZoneFilterEnabled ?? this.locationZoneFilterEnabled,
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
    statusFilter,
    locationZoneFilterEnabled,
    mapType,
    message,
  ];
}
