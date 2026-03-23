import 'package:equatable/equatable.dart';

enum GeneralUserBuoyOverviewTab { overview, trajectory }

abstract class GeneralUserBuoyOverviewEvent extends Equatable {
  const GeneralUserBuoyOverviewEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserBuoyOverview extends GeneralUserBuoyOverviewEvent {
  final String buoyId;

  const LoadGeneralUserBuoyOverview({this.buoyId = 'DB-01'});

  @override
  List<Object> get props => [buoyId];
}

class ChangeGeneralUserBuoyOverviewTab extends GeneralUserBuoyOverviewEvent {
  final GeneralUserBuoyOverviewTab tab;

  const ChangeGeneralUserBuoyOverviewTab(this.tab);

  @override
  List<Object> get props => [tab];
}

class ExportGeneralUserBuoyData extends GeneralUserBuoyOverviewEvent {
  const ExportGeneralUserBuoyData();
}

class ClearGeneralUserBuoyOverviewMessage extends GeneralUserBuoyOverviewEvent {
  const ClearGeneralUserBuoyOverviewMessage();
}
