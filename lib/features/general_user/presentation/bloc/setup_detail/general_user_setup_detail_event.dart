import 'package:equatable/equatable.dart';

abstract class GeneralUserSetupDetailEvent extends Equatable {
  const GeneralUserSetupDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserSetupDetail extends GeneralUserSetupDetailEvent {
  const LoadGeneralUserSetupDetail();
}

class ChangeGeneralUserSetupDetailTab extends GeneralUserSetupDetailEvent {
  final SetupDetailTab tab;

  const ChangeGeneralUserSetupDetailTab(this.tab);

  @override
  List<Object> get props => [tab];
}

class ToggleGeneralUserEnableConfiguration extends GeneralUserSetupDetailEvent {
  const ToggleGeneralUserEnableConfiguration();
}

enum SetupDetailTab { addNew, backup }
