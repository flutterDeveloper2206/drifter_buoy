import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:equatable/equatable.dart';

abstract class GeneralUserMapEvent extends Equatable {
  const GeneralUserMapEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserMap extends GeneralUserMapEvent {
  final List<DummyBuoy>? preloadedBuoys;

  const LoadGeneralUserMap({this.preloadedBuoys});

  @override
  List<Object?> get props => [preloadedBuoys];
}

class ToggleGeneralUserMapPanel extends GeneralUserMapEvent {
  const ToggleGeneralUserMapPanel();
}

class ToggleBuoyStatusFilter extends GeneralUserMapEvent {
  final BuoyStatus status;

  const ToggleBuoyStatusFilter(this.status);

  @override
  List<Object> get props => [status];
}

class ResetBuoyFilters extends GeneralUserMapEvent {
  const ResetBuoyFilters();
}

class ZoomInMap extends GeneralUserMapEvent {
  const ZoomInMap();
}

class ZoomOutMap extends GeneralUserMapEvent {
  const ZoomOutMap();
}
