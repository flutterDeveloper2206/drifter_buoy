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
  const RunGeneralUserSelfTestDebugAction(this.commandIndex);

  final int commandIndex;

  @override
  List<Object> get props => [commandIndex];
}

class ClearGeneralUserSelfTestDebugMessage extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserSelfTestDebugMessage();
}

class SubmitGeneralUserSetStationId extends GeneralUserSelfTestDebugEvent {
  const SubmitGeneralUserSetStationId(this.stationId);

  final String stationId;

  @override
  List<Object> get props => [stationId];
}

class ClearGeneralUserSetStationIdPrompt extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserSetStationIdPrompt();
}

class SubmitGeneralUserMeasurementStartTime extends GeneralUserSelfTestDebugEvent {
  const SubmitGeneralUserMeasurementStartTime(this.timeValue);

  final String timeValue;

  @override
  List<Object> get props => [timeValue];
}

class ClearGeneralUserMeasurementStartTimePrompt
    extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserMeasurementStartTimePrompt();
}

class SubmitGeneralUserTransmitterFrequency
    extends GeneralUserSelfTestDebugEvent {
  const SubmitGeneralUserTransmitterFrequency({
    required this.transmitterType,
    required this.frequencyValue,
  });

  final int transmitterType;
  final String frequencyValue;

  @override
  List<Object> get props => [transmitterType, frequencyValue];
}

class ClearGeneralUserTransmitterFrequencyPrompt
    extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserTransmitterFrequencyPrompt();
}

class SubmitGeneralUserSetAttenuation extends GeneralUserSelfTestDebugEvent {
  const SubmitGeneralUserSetAttenuation({
    required this.transmitterType,
    required this.attenuationValue,
  });

  final int transmitterType;
  final String attenuationValue;

  @override
  List<Object> get props => [transmitterType, attenuationValue];
}

class ClearGeneralUserSetAttenuationPrompt extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserSetAttenuationPrompt();
}

class SubmitGeneralUserRadioSondeTransmitterId
    extends GeneralUserSelfTestDebugEvent {
  const SubmitGeneralUserRadioSondeTransmitterId(this.transmitterId);

  final String transmitterId;

  @override
  List<Object> get props => [transmitterId];
}

class ClearGeneralUserRadioSondeTransmitterIdPrompt
    extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserRadioSondeTransmitterIdPrompt();
}

class SubmitGeneralUserTransmitterTest extends GeneralUserSelfTestDebugEvent {
  const SubmitGeneralUserTransmitterTest({
    required this.plainCarrierOn,
    required this.modulationOn,
    required this.prbsOn,
  });

  final bool plainCarrierOn;
  final bool modulationOn;
  final bool prbsOn;

  @override
  List<Object> get props => [plainCarrierOn, modulationOn, prbsOn];
}

class ClearGeneralUserTransmitterTestPrompt
    extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserTransmitterTestPrompt();
}

class ClearGeneralUserCheckStatusPrompt extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserCheckStatusPrompt();
}
