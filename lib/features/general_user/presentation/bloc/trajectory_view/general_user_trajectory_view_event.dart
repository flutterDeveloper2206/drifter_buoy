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

class ZoomInGeneralUserTrajectoryView extends GeneralUserTrajectoryViewEvent {
  const ZoomInGeneralUserTrajectoryView();
}

class ZoomOutGeneralUserTrajectoryView extends GeneralUserTrajectoryViewEvent {
  const ZoomOutGeneralUserTrajectoryView();
}
