import 'package:equatable/equatable.dart';

import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_event.dart';

abstract class GeneralUserTrajectoryFiltersEvent extends Equatable {
  const GeneralUserTrajectoryFiltersEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserTrajectoryFilters
    extends GeneralUserTrajectoryFiltersEvent {
  final String buoyId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? intervalMinutes;

  const LoadGeneralUserTrajectoryFilters({
    this.buoyId = 'buyos123',
    this.fromDate,
    this.toDate,
    this.intervalMinutes,
  });

  @override
  List<Object?> get props => [buoyId, fromDate, toDate, intervalMinutes];
}

class ToggleGpsCoordinatesFilter extends GeneralUserTrajectoryFiltersEvent {
  const ToggleGpsCoordinatesFilter();
}

class ToggleTimestampsFilter extends GeneralUserTrajectoryFiltersEvent {
  const ToggleTimestampsFilter();
}

class ToggleBatteryLogsFilter extends GeneralUserTrajectoryFiltersEvent {
  const ToggleBatteryLogsFilter();
}

class ChangeTrajectoryMapDisplayType
    extends GeneralUserTrajectoryFiltersEvent {
  const ChangeTrajectoryMapDisplayType(this.mapType);

  final MapDisplayType mapType;

  @override
  List<Object> get props => [mapType];
}

class ZoomInGeneralUserTrajectoryFilters
    extends GeneralUserTrajectoryFiltersEvent {
  const ZoomInGeneralUserTrajectoryFilters();
}

class ZoomOutGeneralUserTrajectoryFilters
    extends GeneralUserTrajectoryFiltersEvent {
  const ZoomOutGeneralUserTrajectoryFilters();
}
