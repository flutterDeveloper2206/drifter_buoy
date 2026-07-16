import 'package:drifter_buoy/features/general_user/data/models/drifter_buoy_command_model.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserSelfTestDebugStatus { initial, loading, loaded, running, error }

/// BLE/API success payload for dialogs or listeners.
class SelfTestBleResponseSnapshot extends Equatable {
  const SelfTestBleResponseSnapshot({
    required this.testName,
    required this.responseLine,
    required this.helpText,
    this.hideResponseLine = false,
    this.descriptionSuccess,
  });

  final String testName;
  final String responseLine;
  final String helpText;

  /// When true, the dialog omits the raw BLE response block.
  final bool hideResponseLine;

  /// When non-null, [helpText] is styled as success (true) or error (false).
  final bool? descriptionSuccess;

  @override
  List<Object?> get props => [
    testName,
    responseLine,
    helpText,
    hideResponseLine,
    descriptionSuccess,
  ];
}

class SelfTestStationIdPrompt extends Equatable {
  const SelfTestStationIdPrompt({
    required this.testName,
    required this.currentStationId,
    this.note = '',
  });

  final String testName;
  final String currentStationId;
  final String note;

  @override
  List<Object?> get props => [testName, currentStationId, note];
}

/// `?07` — station name field is 16 characters (space-padded on send).
class SelfTestStationNamePrompt extends Equatable {
  const SelfTestStationNamePrompt({
    required this.testName,
    required this.currentStationName,
    this.prefetchWarning,
    this.note = '',
  });

  final String testName;
  final String currentStationName;

  /// Non-fatal hint when `?04` prefetch did not yield a name.
  final String? prefetchWarning;
  final String note;

  @override
  List<Object?> get props => [testName, currentStationName, prefetchWarning, note];
}

/// `?61,HH:MM:SS,#` — dialog only (no `?04` prefetch); user enters time, then BLE send.
class SelfTestMeasurementTimePrompt extends Equatable {
  const SelfTestMeasurementTimePrompt({required this.testName, this.note = ''});

  final String testName;
  final String note;

  @override
  List<Object?> get props => [testName, note];
}

/// `?08,HH:MM:SS,#` — current time prefetched via `?63,,#`, then user confirms/edits.
class SelfTestTransmissionTimePrompt extends Equatable {
  const SelfTestTransmissionTimePrompt({
    required this.testName,
    this.currentTxTime = '',
    this.prefetchWarning,
    this.note = '',
  });

  final String testName;
  final String currentTxTime;
  final String? prefetchWarning;
  final String note;

  @override
  List<Object?> get props => [testName, currentTxTime, prefetchWarning, note];
}

/// `?09,HH:MM:SS,#` — Tx interval from `?04,,#` (3rd field), then user confirms/edits.
class SelfTestTransmissionIntervalPrompt extends Equatable {
  const SelfTestTransmissionIntervalPrompt({
    required this.testName,
    required this.currentTxInterval,
    this.prefetchWarning,
    this.catalogHelpText = '',
    this.note = '',
  });

  final String testName;
  final String currentTxInterval;
  final String? prefetchWarning;
  final String catalogHelpText;
  final String note;

  @override
  List<Object?> get props => [
    testName,
    currentTxInterval,
    prefetchWarning,
    catalogHelpText,
    note,
  ];
}

/// `?10,HH:MM:SS,#` — measurement interval prefetched from `?04,,#`.
class SelfTestMeasurementIntervalPrompt extends Equatable {
  const SelfTestMeasurementIntervalPrompt({
    required this.testName,
    required this.currentMeasurementInterval,
    this.prefetchWarning,
    this.catalogHelpText = '',
    this.note = '',
  });

  final String testName;
  final String currentMeasurementInterval;
  final String? prefetchWarning;
  final String catalogHelpText;
  final String note;

  @override
  List<Object?> get props => [
    testName,
    currentMeasurementInterval,
    prefetchWarning,
    catalogHelpText,
    note,
  ];
}

/// `?11,<APN>,<para2>,<para3>,#` — Para1 APN (max 31), Para2 0/Vodafone vs 1/other, Para3 1/SIM1 vs 2/SIM2.
class SelfTestSetApnPrompt extends Equatable {
  const SelfTestSetApnPrompt({
    required this.testName,
    required this.initialSim1Apn,
    required this.initialSim2Apn,
    this.prefetchWarning,
    this.catalogHelpText = '',
    this.note = '',
  });

