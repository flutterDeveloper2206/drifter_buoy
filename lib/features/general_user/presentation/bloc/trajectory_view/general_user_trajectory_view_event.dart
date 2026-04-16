import 'package:equatable/equatable.dart';

abstract class GeneralUserTrajectoryViewEvent extends Equatable {
  const GeneralUserTrajectoryViewEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserTrajectoryView extends GeneralUserTrajectoryViewEvent {
  final String buoyId;

  const LoadGeneralUserTrajectoryView({this.buoyId = 'DB-01'});

  @override
  List<Object> get props => [buoyId];
}

/// Keeps [GeneralUserTrajectoryViewState.zoom] aligned with the Google Map
/// camera (pinch, fit bounds, or +/- controls) for button enablement.
class SyncGeneralUserTrajectoryMapZoom extends GeneralUserTrajectoryViewEvent {
  const SyncGeneralUserTrajectoryMapZoom(this.zoom);

  final double zoom;

  @override
  List<Object?> get props => [zoom];
}
