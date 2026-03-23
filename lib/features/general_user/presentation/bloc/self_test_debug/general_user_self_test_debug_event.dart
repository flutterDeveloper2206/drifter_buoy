import 'package:equatable/equatable.dart';

abstract class GeneralUserSelfTestDebugEvent extends Equatable {
  const GeneralUserSelfTestDebugEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserSelfTestDebug extends GeneralUserSelfTestDebugEvent {
  const LoadGeneralUserSelfTestDebug();
}

class RunGeneralUserSelfTestDebugAction extends GeneralUserSelfTestDebugEvent {
  final String action;

  const RunGeneralUserSelfTestDebugAction(this.action);

  @override
  List<Object> get props => [action];
}

class ClearGeneralUserSelfTestDebugMessage extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserSelfTestDebugMessage();
}