  final String testName;

  /// Trimmed primary / secondary APN from `?04` (parameter indices 4 and 5).
  final String initialSim1Apn;
  final String initialSim2Apn;
  final String? prefetchWarning;
  final String catalogHelpText;
  final String note;

  @override
  List<Object?> get props => [
    testName,
    initialSim1Apn,
    initialSim2Apn,
    prefetchWarning,
    catalogHelpText,
    note,
  ];
}

/// `?58,N,#` — Fast SMS check prefetched from `?04` field index 6.
class SelfTestFastSmsCheckPrompt extends Equatable {
  const SelfTestFastSmsCheckPrompt({
    required this.testName,
    required this.enabled,
    this.prefetchWarning,
    this.catalogHelpText = '',
    this.note = '',
  });

  final String testName;

  /// `true` when device value is `1` (enable); `false` for `0` (disable).
  final bool enabled;
  final String? prefetchWarning;
  final String catalogHelpText;
  final String note;

  @override
  List<Object?> get props => [
    testName,
    enabled,
    prefetchWarning,
    catalogHelpText,
    note,
  ];
}

/// `?59` / `?60` — admin SMS cell prefetched from `?04` (indices 7 and 8).
class SelfTestAdminSmsCellPrompt extends Equatable {
  const SelfTestAdminSmsCellPrompt({
    required this.commandId,
    required this.testName,
    required this.initialMobileNumber,
    this.prefetchWarning,
    this.catalogHelpText = '',
    this.note = '',
  });

  final String commandId;
  final String testName;
  final String initialMobileNumber;
  final String? prefetchWarning;
  final String catalogHelpText;
  final String note;

  @override
  List<Object?> get props => [
    commandId,
    testName,
    initialMobileNumber,
    prefetchWarning,
    catalogHelpText,
    note,
  ];
}

class SelfTestTransmitterFrequencyPrompt extends Equatable {
  const SelfTestTransmitterFrequencyPrompt({
    required this.testName,
    required this.transmitterType,
    required this.frequencyValue,
    this.note = '',
  });

  final String testName;
  final int transmitterType;
  final String frequencyValue;
  final String note;

  @override
  List<Object?> get props => [testName, transmitterType, frequencyValue, note];
}

class SelfTestSetAttenuationPrompt extends Equatable {
  const SelfTestSetAttenuationPrompt({
    required this.testName,
    required this.transmitterType,
    required this.attenuationValue,
    this.note = '',
  });

  final String testName;
  final int transmitterType;
  final String attenuationValue;
  final String note;

  @override
  List<Object?> get props => [testName, transmitterType, attenuationValue, note];
}

class SelfTestRadioSondeTransmitterIdPrompt extends Equatable {
  const SelfTestRadioSondeTransmitterIdPrompt({
    required this.testName,
    required this.currentTransmitterId,
    this.note = '',
  });

  final String testName;
  final String currentTransmitterId;
  final String note;

  @override
  List<Object?> get props => [testName, currentTransmitterId, note];
}

/// `?99,N,HH:MM:SS,#` — UHF / Sonde transmission times (N 1–4).
class SelfTestUhfSondeTxInTimePrompt extends Equatable {
  const SelfTestUhfSondeTxInTimePrompt({
    required this.testName,
    required this.uhfStartTime,
    required this.uhfIntervalTime,
    required this.sondeStartTime,
    required this.sondeIntervalTime,
    this.prefetchWarning,
    this.note = '',
  });

  final String testName;
  final String uhfStartTime;
  final String uhfIntervalTime;
  final String sondeStartTime;
  final String sondeIntervalTime;
  final String? prefetchWarning;
  final String note;

  @override
  List<Object?> get props => [
    testName,
    uhfStartTime,
    uhfIntervalTime,
    sondeStartTime,
    sondeIntervalTime,
    prefetchWarning,
    note,
  ];
}

class SelfTestTransmitterTestPrompt extends Equatable {
  const SelfTestTransmitterTestPrompt({
    this.plainCarrierOn = false,
    this.modulationOn = false,
    this.prbsOn = false,
    this.note = '',
  });

