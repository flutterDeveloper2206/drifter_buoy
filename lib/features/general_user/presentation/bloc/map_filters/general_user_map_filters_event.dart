import 'package:equatable/equatable.dart';

enum MapDisplayType { satellite, terrain }

abstract class GeneralUserMapFiltersEvent extends Equatable {
  const GeneralUserMapFiltersEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserMapFilters extends GeneralUserMapFiltersEvent {
  const LoadGeneralUserMapFilters();
}

class ToggleTrajectory extends GeneralUserMapFiltersEvent {
  const ToggleTrajectory();
}

class ToggleGpsPoints extends GeneralUserMapFiltersEvent {
  const ToggleGpsPoints();
}

class ToggleBatteryStatus extends GeneralUserMapFiltersEvent {
  const ToggleBatteryStatus();
}

class ToggleGprsSignal extends GeneralUserMapFiltersEvent {
  const ToggleGprsSignal();
}

class ToggleStatusFilter extends GeneralUserMapFiltersEvent {
  const ToggleStatusFilter();
}

class ToggleSignalStrengthFilter extends GeneralUserMapFiltersEvent {
  const ToggleSignalStrengthFilter();
}

class ChangeMapDisplayType extends GeneralUserMapFiltersEvent {
  final MapDisplayType mapType;

  const ChangeMapDisplayType(this.mapType);

  @override
  List<Object> get props => [mapType];
}
