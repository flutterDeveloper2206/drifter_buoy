import 'package:equatable/equatable.dart';

abstract class GeneralUserAlertsEvent extends Equatable {
  const GeneralUserAlertsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserAlerts extends GeneralUserAlertsEvent {
  const LoadGeneralUserAlerts({this.isPullToRefresh = false});

  final bool isPullToRefresh;

  @override
  List<Object?> get props => [isPullToRefresh];
}