  final bool plainCarrierOn;
  final bool modulationOn;
  final bool prbsOn;
  final String note;

  @override
  List<Object?> get props => [plainCarrierOn, modulationOn, prbsOn, note];
}

/// Field shape for primary/secondary server BLE commands from the command catalog.
enum SelfTestParameterizedCommandFieldKind {
  /// Max 20 chars, padded with trailing spaces for shorter values (FTP address, path, user, password).
  ftpField20,

  /// Port 0–65535 as 5 digits (leading zeros).
  portFiveDigits,

  /// `+91` + 10 digits (secondary SMS cell).
  smsCellPlus91,

  /// `0` = GSM and GPRS, `1` = GSM if GPRS fail.
  txRedundancy01,

  /// Battery voltage query index `00`–`11` for `?84,xx,#`.
  batteryVoltageIndex00to11,

  /// RTC HTTP website — trailing space appended when length is under 40 (catalog).
  rtcHttpWebsite128,

  /// RTC HTTP key — max 15 chars; trailing space when length is under 40 (catalog).
  rtcHttpKey15,

  /// Primary HTTP — HTTP field N (1–3: URL, key, data) plus website (max 128 chars).
  primaryHttpWebsiteIndex128,

  /// Secondary HTTP — HTTP field N (1–3: URL, key, data) plus website (max 128 chars).
  secondaryHttpWebsiteIndex0to3And128,

  /// Third HTTP (`?30`) — HTTP field N (1–3) plus website (max 128); trailing space when length &lt; 40 (catalog).
  thirdHttpWebsiteIndex0to3And128Trailing40,

  /// Factory HTTP (`?38`) — HTTP field N (1–3) plus website (max 128); trailing space when length &lt; 128 (catalog).
  factoryHttpWebsiteIndex0to3And128,

  /// HTTP server username (`?62`) — server N (1–4) plus username (max 64, padded).
  httpServerUsernameIndex1to4And64,

  /// DL cell / MSISDN (`?68`) — slot N (1–4) plus number (rules vary by N).
  dlCellNumberIndex1to4,

  /// Test mode (`?71`) — N = 0 or 1 (`?71,N,#`).
  testModeValue01,

  /// Power switching (`?76`) — numeric N (e.g. 20 → `?76,20,#`).
  powerSwitchingValueN,

  /// Set buoy offset (`?75`) — signed 4-digit value (`+1234` / `-1234`).
  setBuoyOffsetSignedFourDigits,

  /// Set HTTP port (`?98`) — server N (0–3) plus port PPPPP (0–65535, 5 digits).
  setHttpPortIndex1to4FiveDigits,

  /// Set HTTP password (`?97`) — server N (1–4) plus password (max 64, padded).
  setHttpPasswordIndex1to4And64,

  /// GET sensor parameter (`?83`) — sensor number (two digits, e.g. 01).
  getSensorParameter83SensorNumber,
}

/// Prompt for server/FTP/SMS commands that embed user input in `?NN,payload,#`.
class SelfTestParameterizedCommandPrompt extends Equatable {
  const SelfTestParameterizedCommandPrompt({
    required this.commandId,
    required this.testName,
    required this.fieldKind,
    this.requestCommand = '',
    this.requestHelpText = '',
    this.note = '',
  });

  final String commandId;
  final String testName;
  final SelfTestParameterizedCommandFieldKind fieldKind;

  /// Disambiguates duplicate Mongo ids (e.g. `?81` vs `?83` both use …994).
  final String requestCommand;

  /// Full request / field rules from the command catalog.
  final String requestHelpText;
  final String note;

  @override
  List<Object?> get props => [
    commandId,
    testName,
    fieldKind,
    requestCommand,
    requestHelpText,
    note,
  ];
}

/// Values shown in the **Set all general system parameters** (`?05`) form.
class SelfTestSetAllGeneralParametersDraft extends Equatable {
  const SelfTestSetAllGeneralParametersDraft({
    this.stationId = '',
    this.stationName = '',
    this.txInterval = '',
    this.measurementInterval = '',
    this.apn = '',
    this.fastSmsCheck = '',
    this.adminCell1 = '',
    this.adminCell2 = '',
    this.measurementStartTime = '',
  });

