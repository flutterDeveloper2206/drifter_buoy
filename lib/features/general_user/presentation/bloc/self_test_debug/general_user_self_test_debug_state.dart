import 'package:drifter_buoy/features/general_user/data/models/drifter_buoy_command_model.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserSelfTestDebugStatus { initial, loading, loaded, running, error }

/// BLE/API success payload for dialogs or listeners.
class SelfTestBleResponseSnapshot extends Equatable {
  const SelfTestBleResponseSnapshot({
    required this.testName,
    required this.responseLine,
    required this.helpText,
  });

  final String testName;
  final String responseLine;
  final String helpText;

  @override
  List<Object?> get props => [testName, responseLine, helpText];
}

class SelfTestStationIdPrompt extends Equatable {
  const SelfTestStationIdPrompt({
    required this.currentStationId,
  });

  final String currentStationId;

  @override
  List<Object?> get props => [currentStationId];
}

class SelfTestMeasurementTimePrompt extends Equatable {
  const SelfTestMeasurementTimePrompt({
    required this.currentTime,
  });

  final String currentTime;

  @override
  List<Object?> get props => [currentTime];
}

class SelfTestTransmitterFrequencyPrompt extends Equatable {
  const SelfTestTransmitterFrequencyPrompt({
    required this.transmitterType,
    required this.frequencyValue,
  });

  final int transmitterType;
  final String frequencyValue;

  @override
  List<Object?> get props => [transmitterType, frequencyValue];
}

class SelfTestSetAttenuationPrompt extends Equatable {
  const SelfTestSetAttenuationPrompt({
    required this.transmitterType,
    required this.attenuationValue,
  });

  final int transmitterType;
  final String attenuationValue;

  @override
  List<Object?> get props => [transmitterType, attenuationValue];
}

class SelfTestRadioSondeTransmitterIdPrompt extends Equatable {
  const SelfTestRadioSondeTransmitterIdPrompt({
    required this.currentTransmitterId,
  });

  final String currentTransmitterId;

  @override
  List<Object?> get props => [currentTransmitterId];
}

class SelfTestTransmitterTestPrompt extends Equatable {
  const SelfTestTransmitterTestPrompt({
    this.plainCarrierOn = false,
    this.modulationOn = false,
    this.prbsOn = false,
  });

  final bool plainCarrierOn;
  final bool modulationOn;
  final bool prbsOn;

  @override
  List<Object?> get props => [plainCarrierOn, modulationOn, prbsOn];
}

class SelfTestCheckStatusPrompt extends Equatable {
  const SelfTestCheckStatusPrompt({
    required this.peripheralStatus,
    required this.gprsPrimary,
    required this.gprsSecondary,
    required this.gprsThird,
    required this.gprsFactory,
    required this.memory1Fail,
    required this.memory1Test,
    required this.memory2Fail,
    required this.memory2Test,
    required this.chargeStatus,
    required this.firmwareVersion,
    required this.rawResponse,
  });

  final String peripheralStatus;
  final String gprsPrimary;
  final String gprsSecondary;
  final String gprsThird;
  final String gprsFactory;
  final String memory1Fail;
  final String memory1Test;
  final String memory2Fail;
  final String memory2Test;
  final String chargeStatus;
  final String firmwareVersion;
  final String rawResponse;

  @override
  List<Object?> get props => [
        peripheralStatus,
        gprsPrimary,
        gprsSecondary,
        gprsThird,
        gprsFactory,
        memory1Fail,
        memory1Test,
        memory2Fail,
        memory2Test,
        chargeStatus,
        firmwareVersion,
        rawResponse,
      ];
}

class GeneralUserSelfTestDebugState extends Equatable {
  final GeneralUserSelfTestDebugStatus status;
  final List<DrifterBuoyCommandModel> commands;
  final int? runningCommandIndex;
  final String message;
  final bool isSuccessMessage;
  final SelfTestBleResponseSnapshot? lastSnapshot;
  final SelfTestStationIdPrompt? stationIdPrompt;
  final SelfTestMeasurementTimePrompt? measurementTimePrompt;
  final SelfTestTransmitterFrequencyPrompt? transmitterFrequencyPrompt;
  final SelfTestSetAttenuationPrompt? setAttenuationPrompt;
  final SelfTestRadioSondeTransmitterIdPrompt? radioSondeTransmitterIdPrompt;
  final SelfTestTransmitterTestPrompt? transmitterTestPrompt;
  final SelfTestCheckStatusPrompt? checkStatusPrompt;

