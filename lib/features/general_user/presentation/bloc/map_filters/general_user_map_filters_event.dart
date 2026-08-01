import 'package:equatable/equatable.dart';

enum MapDisplayType { satellite, terrain }

enum MapBuoyStatusFilter { online, offline, both }

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

class ChangeStatusFilter extends GeneralUserMapFiltersEvent {
  const ChangeStatusFilter(this.filter);

  final MapBuoyStatusFilter filter;

  @override
  List<Object> get props => [filter];
}

class ToggleLocationZoneFilter extends GeneralUserMapFiltersEvent {
  const ToggleLocationZoneFilter();
}

class ChangeMapDisplayType extends GeneralUserMapFiltersEvent {
  final MapDisplayType mapType;

  const ChangeMapDisplayType(this.mapType);

  @override
  List<Object> get props => [mapType];
}