  final String stationId;
  final String stationName;
  final String txInterval;
  final String measurementInterval;
  final String apn;
  final String fastSmsCheck;
  final String adminCell1;
  final String adminCell2;
  final String measurementStartTime;

  @override
  List<Object?> get props => [
    stationId,
    stationName,
    txInterval,
    measurementInterval,
    apn,
    fastSmsCheck,
    adminCell1,
    adminCell2,
    measurementStartTime,
  ];
}

/// Opens the multi-field dialog for `?05,<nine fields>,#`.
class SelfTestSetAllGeneralParametersPrompt extends Equatable {
  const SelfTestSetAllGeneralParametersPrompt({
    required this.commandId,
    required this.testName,
    required this.initial,
    this.prefetchWarning,
    this.catalogHelpText = '',
    this.note = '',
  });

  final String commandId;
  final String testName;
  final SelfTestSetAllGeneralParametersDraft initial;

  /// When set (e.g. `?04` prefetch failed), show non-blocking hint above the form.
  final String? prefetchWarning;

  /// Catalog `requestCommandDescription` / example line for this row.
  final String catalogHelpText;
  final String note;

  @override
  List<Object?> get props => [
    commandId,
    testName,
    initial,
    prefetchWarning,
    catalogHelpText,
    note,
  ];
}

/// Values shown in the **Set all server FTP/HTTP parameters** (`?46`–`?49`) form.
class SelfTestSetAllServerParametersDraft extends Equatable {
  const SelfTestSetAllServerParametersDraft({
    this.stationId = '',
    this.ftpAddress = '',
    this.ftpPort = '',
    this.ftpPath = '',
    this.ftpUsername = '',
    this.ftpPassword = '',
    this.cellNo = '',
    this.txRedundancy = 0,
  });

  final String stationId;
  final String ftpAddress;
  final String ftpPort;
  final String ftpPath;
  final String ftpUsername;
  final String ftpPassword;
  final String cellNo;
  final int txRedundancy;

  @override
  List<Object?> get props => [
    stationId,
    ftpAddress,
    ftpPort,
    ftpPath,
    ftpUsername,
    ftpPassword,
    cellNo,
    txRedundancy,
  ];
}

/// Opens the multi-field dialog for `?46`–`?49`.
class SelfTestSetAllServerParametersPrompt extends Equatable {
  const SelfTestSetAllServerParametersPrompt({
    required this.commandId,
    required this.testName,
    required this.initial,
    this.prefetchWarning,
    this.catalogHelpText = '',
    this.note = '',
  });

  final String commandId;
  final String testName;
  final SelfTestSetAllServerParametersDraft initial;
  final String? prefetchWarning;
  final String catalogHelpText;
  final String note;

  @override
  List<Object?> get props => [
    commandId,
    testName,
    initial,
    prefetchWarning,
    catalogHelpText,
    note,
  ];
}

/// Opens a confirmation dialog before **Restore Default Parameters** (`?03,,#`).
class SelfTestRestoreDefaultParametersPrompt extends Equatable {
  const SelfTestRestoreDefaultParametersPrompt({
    required this.commandId,
    required this.testName,
    this.catalogHelpText = '',
    this.note = '',
  });

  final String commandId;
  final String testName;
  final String catalogHelpText;
  final String note;

  @override
  List<Object?> get props => [commandId, testName, catalogHelpText, note];
}

/// Opens a confirmation dialog before restore commands `?54`–`?57`.
class SelfTestRestoreServerParametersPrompt extends Equatable {
  const SelfTestRestoreServerParametersPrompt({
    required this.commandId,
    required this.testName,
    this.catalogHelpText = '',
    this.note = '',
  });

  final String commandId;
  final String testName;
  final String catalogHelpText;
  final String note;

  @override
  List<Object?> get props => [commandId, testName, catalogHelpText, note];
}