  const GeneralUserSelfTestDebugState({
    required this.status,
    required this.commands,
    required this.runningCommandIndex,
    required this.message,
    required this.isSuccessMessage,
    required this.lastSnapshot,
    required this.stationIdPrompt,
    required this.measurementTimePrompt,
    required this.transmitterFrequencyPrompt,
    required this.setAttenuationPrompt,
    required this.radioSondeTransmitterIdPrompt,
    required this.transmitterTestPrompt,
    required this.checkStatusPrompt,
  });

  const GeneralUserSelfTestDebugState.initial()
    : status = GeneralUserSelfTestDebugStatus.initial,
      commands = const [],
      runningCommandIndex = null,
      message = '',
      isSuccessMessage = false,
      lastSnapshot = null,
      stationIdPrompt = null,
      measurementTimePrompt = null,
      transmitterFrequencyPrompt = null,
      setAttenuationPrompt = null,
      radioSondeTransmitterIdPrompt = null,
      transmitterTestPrompt = null,
      checkStatusPrompt = null;

  GeneralUserSelfTestDebugState copyWith({
    GeneralUserSelfTestDebugStatus? status,
    List<DrifterBuoyCommandModel>? commands,
    int? runningCommandIndex,
    bool clearRunningCommandIndex = false,
    String? message,
    bool? isSuccessMessage,
    SelfTestBleResponseSnapshot? lastSnapshot,
    bool clearLastSnapshot = false,
    SelfTestStationIdPrompt? stationIdPrompt,
    bool clearStationIdPrompt = false,
    SelfTestMeasurementTimePrompt? measurementTimePrompt,
    bool clearMeasurementTimePrompt = false,
    SelfTestTransmitterFrequencyPrompt? transmitterFrequencyPrompt,
    bool clearTransmitterFrequencyPrompt = false,
    SelfTestSetAttenuationPrompt? setAttenuationPrompt,
    bool clearSetAttenuationPrompt = false,
    SelfTestRadioSondeTransmitterIdPrompt? radioSondeTransmitterIdPrompt,
    bool clearRadioSondeTransmitterIdPrompt = false,
    SelfTestTransmitterTestPrompt? transmitterTestPrompt,
    bool clearTransmitterTestPrompt = false,
    SelfTestCheckStatusPrompt? checkStatusPrompt,
    bool clearCheckStatusPrompt = false,
  }) {
    return GeneralUserSelfTestDebugState(
      status: status ?? this.status,
      commands: commands ?? this.commands,
      runningCommandIndex: clearRunningCommandIndex
          ? null
          : (runningCommandIndex ?? this.runningCommandIndex),
      message: message ?? this.message,
      isSuccessMessage: isSuccessMessage ?? this.isSuccessMessage,
      lastSnapshot: clearLastSnapshot
          ? null
          : (lastSnapshot ?? this.lastSnapshot),
      stationIdPrompt: clearStationIdPrompt
          ? null
          : (stationIdPrompt ?? this.stationIdPrompt),
      measurementTimePrompt: clearMeasurementTimePrompt
          ? null
          : (measurementTimePrompt ?? this.measurementTimePrompt),
      transmitterFrequencyPrompt: clearTransmitterFrequencyPrompt
          ? null
          : (transmitterFrequencyPrompt ?? this.transmitterFrequencyPrompt),
      setAttenuationPrompt: clearSetAttenuationPrompt
          ? null
          : (setAttenuationPrompt ?? this.setAttenuationPrompt),
      radioSondeTransmitterIdPrompt: clearRadioSondeTransmitterIdPrompt
          ? null
          : (radioSondeTransmitterIdPrompt ?? this.radioSondeTransmitterIdPrompt),
      transmitterTestPrompt: clearTransmitterTestPrompt
          ? null
          : (transmitterTestPrompt ?? this.transmitterTestPrompt),
      checkStatusPrompt: clearCheckStatusPrompt
          ? null
          : (checkStatusPrompt ?? this.checkStatusPrompt),
    );
  }

  @override
  List<Object?> get props => [
        status,
        commands,
        runningCommandIndex,
        message,
        isSuccessMessage,
        lastSnapshot,
        stationIdPrompt,
        measurementTimePrompt,
        transmitterFrequencyPrompt,
        setAttenuationPrompt,
        radioSondeTransmitterIdPrompt,
        transmitterTestPrompt,
        checkStatusPrompt,
      ];
}
