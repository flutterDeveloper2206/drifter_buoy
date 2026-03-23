import 'package:equatable/equatable.dart';

abstract class GeneralUserTrajectoryFiltersEvent extends Equatable {
  const GeneralUserTrajectoryFiltersEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserTrajectoryFilters
    extends GeneralUserTrajectoryFiltersEvent {
  final String buoyId;

  const LoadGeneralUserTrajectoryFilters({this.buoyId = 'DB-01'});

  @override
  List<Object> get props => [buoyId];
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

class ZoomInGeneralUserTrajectoryFilters
    extends GeneralUserTrajectoryFiltersEvent {
  const ZoomInGeneralUserTrajectoryFilters();
}

class ZoomOutGeneralUserTrajectoryFilters
    extends GeneralUserTrajectoryFiltersEvent {
  const ZoomOutGeneralUserTrajectoryFilters();
}