/// Field values for **SET Sensor ALL parameter** (`?80`).
class SelfTestSetSensorAllParametersDraft extends Equatable {
  const SelfTestSetSensorAllParametersDraft({
    this.sensorNo = '01',
    this.channelNo = '20',
    this.fg = '00003.81475',
    this.factoryOff = '+00000.00000',
    this.senG = '+00001.00000',
    this.soff = '+00000.00000',
    this.resolution = '00000.00100',
    this.senMin = '-00040.00000',
    this.sensMax = '+00060.00000',
    this.averagScheme = '0',
    this.Vector = '00',
    this.startTime = '00:59:07',
    this.interval = '01:00:00',
    this.totalSample = '01',
    this.mode = '1',
    this.txG = '+00010.00000',
    this.txO = '+00400.00000',
  });

  final String sensorNo;
  final String channelNo;
  final String fg;
  final String factoryOff;
  final String senG;
  final String soff;
  final String resolution;
  final String senMin;
  final String sensMax;
  final String averagScheme;
  final String Vector;
  final String startTime;
  final String interval;
  final String totalSample;
  final String mode;
  final String txG;
  final String txO;

  @override
  List<Object?> get props => [
    sensorNo,
    channelNo,
    fg,
    factoryOff,
    senG,
    soff,
    resolution,
    senMin,
    sensMax,
    averagScheme,
    Vector,
    startTime,
    interval,
    totalSample,
    mode,
    txG,
    txO,
  ];
}

/// Opens the multi-field dialog for `?80`.
class SelfTestSetSensorAllParametersPrompt extends Equatable {
  const SelfTestSetSensorAllParametersPrompt({
    required this.testName,
    required this.initial,
    this.catalogHelpText = '',
    this.note = '',
  });

  final String testName;
  final SelfTestSetSensorAllParametersDraft initial;
  final String catalogHelpText;
  final String note;

  @override
  List<Object?> get props => [testName, initial, catalogHelpText, note];
}

/// Field values for **SET sensors parameters** (`?82`).
class SelfTestSetSensorsParametersDraft extends Equatable {
  const SelfTestSetSensorsParametersDraft({
    this.sensorNo = '00',
    this.unit = '02',
    this.senSelStatus = '0',
    this.baudRate = '5',
    this.reqLen = '11',
    this.startChar = '<',
    this.fp = '09',
    this.lp = '13',
    this.respLen = '22',
    this.relayNo = '2',
    this.periodicSmpl = '0',
    this.derievedPara = '0',
    this.requestString = '12345678912345678',
    this.sensorName = '1234567891234567',
    this.id = '01',
    this.model = '20',
    this.rstcnt = '0',
    this.datum = '0000',
    this.decLen = '8',
    this.fracLen = '6',
    this.maxThreshold = '+00000.00000',
    this.minThreshold = '+00000.00000',
  });

  final String sensorNo;
  final String unit;
  final String senSelStatus;
  final String baudRate;
  final String reqLen;
  final String startChar;
  final String fp;
  final String lp;
  final String respLen;
  final String relayNo;
  final String periodicSmpl;
  final String derievedPara;
  final String requestString;
  final String sensorName;
  final String id;
  final String model;
  final String rstcnt;
  final String datum;
  final String decLen;
  final String fracLen;
  final String maxThreshold;
  final String minThreshold;

  @override
  List<Object?> get props => [
    sensorNo,
    unit,
    senSelStatus,
    baudRate,
    reqLen,
    startChar,
    fp,
    lp,
    respLen,
    relayNo,
    periodicSmpl,
    derievedPara,
    requestString,
    sensorName,
    id,
    model,
    rstcnt,
    datum,
    decLen,
    fracLen,
    maxThreshold,
    minThreshold,
  ];
}

/// Opens the multi-field dialog for `?82`.
class SelfTestSetSensorsParametersPrompt extends Equatable {
  const SelfTestSetSensorsParametersPrompt({
    required this.testName,
    required this.initial,
    this.catalogHelpText = '',
    this.note = '',
  });

  final String testName;
  final SelfTestSetSensorsParametersDraft initial;
  final String catalogHelpText;
  final String note;

  @override
  List<Object?> get props => [testName, initial, catalogHelpText, note];
}

/// Field values for **Set individual sensor parameter** (`?86`).
class SelfTestSetIndividualSensorParameterDraft extends Equatable {
  const SelfTestSetIndividualSensorParameterDraft({
    this.sensorNo = '',
    this.paraNo = '',
    this.value = '',
  });

  final String sensorNo;
  final String paraNo;
  final String value;

  @override
  List<Object?> get props => [sensorNo, paraNo, value];
}

