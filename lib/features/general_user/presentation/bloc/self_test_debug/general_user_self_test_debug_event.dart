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

class ClearGeneralUserSelfTestDebugMessage
    extends GeneralUserSelfTestDebugEvent {
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

class SubmitGeneralUserSetStationName extends GeneralUserSelfTestDebugEvent {
  const SubmitGeneralUserSetStationName(this.stationName);

  final String stationName;

  @override
  List<Object> get props => [stationName];
}

class ClearGeneralUserSetStationNamePrompt
    extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserSetStationNamePrompt();
}

class SubmitGeneralUserMeasurementStartTime
    extends GeneralUserSelfTestDebugEvent {
  const SubmitGeneralUserMeasurementStartTime(this.timeValue);

  final String timeValue;

  @override
  List<Object> get props => [timeValue];
}

class ClearGeneralUserMeasurementStartTimePrompt
    extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserMeasurementStartTimePrompt();
}

class SubmitGeneralUserSetTransmissionTime
    extends GeneralUserSelfTestDebugEvent {
  const SubmitGeneralUserSetTransmissionTime(this.timeValue);

  final String timeValue;

  @override
  List<Object> get props => [timeValue];
}

class ClearGeneralUserTransmissionTimePrompt
    extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserTransmissionTimePrompt();
}

class SubmitGeneralUserSetTransmissionInterval
    extends GeneralUserSelfTestDebugEvent {
  const SubmitGeneralUserSetTransmissionInterval(this.timeValue);

  final String timeValue;

  @override
  List<Object> get props => [timeValue];
}

class ClearGeneralUserTransmissionIntervalPrompt
    extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserTransmissionIntervalPrompt();
}

class SubmitGeneralUserSetMeasurementInterval
    extends GeneralUserSelfTestDebugEvent {
  const SubmitGeneralUserSetMeasurementInterval({
    required this.measurementInterval,
  });

  final String measurementInterval;

  @override
  List<Object> get props => [measurementInterval];
}

class ClearGeneralUserMeasurementIntervalPrompt
    extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserMeasurementIntervalPrompt();
}

class SubmitGeneralUserSetApn extends GeneralUserSelfTestDebugEvent {
  const SubmitGeneralUserSetApn({
    required this.apnName,
    required this.vodafoneOrOther,
    required this.simSlot,
  });

  /// User-entered APN (Para 1); sent as typed (max 31 chars), matching catalog e.g. `?11,jionet,0,2,#`.
  final String apnName;

  /// Para 2: `0` = Vodafone, `1` = other SIM.
  final int vodafoneOrOther;

  /// Para 3: `1` = SIM1 APN, `2` = SIM2 APN.
  final int simSlot;

  @override
  List<Object> get props => [apnName, vodafoneOrOther, simSlot];
}

class ClearGeneralUserSetApnPrompt extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserSetApnPrompt();
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

class ClearGeneralUserSetAttenuationPrompt
    extends GeneralUserSelfTestDebugEvent {
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

/// Fired when the BLE central observes a peripheral disconnect (power off,
/// range, link loss, etc.). Keeps self-test UI consistent with connection state.
class NotifyBlePeripheralDisconnected extends GeneralUserSelfTestDebugEvent {
  const NotifyBlePeripheralDisconnected();
}

/// Primary/secondary FTP, SMS cell, TX redundancy — payload from dialog.
class SubmitGeneralUserParameterizedCommand
    extends GeneralUserSelfTestDebugEvent {
  const SubmitGeneralUserParameterizedCommand({
    required this.commandId,
    required this.value,
  });

  final String commandId;
  final String value;

  @override
  List<Object> get props => [commandId, value];
}

class ClearGeneralUserParameterizedCommandPrompt
    extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserParameterizedCommandPrompt();
}

class SubmitGeneralUserRestoreServerParameters
    extends GeneralUserSelfTestDebugEvent {
  const SubmitGeneralUserRestoreServerParameters({required this.commandId});

  final String commandId;

  @override
  List<Object> get props => [commandId];
}

class ClearGeneralUserRestoreServerParametersPrompt
    extends GeneralUserSelfTestDebugEvent {
  const ClearGeneralUserRestoreServerParametersPrompt();
}