/// Opens the dialog for `?86` (Sensor Para Set).
class SelfTestSetIndividualSensorParameterPrompt extends Equatable {
  const SelfTestSetIndividualSensorParameterPrompt({
    required this.testName,
    required this.initial,
    this.catalogHelpText = '',
    this.note = '',
  });

  final String testName;
  final SelfTestSetIndividualSensorParameterDraft initial;
  final String catalogHelpText;
  final String note;

  @override
  List<Object?> get props => [testName, initial, catalogHelpText, note];
}

class SelfTestCheckStatusPrompt extends Equatable {
  const SelfTestCheckStatusPrompt({
    required this.testName,
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
  });

  final String testName;
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

  @override
  List<Object?> get props => [
    testName,
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
  final SelfTestStationNamePrompt? stationNamePrompt;
  final SelfTestMeasurementTimePrompt? measurementTimePrompt;
  final SelfTestTransmissionTimePrompt? transmissionTimePrompt;
  final SelfTestTransmissionIntervalPrompt? transmissionIntervalPrompt;
  final SelfTestMeasurementIntervalPrompt? measurementIntervalPrompt;
  final SelfTestSetApnPrompt? setApnPrompt;
  final SelfTestFastSmsCheckPrompt? fastSmsCheckPrompt;
  final SelfTestAdminSmsCellPrompt? adminSmsCellPrompt;
  final SelfTestTransmitterFrequencyPrompt? transmitterFrequencyPrompt;
  final SelfTestSetAttenuationPrompt? setAttenuationPrompt;
  final SelfTestRadioSondeTransmitterIdPrompt? radioSondeTransmitterIdPrompt;
  final SelfTestUhfSondeTxInTimePrompt? uhfSondeTxInTimePrompt;
  final SelfTestTransmitterTestPrompt? transmitterTestPrompt;
  final SelfTestCheckStatusPrompt? checkStatusPrompt;
  final SelfTestParameterizedCommandPrompt? parameterizedCommandPrompt;
  final SelfTestSetAllGeneralParametersPrompt? setAllGeneralParametersPrompt;
  final SelfTestSetAllServerParametersPrompt? setAllServerParametersPrompt;
  final SelfTestRestoreDefaultParametersPrompt? restoreDefaultParametersPrompt;
  final SelfTestRestoreServerParametersPrompt? restoreServerParametersPrompt;
  final SelfTestSetSensorAllParametersPrompt? setSensorAllParametersPrompt;
  final SelfTestSetSensorsParametersPrompt? setSensorsParametersPrompt;
  final SelfTestSetIndividualSensorParameterPrompt?
  setIndividualSensorParameterPrompt;

  const GeneralUserSelfTestDebugState({
    required this.status,
    required this.commands,
    required this.runningCommandIndex,
    required this.message,
    required this.isSuccessMessage,
    required this.lastSnapshot,
    required this.stationIdPrompt,
    required this.stationNamePrompt,
    required this.measurementTimePrompt,
    required this.transmissionTimePrompt,
    required this.transmissionIntervalPrompt,
    required this.measurementIntervalPrompt,
    required this.setApnPrompt,
    required this.fastSmsCheckPrompt,
    required this.adminSmsCellPrompt,
    required this.transmitterFrequencyPrompt,
    required this.setAttenuationPrompt,
    required this.radioSondeTransmitterIdPrompt,
    required this.uhfSondeTxInTimePrompt,
    required this.transmitterTestPrompt,
    required this.checkStatusPrompt,
    required this.parameterizedCommandPrompt,
    required this.setAllGeneralParametersPrompt,
    required this.setAllServerParametersPrompt,
    required this.restoreDefaultParametersPrompt,
    required this.restoreServerParametersPrompt,
    required this.setSensorAllParametersPrompt,
    required this.setSensorsParametersPrompt,
    required this.setIndividualSensorParameterPrompt,
  });

  const GeneralUserSelfTestDebugState.initial()
    : status = GeneralUserSelfTestDebugStatus.initial,
      commands = const [],
      runningCommandIndex = null,
      message = '',
      isSuccessMessage = false,
      lastSnapshot = null,
      stationIdPrompt = null,
      stationNamePrompt = null,
      measurementTimePrompt = null,
      transmissionTimePrompt = null,
      transmissionIntervalPrompt = null,
      measurementIntervalPrompt = null,
      setApnPrompt = null,
      fastSmsCheckPrompt = null,
      adminSmsCellPrompt = null,
      transmitterFrequencyPrompt = null,
      setAttenuationPrompt = null,
      radioSondeTransmitterIdPrompt = null,
      uhfSondeTxInTimePrompt = null,
      transmitterTestPrompt = null,
      checkStatusPrompt = null,
      parameterizedCommandPrompt = null,
      setAllGeneralParametersPrompt = null,
      setAllServerParametersPrompt = null,
      restoreDefaultParametersPrompt = null,
      restoreServerParametersPrompt = null,
      setSensorAllParametersPrompt = null,
      setSensorsParametersPrompt = null,
      setIndividualSensorParameterPrompt = null;

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
    SelfTestStationNamePrompt? stationNamePrompt,
    bool clearStationNamePrompt = false,
    SelfTestMeasurementTimePrompt? measurementTimePrompt,
    bool clearMeasurementTimePrompt = false,
    SelfTestTransmissionTimePrompt? transmissionTimePrompt,
    bool clearTransmissionTimePrompt = false,
    SelfTestTransmissionIntervalPrompt? transmissionIntervalPrompt,
    bool clearTransmissionIntervalPrompt = false,
    SelfTestMeasurementIntervalPrompt? measurementIntervalPrompt,
    bool clearMeasurementIntervalPrompt = false,
    SelfTestSetApnPrompt? setApnPrompt,
    bool clearSetApnPrompt = false,
    SelfTestFastSmsCheckPrompt? fastSmsCheckPrompt,
    bool clearFastSmsCheckPrompt = false,
    SelfTestAdminSmsCellPrompt? adminSmsCellPrompt,
    bool clearAdminSmsCellPrompt = false,
    SelfTestTransmitterFrequencyPrompt? transmitterFrequencyPrompt,
    bool clearTransmitterFrequencyPrompt = false,
    SelfTestSetAttenuationPrompt? setAttenuationPrompt,
    bool clearSetAttenuationPrompt = false,
    SelfTestRadioSondeTransmitterIdPrompt? radioSondeTransmitterIdPrompt,
    bool clearRadioSondeTransmitterIdPrompt = false,
    SelfTestUhfSondeTxInTimePrompt? uhfSondeTxInTimePrompt,
    bool clearUhfSondeTxInTimePrompt = false,
    SelfTestTransmitterTestPrompt? transmitterTestPrompt,
    bool clearTransmitterTestPrompt = false,
    SelfTestCheckStatusPrompt? checkStatusPrompt,
    bool clearCheckStatusPrompt = false,
    SelfTestParameterizedCommandPrompt? parameterizedCommandPrompt,
    bool clearParameterizedCommandPrompt = false,
    SelfTestSetAllGeneralParametersPrompt? setAllGeneralParametersPrompt,
    bool clearSetAllGeneralParametersPrompt = false,
    SelfTestSetAllServerParametersPrompt? setAllServerParametersPrompt,
    bool clearSetAllServerParametersPrompt = false,
    SelfTestRestoreDefaultParametersPrompt? restoreDefaultParametersPrompt,
    bool clearRestoreDefaultParametersPrompt = false,
    SelfTestRestoreServerParametersPrompt? restoreServerParametersPrompt,
    bool clearRestoreServerParametersPrompt = false,
    SelfTestSetSensorAllParametersPrompt? setSensorAllParametersPrompt,
    bool clearSetSensorAllParametersPrompt = false,
    SelfTestSetSensorsParametersPrompt? setSensorsParametersPrompt,
    bool clearSetSensorsParametersPrompt = false,
    SelfTestSetIndividualSensorParameterPrompt?
    setIndividualSensorParameterPrompt,
    bool clearSetIndividualSensorParameterPrompt = false,
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
      stationNamePrompt: clearStationNamePrompt
          ? null
          : (stationNamePrompt ?? this.stationNamePrompt),
      measurementTimePrompt: clearMeasurementTimePrompt
          ? null
          : (measurementTimePrompt ?? this.measurementTimePrompt),
      transmissionTimePrompt: clearTransmissionTimePrompt
          ? null
          : (transmissionTimePrompt ?? this.transmissionTimePrompt),
      transmissionIntervalPrompt: clearTransmissionIntervalPrompt
          ? null
          : (transmissionIntervalPrompt ?? this.transmissionIntervalPrompt),
      measurementIntervalPrompt: clearMeasurementIntervalPrompt
          ? null
          : (measurementIntervalPrompt ?? this.measurementIntervalPrompt),
      setApnPrompt: clearSetApnPrompt
          ? null
          : (setApnPrompt ?? this.setApnPrompt),
      fastSmsCheckPrompt: clearFastSmsCheckPrompt
          ? null
          : (fastSmsCheckPrompt ?? this.fastSmsCheckPrompt),
      adminSmsCellPrompt: clearAdminSmsCellPrompt
          ? null
          : (adminSmsCellPrompt ?? this.adminSmsCellPrompt),
      transmitterFrequencyPrompt: clearTransmitterFrequencyPrompt
          ? null
          : (transmitterFrequencyPrompt ?? this.transmitterFrequencyPrompt),
      setAttenuationPrompt: clearSetAttenuationPrompt
          ? null
          : (setAttenuationPrompt ?? this.setAttenuationPrompt),
      radioSondeTransmitterIdPrompt: clearRadioSondeTransmitterIdPrompt
          ? null
          : (radioSondeTransmitterIdPrompt ??
                this.radioSondeTransmitterIdPrompt),
      uhfSondeTxInTimePrompt: clearUhfSondeTxInTimePrompt
          ? null
          : (uhfSondeTxInTimePrompt ?? this.uhfSondeTxInTimePrompt),
      transmitterTestPrompt: clearTransmitterTestPrompt
          ? null
          : (transmitterTestPrompt ?? this.transmitterTestPrompt),
      checkStatusPrompt: clearCheckStatusPrompt
          ? null
          : (checkStatusPrompt ?? this.checkStatusPrompt),
      parameterizedCommandPrompt: clearParameterizedCommandPrompt
          ? null
          : (parameterizedCommandPrompt ?? this.parameterizedCommandPrompt),
      setAllGeneralParametersPrompt: clearSetAllGeneralParametersPrompt
          ? null
          : (setAllGeneralParametersPrompt ??
                this.setAllGeneralParametersPrompt),
      setAllServerParametersPrompt: clearSetAllServerParametersPrompt
          ? null
          : (setAllServerParametersPrompt ?? this.setAllServerParametersPrompt),
      restoreDefaultParametersPrompt: clearRestoreDefaultParametersPrompt
          ? null
          : (restoreDefaultParametersPrompt ??
                this.restoreDefaultParametersPrompt),
      restoreServerParametersPrompt: clearRestoreServerParametersPrompt
          ? null
          : (restoreServerParametersPrompt ??
                this.restoreServerParametersPrompt),
      setSensorAllParametersPrompt: clearSetSensorAllParametersPrompt
          ? null
          : (setSensorAllParametersPrompt ?? this.setSensorAllParametersPrompt),
      setSensorsParametersPrompt: clearSetSensorsParametersPrompt
          ? null
          : (setSensorsParametersPrompt ?? this.setSensorsParametersPrompt),
      setIndividualSensorParameterPrompt:
          clearSetIndividualSensorParameterPrompt
          ? null
          : (setIndividualSensorParameterPrompt ??
                this.setIndividualSensorParameterPrompt),
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
    stationNamePrompt,
    measurementTimePrompt,
    transmissionTimePrompt,
    transmissionIntervalPrompt,
    measurementIntervalPrompt,
    setApnPrompt,
    fastSmsCheckPrompt,
    adminSmsCellPrompt,
    transmitterFrequencyPrompt,
    setAttenuationPrompt,
    radioSondeTransmitterIdPrompt,
    uhfSondeTxInTimePrompt,
    transmitterTestPrompt,
    checkStatusPrompt,
    parameterizedCommandPrompt,
    setAllGeneralParametersPrompt,
    setAllServerParametersPrompt,
    restoreDefaultParametersPrompt,
    restoreServerParametersPrompt,
    setSensorAllParametersPrompt,
    setSensorsParametersPrompt,
    setIndividualSensorParameterPrompt,
  ];
}
