import 'dart:async';
import 'dart:convert';

import 'package:drifter_buoy/core/bluetooth/ble_connection_service.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_self_test_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/models/drifter_buoy_command_model.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserSelfTestDebugBloc
    extends Bloc<GeneralUserSelfTestDebugEvent, GeneralUserSelfTestDebugState> {
  GeneralUserSelfTestDebugBloc({
    required GeneralUserSelfTestRemoteDataSource remoteDataSource,
    required BleConnectionService ble,
  }) : _remote = remoteDataSource,
       _ble = ble,
       super(const GeneralUserSelfTestDebugState.initial()) {
    on<LoadGeneralUserSelfTestDebug>(_onLoadGeneralUserSelfTestDebug);
    on<RunGeneralUserSelfTestDebugAction>(_onRunGeneralUserSelfTestDebugAction);
    on<ClearGeneralUserSelfTestDebugMessage>(
      _onClearGeneralUserSelfTestDebugMessage,
    );
    on<SubmitGeneralUserSetStationId>(_onSubmitGeneralUserSetStationId);
    on<ClearGeneralUserSetStationIdPrompt>(
      _onClearGeneralUserSetStationIdPrompt,
    );
    on<SubmitGeneralUserSetStationName>(_onSubmitGeneralUserSetStationName);
    on<ClearGeneralUserSetStationNamePrompt>(
      _onClearGeneralUserSetStationNamePrompt,
    );
    on<SubmitGeneralUserMeasurementStartTime>(
      _onSubmitGeneralUserMeasurementStartTime,
    );
    on<ClearGeneralUserMeasurementStartTimePrompt>(
      _onClearGeneralUserMeasurementStartTimePrompt,
    );
    on<SubmitGeneralUserSetTransmissionTime>(
      _onSubmitGeneralUserSetTransmissionTime,
    );
    on<ClearGeneralUserTransmissionTimePrompt>(
      _onClearGeneralUserTransmissionTimePrompt,
    );
    on<SubmitGeneralUserSetTransmissionInterval>(
      _onSubmitGeneralUserSetTransmissionInterval,
    );
    on<ClearGeneralUserTransmissionIntervalPrompt>(
      _onClearGeneralUserTransmissionIntervalPrompt,
    );
    on<SubmitGeneralUserSetMeasurementInterval>(
      _onSubmitGeneralUserSetMeasurementInterval,
    );
    on<ClearGeneralUserMeasurementIntervalPrompt>(
      _onClearGeneralUserMeasurementIntervalPrompt,
    );
    on<SubmitGeneralUserSetApn>(_onSubmitGeneralUserSetApn);
    on<ClearGeneralUserSetApnPrompt>(_onClearGeneralUserSetApnPrompt);
    on<SubmitGeneralUserFastSmsCheck>(_onSubmitGeneralUserFastSmsCheck);
    on<ClearGeneralUserFastSmsCheckPrompt>(
      _onClearGeneralUserFastSmsCheckPrompt,
    );
    on<SubmitGeneralUserAdminSmsCell>(_onSubmitGeneralUserAdminSmsCell);
    on<ClearGeneralUserAdminSmsCellPrompt>(
      _onClearGeneralUserAdminSmsCellPrompt,
    );
    on<SubmitGeneralUserTransmitterFrequency>(
      _onSubmitGeneralUserTransmitterFrequency,
    );
    on<ClearGeneralUserTransmitterFrequencyPrompt>(
      _onClearGeneralUserTransmitterFrequencyPrompt,
    );
    on<SubmitGeneralUserSetAttenuation>(_onSubmitGeneralUserSetAttenuation);
    on<ClearGeneralUserSetAttenuationPrompt>(
      _onClearGeneralUserSetAttenuationPrompt,
    );
    on<SubmitGeneralUserRadioSondeTransmitterId>(
      _onSubmitGeneralUserRadioSondeTransmitterId,
    );
    on<ClearGeneralUserRadioSondeTransmitterIdPrompt>(
      _onClearGeneralUserRadioSondeTransmitterIdPrompt,
    );
    on<SubmitGeneralUserTransmitterTest>(_onSubmitGeneralUserTransmitterTest);
    on<ClearGeneralUserTransmitterTestPrompt>(
      _onClearGeneralUserTransmitterTestPrompt,
    );
    on<ClearGeneralUserCheckStatusPrompt>(_onClearGeneralUserCheckStatusPrompt);
    on<NotifyBlePeripheralDisconnected>(_onNotifyBlePeripheralDisconnected);
    on<SubmitGeneralUserParameterizedCommand>(
      _onSubmitGeneralUserParameterizedCommand,
    );
    on<ClearGeneralUserParameterizedCommandPrompt>(
      _onClearGeneralUserParameterizedCommandPrompt,
    );
    on<SubmitGeneralUserRestoreDefaultParameters>(
      _onSubmitGeneralUserRestoreDefaultParameters,
    );
    on<ClearGeneralUserRestoreDefaultParametersPrompt>(
      _onClearGeneralUserRestoreDefaultParametersPrompt,
    );
    on<SubmitGeneralUserSetAllGeneralParameters>(
      _onSubmitGeneralUserSetAllGeneralParameters,
    );
    on<ClearGeneralUserSetAllGeneralParametersPrompt>(
      _onClearGeneralUserSetAllGeneralParametersPrompt,
    );
    on<SubmitGeneralUserRestoreServerParameters>(
      _onSubmitGeneralUserRestoreServerParameters,
    );
    on<ClearGeneralUserRestoreServerParametersPrompt>(
      _onClearGeneralUserRestoreServerParametersPrompt,
    );
    on<SubmitGeneralUserSetSensorAllParameters>(
      _onSubmitGeneralUserSetSensorAllParameters,
    );
    on<ClearGeneralUserSetSensorAllParametersPrompt>(
      _onClearGeneralUserSetSensorAllParametersPrompt,
    );
    on<SubmitGeneralUserSetSensorsParameters>(
      _onSubmitGeneralUserSetSensorsParameters,
    );
    on<ClearGeneralUserSetSensorsParametersPrompt>(
      _onClearGeneralUserSetSensorsParametersPrompt,
    );
    _disconnectSub = _ble.disconnectedRemoteIds.listen((_) {
      add(const NotifyBlePeripheralDisconnected());
    });
  }

  final GeneralUserSelfTestRemoteDataSource _remote;
  final BleConnectionService _ble;
  StreamSubscription<String>? _disconnectSub;

  /// Command document ids — source: Command reposne BLE sheet CSV.
  /// Order matches [_staticCommands].
  static const String _manualRtcUpdateCommandId = '6a04547227be22811320699c';
  static const String _manualDataAcquistionPollCommandId =
      '6a04547227be22811320699a';
  static const String _transmitterTestCommandId = '6a04547227be228113206988';
  static const String _setTransmissionTimeCommandId =
      '6a04547227be228113206950';
  static const String _eraseMemoryCommandId = '6a04547227be22811320699d';
  static const String _restoreDefaultParametersCommandId =
      '6a04547227be22811320694b';
  static const String _setMeasurementIntervalCommandId =
      '6a04547227be228113206952';
  static const String _measurementStartTimeCommandId =
      '6a04547227be228113206985';
  static const String _checkStatusCommandId = '6a04547227be22811320694a';
  static const String _setAllGeneralSystemParametersCommandId =
      '6a04547227be22811320694d';

  /// Embedded in [SubmitGeneralUserParameterizedCommand.value] for the
  /// multi-field “set all general” (`?05`) dialog — avoids relying on a separate
  /// event type that may not match after hot reload.
  static const String setAllGeneralParametersPayloadPrefix =
      '__drifterSetAllGeneral__';

  /// Clears [GeneralUserSelfTestDebugState.setAllGeneralParametersPrompt] after
  /// the dialog closes; sent as [SubmitGeneralUserParameterizedCommand.value].
  static const String setAllGeneralParametersClearPromptMarker =
      '__drifterClearSetAllGeneralPrompt__';
  static const String setAllServerParametersPayloadPrefix =
      '__drifterSetAllServer__';
  static const String setAllServerParametersClearPromptMarker =
      '__drifterClearSetAllServerPrompt__';
  static const String _getAllGeneralSystemParametersCommandId =
      '6a04547227be22811320694c';

  /// Sheet Mongo id; BLE opcode is determined by [DrifterBuoyCommandModel.requestCommand] (`?06,`).
  static const String _setStationIdCommandId = '6a04547227be22811320694e';

  /// Sheet Mongo id; BLE opcode is determined by `requestCommand` (`?07,`).
  static const String _setStationNameCommandId = '6a04547227be22811320694f';
  static const String _setTransmissionIntervalCommandId =
      '6a04547227be228113206951';
  static const String _setApnCommandId = '6a04547227be228113206953';
  static const String _setRtcServerHttpWebsiteAddressCommandId =
      '6a04547227be228113206954';
  static const String _setRtcServerHttpWebsiteKeyCommandId =
      '6a04547227be228113206955';
  static const String _primaryServerHttpWebsiteAddressCommandId =
      '6a04547227be228113206956';
  static const String _primaryServerFtpAddressCommandId =
      '6a04547227be228113206957';
  static const String _primaryServerFtpPortCommandId =
      '6a04547227be228113206958';
  static const String _primaryServerFtpPathCommandId =
      '6a04547227be228113206959';
  static const String _primaryServerFtpUsernameCommandId =
      '6a04547227be22811320695a';
  static const String _primaryServerFtpPasswordCommandId =
      '6a04547227be22811320695b';
  static const String _primaryServerSmsCellNoCommandId =
      '6a04547227be22811320695c';
  static const String _primaryServerTxMediaRedundancyCommandId =
      '6a04547227be22811320695d';
  static const String _secondaryServerHttpWebsiteAddressCommandId =
      '6a04547227be22811320695e';
  static const String _secondaryServerFtpAddressCommandId =
      '6a04547227be22811320695f';
  static const String _secondaryServerFtpPortCommandId =
      '6a04547227be228113206960';
  static const String _secondaryServerFtpPathCommandId =
      '6a04547227be228113206961';
  static const String _secondaryServerFtpUsernameCommandId =
      '6a04547227be228113206962';
  static const String _secondaryServerFtpPasswordCommandId =
      '6a04547227be228113206963';
  static const String _secondaryServerSmsCellNoCommandId =
      '6a04547227be228113206964';
  static const String _secondaryServerTxMediaRedundancyCommandId =
      '6a04547227be228113206965';
  static const String _thirdServerHttpWebsiteAddressCommandId =
      '6a04547227be228113206966';
  static const String _thirdServerFtpAddressCommandId =
      '6a04547227be228113206967';
  static const String _thirdServerFtpPortNoCommandId =
      '6a04547227be228113206968';
  static const String _thirdServerFtpPathCommandId = '6a04547227be228113206969';
  static const String _thirdServerFtpUsernameCommandId =
      '6a04547227be22811320696a';
  static const String _thirdServerFtpPasswordCommandId =
      '6a04547227be22811320696b';
  static const String _setThirdServerSmsCellNoCommandId =
      '6a04547227be22811320696c';
  static const String _thirdServerTxMediaRedundancyCommandId =
      '6a04547227be22811320696d';
  static const String _factoryServerHttpWebsiteAddressCommandId =
      '6a04547227be22811320696e';
  static const String _factoryServerFtpAddressCommandId =
      '6a04547227be22811320696f';
  static const String _factoryServerFtpPortNoCommandId =
      '6a04547227be228113206970';
  static const String _factoryServerFtpPathCommandId =
      '6a04547227be228113206971';
  static const String _factoryServerFtpUsernameCommandId =
      '6a04547227be228113206972';
  static const String _factoryServerFtpPasswordCommandId =
      '6a04547227be228113206973';
  static const String _setFactoryServerSmsCellNoCommandId =
      '6a04547227be228113206974';
  static const String _factoryServerTxMediaRedundancyCommandId =
      '6a04547227be228113206975';
  static const String _setPrimaryServerAllFtpHttpParametersCommandId =
      '6a04547227be228113206976';
  static const String _setSecondaryServerAllFtpHttpParametersCommandId =
      '6a04547227be228113206977';
  static const String _setThirdServerAllFtpHttpParametersCommandId =
      '6a04547227be228113206978';
  static const String _setFactoryServerAllFtpHttpParametersCommandId =
      '6a04547227be228113206979';
  static const String _getPrimaryServerAllFtpHttpParametersCommandId =
      '6a04547227be22811320697a';
  static const String _getSecondaryServerAllFtpHttpParametersCommandId =
      '6a04547227be22811320697b';
  static const String _getThirdServerAllFtpHttpParametersCommandId =
      '6a04547227be22811320697c';
  static const String _getFactoryServerAllFtpHttpParametersCommandId =
      '6a04547227be22811320697d';
  static const Set<String> _setAllServerCommandIds = {
    _setPrimaryServerAllFtpHttpParametersCommandId,
    _setSecondaryServerAllFtpHttpParametersCommandId,
    _setThirdServerAllFtpHttpParametersCommandId,
    _setFactoryServerAllFtpHttpParametersCommandId,
  };
  static const Set<String> _restoreAllServerCommandIds = {
    _restorePrimaryServerAllFtpHttpParametersCommandId,
    _restoreSecondaryServerAllFtpHttpParametersCommandId,
    _restoreThirdServerAllFtpHttpParametersCommandId,
    _restoreFactoryServerAllFtpHttpParametersCommandId,
  };
  static const Map<String, String> _setAllToGetServerCommandId = {
    _setPrimaryServerAllFtpHttpParametersCommandId:
        _getPrimaryServerAllFtpHttpParametersCommandId,
    _setSecondaryServerAllFtpHttpParametersCommandId:
        _getSecondaryServerAllFtpHttpParametersCommandId,
    _setThirdServerAllFtpHttpParametersCommandId:
        _getThirdServerAllFtpHttpParametersCommandId,
    _setFactoryServerAllFtpHttpParametersCommandId:
        _getFactoryServerAllFtpHttpParametersCommandId,
  };
  static const Set<String> _getAllServerCommandIds = {
    _getPrimaryServerAllFtpHttpParametersCommandId,
    _getSecondaryServerAllFtpHttpParametersCommandId,
    _getThirdServerAllFtpHttpParametersCommandId,
    _getFactoryServerAllFtpHttpParametersCommandId,
  };
  static const String _restorePrimaryServerAllFtpHttpParametersCommandId =
      '6a04547227be22811320697e';
  static const String _restoreSecondaryServerAllFtpHttpParametersCommandId =
      '6a04547227be22811320697f';
  static const String _restoreThirdServerAllFtpHttpParametersCommandId =
      '6a04547227be228113206980';
  static const String _restoreFactoryServerAllFtpHttpParametersCommandId =
      '6a04547227be228113206981';
  static const String _fastSmsCheckCommandId = '6a04547227be228113206982';
  static const String _setAdmin1SmsCellNoCommandId = '6a04547227be228113206983';
  static const String _setAdmin2SmsCellNoCommandId = '6a04547227be228113206984';
  static const String _httpServerUsernameCommandId = '6a04547227be228113206986';
  static const String _getTransmissionStartTimeGprsCommandId =
      '6a04547227be228113206987';
  static const String _transmitterFrequencyCommandId =
      '6a04547227be228113206989';
  static const String _setAttenuationCommandId = '6a04547227be22811320698a';
  static const String _radioSondeTransmitterIdCommandId =
      '6a04547227be22811320698b';
  static const String _setDlCellNoCommandId = '6a04547227be22811320698c';
  static const String _testModeCommandId = '6a04547227be22811320698d';
  static const String _powerSwitchingCommandId = '6a04547227be22811320698e';
  static const String _simCardTestCommandId = '6a04547227be22811320698f';
  static const String _sleepCurrentTestCommandId = '6a04547227be228113206990';
  static const String _setSensorAllParameterCommandId =
      '6a04547227be228113206991';
  static const String _setSensorsParametersCommandId =
      '6a04547227be228113206993';
  static const String _getSensorParameterCommandId = '6a04547227be228113206994';
  static const String _getSensorParameter83CommandId =
      '6a04547227be228113206994';
  static const String _batteryVoltageCommandId = '6a04547227be228113206995';
  static const String _gprsRssiCommandId = '6a04547227be228113206997';
  static const String _setHttpPasswordCommandId = '6a04547227be22811320699e';
  static const String _setHttpPortCommandId = '6a04547227be22811320699f';
  static const String _memoryTestCommandId = '6a04547227be228113206998';
  static const String _manualFtpCommandId = '6a04547227be228113206999';

  /// BLE templates that collect one user field before [_ble.sendDrifterAsciiCommand].
  static const Map<String, SelfTestParameterizedCommandFieldKind>
  _parameterizedServerFieldKindByCommandId = {
    _setRtcServerHttpWebsiteAddressCommandId:
        SelfTestParameterizedCommandFieldKind.rtcHttpWebsite128,
    _setRtcServerHttpWebsiteKeyCommandId:
        SelfTestParameterizedCommandFieldKind.rtcHttpKey15,
    _primaryServerHttpWebsiteAddressCommandId:
        SelfTestParameterizedCommandFieldKind.primaryHttpWebsiteIndex128,
    _primaryServerFtpAddressCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _primaryServerFtpPortCommandId:
        SelfTestParameterizedCommandFieldKind.portFiveDigits,
    _primaryServerFtpPathCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _primaryServerFtpUsernameCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _primaryServerFtpPasswordCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _primaryServerSmsCellNoCommandId:
        SelfTestParameterizedCommandFieldKind.smsCellPlus91,
    _primaryServerTxMediaRedundancyCommandId:
        SelfTestParameterizedCommandFieldKind.txRedundancy01,
    _secondaryServerHttpWebsiteAddressCommandId:
        SelfTestParameterizedCommandFieldKind
            .secondaryHttpWebsiteIndex0to3And128,
    _secondaryServerFtpAddressCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _secondaryServerFtpPortCommandId:
        SelfTestParameterizedCommandFieldKind.portFiveDigits,
    _secondaryServerFtpPathCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _secondaryServerFtpUsernameCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _secondaryServerFtpPasswordCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _secondaryServerSmsCellNoCommandId:
        SelfTestParameterizedCommandFieldKind.smsCellPlus91,
    _secondaryServerTxMediaRedundancyCommandId:
        SelfTestParameterizedCommandFieldKind.txRedundancy01,
    _thirdServerHttpWebsiteAddressCommandId:
        SelfTestParameterizedCommandFieldKind
            .thirdHttpWebsiteIndex0to3And128Trailing40,
    _thirdServerFtpAddressCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _thirdServerFtpPortNoCommandId:
        SelfTestParameterizedCommandFieldKind.portFiveDigits,
    _thirdServerFtpPathCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _thirdServerFtpUsernameCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _thirdServerFtpPasswordCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _setThirdServerSmsCellNoCommandId:
        SelfTestParameterizedCommandFieldKind.smsCellPlus91,
    _thirdServerTxMediaRedundancyCommandId:
        SelfTestParameterizedCommandFieldKind.txRedundancy01,
    _factoryServerHttpWebsiteAddressCommandId:
        SelfTestParameterizedCommandFieldKind.factoryHttpWebsiteIndex0to3And128,
    _factoryServerFtpAddressCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _factoryServerFtpPortNoCommandId:
        SelfTestParameterizedCommandFieldKind.portFiveDigits,
    _factoryServerFtpPathCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _factoryServerFtpUsernameCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _factoryServerFtpPasswordCommandId:
        SelfTestParameterizedCommandFieldKind.ftpField20,
    _setFactoryServerSmsCellNoCommandId:
        SelfTestParameterizedCommandFieldKind.smsCellPlus91,
    _factoryServerTxMediaRedundancyCommandId:
        SelfTestParameterizedCommandFieldKind.txRedundancy01,
    _httpServerUsernameCommandId:
        SelfTestParameterizedCommandFieldKind.httpServerUsernameIndex1to4And64,
    _setDlCellNoCommandId:
        SelfTestParameterizedCommandFieldKind.dlCellNumberIndex1to4,
    _testModeCommandId: SelfTestParameterizedCommandFieldKind.testModeValue01,
    _powerSwitchingCommandId:
        SelfTestParameterizedCommandFieldKind.powerSwitchingValueN,
    _setHttpPasswordCommandId:
        SelfTestParameterizedCommandFieldKind.setHttpPasswordIndex1to4And64,
    _setHttpPortCommandId:
        SelfTestParameterizedCommandFieldKind.setHttpPortIndex1to4FiveDigits,
    _batteryVoltageCommandId:
        SelfTestParameterizedCommandFieldKind.batteryVoltageIndex00to11,
  };

  static const String _fetchStationIdCommand = '?04,,#';

  /// Catalog choices for `?10` measurement interval field (HH:MM:SS).
  static const List<String> _allowedMeasurementIntervalHms = [
    '00:01:00',
    '00:05:00',
    '00:10:00',
    '00:15:00',
    '00:20:00',
    '00:30:00',
    '01:00:00',
  ];

  /// BLE request for `?65,N,S,FFFF,#`. When **S = 0** (get), FFFF must be empty:
  /// `?65,N,0,,#`. When **S = 1** (set), send four digit MHz fragment, e.g.
  /// `?65,0,1,4025,#`.
  static String _transmitterFrequencyRequestCommand({
    required int n,
    required int s,
    String? ffffFourDigits,
  }) {
    if (s == 0) {
      return '?65,$n,0,,#';
    }
    return '?65,$n,1,${ffffFourDigits ?? ''},#';
  }

  /// BLE request for `?67,S,xxxxx,#`. When **S = 0** (get), omit xxxxx:
  /// `?67,0,,#`. When **S = 1** (set), send the 5-character id: `?67,1,ABCDE,#`.
  static String _radioSondeTransmitterIdRequestCommand({
    required int s,
    String? fiveCharId,
  }) {
    if (s == 0) {
      return '?67,0,,#';
    }
    return '?67,1,${fiveCharId ?? ''},#';
  }

  static const List<DrifterBuoyCommandModel> _staticCommands = [
    DrifterBuoyCommandModel(
      id: _manualRtcUpdateCommandId,
      testName: 'Manual RTC Update',
      requestCommand: '?95,,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'Triggers manual RTC update on the device.',
      response:
          r'$95,Factory St-ID, GPS Update Status, DD/MM/YY HH:MM, RTC Update status, #',
      responseDescription:
          'Factory station ID, GPS status, last RTC date/time, RTC update status (0 = success).',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _manualDataAcquistionPollCommandId,
      testName: 'Manual Data Acquistion/poll',
      requestCommand: '?93,,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'NA',
      response:
          r'$93,station id,19-12-2025 17:08:00,11.9,78.864,170.12345,C6,48,#',
      responseDescription: 'Return Data String station id, All sensors data,',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _transmitterTestCommandId,
      testName: 'Transmitter Test',
      requestCommand: '?64,N,S,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'where, N = 0 – Enable plain carrier N = 1 – Modulation, N= 2 - PRBS where S = 0 -ON S = 1- OFF',
      response: r'$64,station id,S,#',
      responseDescription:
          'Where, S = 0 – Transmitter test OK S = 1 – Transmitter test Not OK',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setTransmissionTimeCommandId,
      testName: 'Set Transmission Time',
      requestCommand: '?08,HH:MM:SS,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'NA',
      response: r'$08,station id ,HH:MM:SS#',
      responseDescription: r'$08,00:10:02,#',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _eraseMemoryCommandId,
      testName: 'Erase Memory',
      requestCommand: '?96,,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'Erases device memory.',
      response: r'$96,station id, 1,#',
      responseDescription: '1 — success',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _restoreDefaultParametersCommandId,
      testName: 'Restore Default Parameters',
      requestCommand: '?03,,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription:
          'Restores factory default general system parameters on the device.',
      response: r'$03,list of general parameters#',
      responseDescription:
          'Station id, station name, Tx interval, measurement interval, APN, APN, Fast SMS check, admin cell no.1, admin cell no. 2, sensor power on time, measurement start time.',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setMeasurementIntervalCommandId,
      testName: 'Set measurement interval',
      requestCommand: '?10,HH:MM:SS,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription:
          'Allowed Measurement Intervals (HH:MM:SS):00:01:00, 00:05:00, 00:10:00, 00:15:00, 00:20:00, 00:30:00, 01:00:00',
      response: r'$10,list of general parameters#',
      responseDescription:
          'IIIIIIII, NNNNNNNNNNNNNNNN,HH:MM:SS,hh:mm:ss,AAAAAAAAAAAAAAAA,HHH…,S, +91nnnnnnnnnn, +91nnnnnnnnnn,YY,HH:MM:SS (Station id, station name, Tx interval, measurement interval, APN , APN, Fast SMS check, admin cell no.1, admin cell no. 2s, sensor power on time, measurement start time) Max length = 8+1+16+1+8+1+8+1+31+1+31+1+1+1+13+1+13+1+2+1+8= 149 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _measurementStartTimeCommandId,
      testName: 'Measurement Start Time',
      requestCommand: '?61,HH:MM:SS,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: '',
      response: r'$61,list of general parameters#',
      responseDescription:
          'IIIIIIII, NNNNNNNNNNNNNNNN,HH:MM:SS,hh:mm:ss,AAAAAAAAAAAAAAAA,HHH…,S, +91nnnnnnnnnn, +91nnnnnnnnnn,YY,HH:MM:SS (Station id, station name, Tx interval, measurement interval, APN , APN, Fast SMS check, admin cell no.1, admin cell no. 2s, sensor power on time, measurement start time) Max length = 8+1+16+1+8+1+8+1+31+1+31+1+1+1+13+1+13+1+2+1+8= 149 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _checkStatusCommandId,
      testName: 'Check Status',
      requestCommand: '?02,,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'Returns Status of GPRS and Peripheral Devices',
      response: r'$02,C4,00,00,00,00,0,0,0,0,1,VERSION 1.0.2 ,#',
      responseDescription:
          r'$02,PP,GG,GG,GG,GG, F1, MT1, F2, MT2, CH, D. L Firmware Version# (Peripheral status, GPRS status of primary server, GPRS status of secondary server, GPRS status of third server, GPRS status of factory server) F1 – Memory 1 Fail Status (0 = OK, 1 = Not OK) MT1– Memory 1 Test Result (0 = OK, 1 = Not OK) F2 – Memory 2 Fail Status (0 = OK, 1 = Not OK) MT2 – Memory 2 Test Result (0 = OK, 1 = Not OK) CH – Battery Charging Status (0 = Charging ON, 1 = Charging OFF, 2 = Fault) DL Firmware Version – Indicates the latest Data Logger firmware version.',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setAllGeneralSystemParametersCommandId,
      testName: 'Set all general system parameters',
      requestCommand: '?05,<nine comma-separated fields>,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'Nine fields: Station id (8), Station name (16), Tx interval (HH:MM:SS), '
          'Measurement interval (HH:MM:SS), APN (≤31), Fast SMS check (0 or 1), '
          'Admin cell 1 (+91…), Admin cell 2 (+91…), Measurement start time (HH:MM:SS). '
          'Example: ?05,D0110000,Ahemdabadabcdefg,01:10:10,00:10:10,/DLTEST1abcdefg/,1,'
          '+916357315181,+916357315181,09:10:10,#',
      response: r'$05,ist of all general system parameters#',
      responseDescription:
          'IIIIIIII, NNNNNNNNNNNNNNNN,HH:MM:SS,hh:mm:ss,AAAAAAAAAAAAAAAA,HHH…,S, +91nnnnnnnnnn, +91nnnnnnnnnn,YY,HH:MM:SS (Station id, station name, Tx interval, measurement interval, APN , APN, Fast SMS check, admin cell no.1, admin cell no. 2s, sensor power on time, measurement start time) Max length = 8+1+16+1+8+1+8+1+31+1+31+1+1+1+13+1+13+1+2+1+8= 149 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _getAllGeneralSystemParametersCommandId,
      testName: 'Get all general system parameters',
      requestCommand: '?04,,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'returns list of general parameters',
      response: r'$04,list of general parameters#',
      responseDescription:
          'IIIIIIII, NNNNNNNNNNNNNNNN,HH:MM:SS,hh:mm:ss,AAAAAAAAAAAAAAAA,HHH…,S, +91nnnnnnnnnn, +91nnnnnnnnnn,YY,HH:MM:SS (Station id, station name, Tx interval, measurement interval, APN , APN, Fast SMS check, admin cell no.1, admin cell no. 2s, sensor power on time, measurement start time) Max length = 8+1+16+1+8+1+8+1+31+1+31+1+1+1+13+1+13+1+2+1+8= 149 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setStationIdCommandId,
      testName: 'Set Station Id',
      requestCommand: '?06,XXXXXXXX,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'Sets 8 char station id',
      response: r'$06,list of general parameters#',
      responseDescription:
          'IIIIIIII, NNNNNNNNNNNNNNNN,HH:MM:SS,hh:mm:ss,AAAAAAAAAAAAAAAA,HHH…,S, +91nnnnnnnnnn, +91nnnnnnnnnn,YY,HH:MM:SS (Station id, station name, Tx interval, measurement interval, APN , APN, Fast SMS check, admin cell no.1, admin cell no. 2s, sensor power on time, measurement start time) Max length = 8+1+16+1+8+1+8+1+31+1+31+1+1+1+13+1+13+1+2+1+8= 149 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setStationNameCommandId,
      testName: 'Set station name',
      requestCommand: '?07,NNNNNNNNNNNNNNNN,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'NNNNNNNNNNNNNNNN (New value of station name)',
      response: r'$07,list of general parameters#',
      responseDescription:
          'IIIIIIII, NNNNNNNNNNNNNNNN,HH:MM:SS,hh:mm:ss,AAAAAAAAAAAAAAAA,HHH…,S, +91nnnnnnnnnn, +91nnnnnnnnnn,YY,HH:MM:SS (Station id, station name, Tx interval, measurement interval, APN , APN, Fast SMS check, admin cell no.1, admin cell no. 2s, sensor power on time, measurement start time) Max length = 8+1+16+1+8+1+8+1+31+1+31+1+1+1+13+1+13+1+2+1+8= 149 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setTransmissionIntervalCommandId,
      testName: 'Set transmission interval',
      requestCommand: '?09,HH:MM:SS,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'Allowed minimum interval = 00:10:00',
      response: r'$09,list of general parameters#',
      responseDescription: 'NA',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setApnCommandId,
      testName: 'Set APN',
      requestCommand: '?11,Para 1, para 2, para 3,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'Para1-> APN name,Para2-> 0 for Vodafone, 1 for other sim Para3-> ( 1 - sim1 APN , 2 – sim2 APN) (APN string – Only chars entered by user, maximum 31 char long. )',
      response: r'$11,list of general parameters#',
      responseDescription: '',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setRtcServerHttpWebsiteAddressCommandId,
      testName: 'Set RTC server HTTP website address',
      requestCommand: '?12,xxxx…,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(Max 128 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 40 char. Space char will not be part of address',
      response: r'$12,list of general parameters#',
      responseDescription: 'NA',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setRtcServerHttpWebsiteKeyCommandId,
      testName: 'Set RTC server HTTP website key',
      requestCommand: '?13,xxxx…,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(max 15 char)Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 40 char. Space char will not be part of address',
      response: r'$13,StationId,RTC Server Key#',
      responseDescription: 'NA',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _primaryServerHttpWebsiteAddressCommandId,
      testName: 'Primary server HTTP website address',
      requestCommand: '?14,N,xxx...,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'Where N represents the HTTP server number.(Max 128 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 128 char. Space char will not be part of address',
      response: r'$14,all primary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _primaryServerFtpAddressCommandId,
      testName: 'Primary server FTP address',
      requestCommand: '?15,xxxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(max 20 char) .Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$15,all primary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _primaryServerFtpPortCommandId,
      testName: 'Primary server FTP port no.',
      requestCommand: '?16,PPPPP,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'PPPPP(Port no. – 5 digit long, Range = 0 to 65535)',
      response: r'$16,all primary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _primaryServerFtpPathCommandId,
      testName: 'Primary server FTP path',
      requestCommand: '?17,xxxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(Max 20 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$17,all primary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _primaryServerFtpUsernameCommandId,
      testName: 'Primary server FTP username',
      requestCommand: '?18,xxxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(Max 20 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$18,all primary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _primaryServerFtpPasswordCommandId,
      testName: 'Primary server FTP password',
      requestCommand: '?19,xxxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(Max 20 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$19,all primary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _primaryServerSmsCellNoCommandId,
      testName: 'Set primary server SMS cell no',
      requestCommand: '?20,+91nnnnnnnnnn,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: '(nnnnnnnnnn: Cellular no. – 10 digit long)',
      response: r'$20,all primary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _primaryServerTxMediaRedundancyCommandId,
      testName: 'Primary server tx media redundancy',
      requestCommand: '?21,n,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'n = 0-GSM and GPRS, 1-GSM if GPRS Fail',
      response: r'$21,all primary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerHttpWebsiteAddressCommandId,
      testName: 'Secondary server HTTP website address',
      requestCommand: '?22,N,xxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'N -represents server number from 0 to 3. (Max 128 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 128 char. Space char will not be part of address',
      response: r'$22,all primary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerFtpAddressCommandId,
      testName: 'Secondary server FTP address',
      requestCommand: '?23,xxxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(max 20 char) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$23,all secondary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerFtpPortCommandId,
      testName: 'Secondary server FTP port no.',
      requestCommand: '?24,PPPPP,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'PPPPP(Port no. – 5 digit long, Range = 0 to 65535)',
      response: r'$24,all secondary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerFtpPathCommandId,
      testName: 'Secondary server FTP path',
      requestCommand: '?25,xxxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(Max 20 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$25,all secondary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerFtpUsernameCommandId,
      testName: 'Secondary server FTP user name',
      requestCommand: '?26,xxxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(Max 20 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$26,all secondary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerFtpPasswordCommandId,
      testName: 'Secondary server FTP password',
      requestCommand: '?27,xxxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(Max 20 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$27,all secondary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerSmsCellNoCommandId,
      testName: 'Set secondary server SMS cell no',
      requestCommand: '?28,+91nnnnnnnnnn,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'PPPPP(nnnnnnnnnn: Cellular no. – 10 digit long)',
      response: r'$28,all secondary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerTxMediaRedundancyCommandId,
      testName: 'Secondary server tx media redundancy',
      requestCommand: '?29,n,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'n = 0-GSM and GPRS, 1-GSM if GPRS Fail',
      response: r'$29,all secondary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _thirdServerHttpWebsiteAddressCommandId,
      testName: 'Third server HTTP website address',
      requestCommand: '?30,N,xxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'N -represents server number from 0 to 3. (Max 128 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 40 char. Space char will not be part of address',
      response: r'$30,all secondary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _thirdServerFtpAddressCommandId,
      testName: 'Third server FTP address',
      requestCommand: '?31,xxxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(Max 20 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 128 char. Space char will not be part of address',
      response: r'$31,all third server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _thirdServerFtpPortNoCommandId,
      testName: 'Third server FTP port no.',
      requestCommand: '?32,PPPPP,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'PPPPP(Port no. – 5 digit long, Range = 0 to 65535)',
      response: r'$32,all third server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _thirdServerFtpPathCommandId,
      testName: 'Third server FTP path',
      requestCommand: '?33,xxxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(Max 20 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$33,all third server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _thirdServerFtpUsernameCommandId,
      testName: 'Third server FTP username',
      requestCommand: '?34,xxxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(Max 20 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$34,all third server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _thirdServerFtpPasswordCommandId,
      testName: 'Third server FTP password',
      requestCommand: '?35,xxxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(Max 20 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$35,all third server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setThirdServerSmsCellNoCommandId,
      testName: 'Set Third server SMS cell no',
      requestCommand: '?36,+91nnnnnnnnnn,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: '(nnnnnnnnnn: Cellular no. – 10 digit long)',
      response: r'$36,all third server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _thirdServerTxMediaRedundancyCommandId,
      testName: 'Third server tx media redundancy',
      requestCommand: '?37,n,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'n = 0-GSM and GPRS, 1-GSM if GPRS Fail',
      response: r'$37,all third server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _factoryServerHttpWebsiteAddressCommandId,
      testName: 'Factory server HTTP website address',
      requestCommand: '?38,N,xxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'N -represents server number from 0 to 3. (Max 128 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 128 char. Space char will not be part of address',
      response: r'$38,all factory server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _factoryServerFtpAddressCommandId,
      testName: 'Factory server FTP address',
      requestCommand: '?39,xxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'where xxx...Ipv4 format or URL format Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$39,all factory server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _factoryServerFtpPortNoCommandId,
      testName: 'Factory server FTP port no',
      requestCommand: '?40,PPPPP,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'PPPPP(Port no. – 5 digit long, Range = 0 to 65535)',
      response: r'$40,all factory server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _factoryServerFtpPathCommandId,
      testName: 'Factory server FTP path',
      requestCommand: '?41,xxxx...,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(Max 20 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$41,all factory server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _factoryServerFtpUsernameCommandId,
      testName: 'Factory server FTP username',
      requestCommand: '?42,xxxx...,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(Max 20 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$42,all factory server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _factoryServerFtpPasswordCommandId,
      testName: 'Factory server FTP password',
      requestCommand: '?43,xxxx..,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(Max 20 characters) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$43,all factory server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setFactoryServerSmsCellNoCommandId,
      testName: 'Set factory server SMS cell no',
      requestCommand: '?44,+91nnnnnnnnnn,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: '(nnnnnnnnnn: Cellular no. – 10 digit long)',
      response: r'$44,all factory server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _factoryServerTxMediaRedundancyCommandId,
      testName: 'Factory server tx media redundancy',
      requestCommand: '?45,n,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'n = 0-GSM and GPRS, 1-GSM if GPRS Fail',
      response: r'$45,all factory server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setPrimaryServerAllFtpHttpParametersCommandId,
      testName: 'Set primary server all FTP/HTTP parameters',
      requestCommand: '?46,IIIIII,FFF…,PPPPP,ffff…,uuuu…,pppp…,+91nnnn…,R,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(station id, FTP server address, FTP port no., FTP file path, FTP user name, FTP password, cell no., tx redundancy)Station id – fix 8 characters.FTP port no. – fix 5 character, range 00000 to 65535.FTP server address, FTP file path, FTP user name, FTP password – max 20 characters. If < 20 char, use ‘‘last character.Cell no. – fix 10 charactersTx redundancy – 1 => enable, 0 => disable',
      response: r'$46,all primary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setSecondaryServerAllFtpHttpParametersCommandId,
      testName: 'Set secondary server all FTP/HTTP parameters',
      requestCommand: '?47,IIIIII,FFF…,PPPPP,ffff…,uuuu…,pppp…,+91nnnn…,R,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(station id, FTP server address, FTP port no., FTP file path, FTP user name, FTP password, cell no., tx redundancy)Station id – fix 8 characters.FTP port no. – fix 5 character, range 00000 to 65535.FTP server address, FTP file path, FTP user name, FTP password – max 20 characters. If < 20 char, use ‘‘last character.Cell no. – fix 10 charactersTx redundancy – 1 => enable, 0 => disable',
      response: r'$47,all secondary server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setThirdServerAllFtpHttpParametersCommandId,
      testName: 'Set third server all FTP/HTTP parameters',
      requestCommand: '?48,IIIIII,FFF…,PPPPP,ffff…,uuuu…,pppp…,+91nnnn…,R,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(station id, FTP server address, FTP port no., FTP file path, FTP user name, FTP password, cell no., tx redundancy)Station id – fix 8 characters.FTP port no. – fix 5 character, range 00000 to 65535.FTP server address, FTP file path, FTP user name, FTP password – max 20 characters. If < 20 char, use ‘‘last character.Cell no. – fix 10 charactersTx redundancy – 1 => enable, 0 => disable',
      response: r'$48,all third server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setFactoryServerAllFtpHttpParametersCommandId,
      testName: 'Set factory server all FTP/HTTP parameters',
      requestCommand: '?49,IIIIII,FFF…,PPPPP,ffff…,uuuu…,pppp…,+91nnnn…,R,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          '(station id, FTP server address, FTP port no., FTP file path, FTP user name, FTP password, cell no., tx redundancy)Station id – fix 8 characters.FTP port no. – fix 5 character, range 00000 to 65535.FTP server address, FTP file path, FTP user name, FTP password – max 20 characters. If < 20 char, use ‘‘last character.Cell no. – fix 10 charactersTx redundancy – 1 => enable, 0 => disable',
      response: r'$49,all factory server settings#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _getPrimaryServerAllFtpHttpParametersCommandId,
      testName: 'Get primary server all FTP/HTTP parameters',
      requestCommand: '?50,,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'Returns all primary settings',
      response: r'$50, all primary server settings,#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _getSecondaryServerAllFtpHttpParametersCommandId,
      testName: 'Get secondary server all FTP/HTTP parameters',
      requestCommand: '?51,,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'Returns all secondary settings',
      response: r'$51, all secondary server settings,#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _getThirdServerAllFtpHttpParametersCommandId,
      testName: 'Get third server all FTP/HTTP parameters',
      requestCommand: '?52,,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'Returns all third settings',
      response: r'$52, all third server settings,#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _getFactoryServerAllFtpHttpParametersCommandId,
      testName: 'Get factory server all FTP/HTTP parameters',
      requestCommand: '?53,,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'Returns all factory settings',
      response: r'$53, all factory server settings,#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _restorePrimaryServerAllFtpHttpParametersCommandId,
      testName: 'Restore primary server all FTP/HTTP parameters',
      requestCommand: '?54,,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'Returns all primary settings',
      response: r'$54, all primary server settings,#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _restoreSecondaryServerAllFtpHttpParametersCommandId,
      testName: 'Restore secondary server all FTP/HTTP parameters',
      requestCommand: '?55,,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'Returns all secondary settings',
      response: r'$55, all secondary server settings,#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _restoreThirdServerAllFtpHttpParametersCommandId,
      testName: 'Restore third server all FTP/HTTP parameters',
      requestCommand: '?56,,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'Returns all third settings',
      response: r'$56, all third server settings,#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _restoreFactoryServerAllFtpHttpParametersCommandId,
      testName: 'Restore factory server all FTP/HTTP parameters',
      requestCommand: '?57,,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'Returns all factory settings',
      response: r'$57, all factory server settings,#',
      responseDescription:
          'IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _fastSmsCheckCommandId,
      testName: 'Fast SMS check',
      requestCommand: '?58,N,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'N=0 Disable, 1Enable',
      response: r'$58,all general system parameters#',
      responseDescription:
          'IIIIIIII, NNNNNNNNNNNNNNNN,HH:MM:SS,hh:mm:ss,AAAAAAAAAAAAAAAA,HHH…,S, +91nnnnnnnnnn, +91nnnnnnnnnn,YY,HH:MM:SS (Station id, station name, Tx interval, measurement interval, APN , APN, Fast SMS check, admin cell no.1, admin cell no. 2s, sensor power on time, measurement start time) Max length = 8+1+16+1+8+1+8+1+31+1+31+1+1+1+13+1+13+1+2+1+8= 149 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setAdmin1SmsCellNoCommandId,
      testName: 'Set admin 1 SMS cell no',
      requestCommand: '?59,+91nnnnnnnnnn,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: '(nnnnnnnnnn: Cellular no. – 10 digit long)',
      response: r'$59,all general system parameters#',
      responseDescription:
          'IIIIIIII, NNNNNNNNNNNNNNNN,HH:MM:SS,hh:mm:ss,AAAAAAAAAAAAAAAA,HHH…,S, +91nnnnnnnnnn, +91nnnnnnnnnn,YY,HH:MM:SS (Station id, station name, Tx interval, measurement interval, APN , APN, Fast SMS check, admin cell no.1, admin cell no. 2s, sensor power on time, measurement start time) Max length = 8+1+16+1+8+1+8+1+31+1+31+1+1+1+13+1+13+1+2+1+8= 149 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setAdmin2SmsCellNoCommandId,
      testName: 'Set admin 2 SMS cell no',
      requestCommand: '?60,+91nnnnnnnnnn,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: '(nnnnnnnnnn: Cellular no. – 10 digit long)',
      response: r'$60,all general system parameters#',
      responseDescription:
          'IIIIIIII, NNNNNNNNNNNNNNNN,HH:MM:SS,hh:mm:ss,AAAAAAAAAAAAAAAA,HHH…,S, +91nnnnnnnnnn, +91nnnnnnnnnn,YY,HH:MM:SS (Station id, station name, Tx interval, measurement interval, APN , APN, Fast SMS check, admin cell no.1, admin cell no. 2s, sensor power on time, measurement start time) Max length = 8+1+16+1+8+1+8+1+31+1+31+1+1+1+13+1+13+1+2+1+8= 149 characters',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _httpServerUsernameCommandId,
      testName: 'HTTP Server Username',
      requestCommand: '?62,N,username,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'N-ServerNo 1 to 4, username for the selected server (max 64 char)',
      response: r'$62,station id,N,azista123..#',
      responseDescription:
          'N – Server number from 1 to 4 azista123... – username for the selected server (Max 64-character length)',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _getTransmissionStartTimeGprsCommandId,
      testName: 'Get transmission start time GPRS',
      requestCommand: '?63,,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'returns current tranmission time',
      response: r'$63,station id,HH:MM:SS#',
      responseDescription: 'NA',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _transmitterFrequencyCommandId,
      testName: 'Set/Get transmitter frequency',
      requestCommand: '?65,N,S,FFFF,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'S = 0 – to get ,1- set if S =0 no need to send FFFF. N= 0 for UHF, 1 for Radio Sonde. Freq from 402.0000 to 403.0000Mhz.FFFF - value of Frequency',
      response: r'$65,station id ,N,S,FFFF,#',
      responseDescription:
          'If S = 0, then only consider valid FFFF value. Value of S below: 0 - frequency set successful,1 - Checksum error,2 - frequency not set,3 -transmitter communication problem or not connected 4 - get successful,N= 0 for UHF, 1 for Radio Sonde FFFF - value of Frequency',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setAttenuationCommandId,
      testName: 'Set Attenuation',
      requestCommand: '?66,N,S,xx,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'N= 0 for UHF, 1 for Radio Sonde S = 0 – to get ,1- set In case of S =0 no need to send xx. Where xx = attenuation value',
      response: r'$66,station id,N,S,xx,#',
      responseDescription:
          'N= 0 for UHF, 1 for Radio Sonde, S = 0 – to get ,1- set ,xx= attenuation value',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _radioSondeTransmitterIdCommandId,
      testName: 'Get station ID of Radio sonde Transmitter',
      requestCommand: '?67,S,xxxxx,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription:
          'S = 0 – get, 1- set in case of S =0 no need to send xxxxx xxxxx = station id of sonde transmitter (5 char)',
      response: r'$67,station id,S,xxxx,#',
      responseDescription:
          'S = 0 – get, 1- set xxxxx = station id of sonde transmitter (5 char)',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setDlCellNoCommandId,
      testName: 'Set DL cell no',
      requestCommand: '?68,N,nnnnnnnnnnnnn,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription:
          'N = 1 — D.L. cell no. 1 (+91 and 10 digits, or 13 digits). '
          'N = 2 — D.L. cell no. 2 (+91 and 10 digits, or 13 digits). '
          'N = 3 — MSISDN no. 1 (13 digits only, no +91). '
          'N = 4 — MSISDN no. 2 (13 digits only, no +91).',
      response: r'$68,Stationid,+91nnnnnnnnnn,#',
      responseDescription:
          'Station ID and the cell number that was set (e.g. +91 and 10 digits).',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _testModeCommandId,
      testName: 'TestMode',
      requestCommand: '?71,N,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'N = 0 or 1. Example: ?71,1,#',
      response: r'$71,StationID,N,#',
      responseDescription: 'Station ID and test mode value (N) from device.',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _powerSwitchingCommandId,
      testName: 'Power Switching',
      requestCommand: '?76,N,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription:
          'Enter N for power switching (e.g. 20 sends ?76,20,#).',
      response: r'$76,StationId,1#',
      responseDescription: '1 — success',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _simCardTestCommandId,
      testName: 'Sim Card Test',
      requestCommand: '?77,1,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: '',
      response: r'$77,Station ID, 0, -067, 0, -072, EC200UCNAAR03A14M08,#',
      responseDescription:
          'SIM1_slot_status – 0: Success,1: Failure, Signal_strength_SIM1: -067, SIM2_slot_status - 0: Success,1: Failure, Signal_strength_SIM2: -072 ,Modem Firmware Ver: EC200UCNAAR03A14M08',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _sleepCurrentTestCommandId,
      testName: 'Sleep Current Test',
      requestCommand: '?79,,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'Runs sleep current test on the device.',
      response: r'$79,StationId,1#',
      responseDescription: '1 — success',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setSensorAllParameterCommandId,
      testName: 'SET Sensor ALL parameter',
      requestCommand:
          '?80,(Sensor no, channel no,F.G, factory off, senG, Soff, Resolution, sen Min, sens Max, Averag Scheme, vactor, start time, interval, total sample, mode, Tx.G, Tx.O ),#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'NA',
      response: r'$80,List of all sensor parameters,#',
      responseDescription:
          'Sensor no, channel no, F.G, factory off, senG, S.off, Resolution, sen Min, sens Max, Averag Scheme, vactor, start time, interval, total sample, mode, Tx.G, Tx.O',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _getSensorParameterCommandId,
      testName: 'GET sensor parameter (?81)',
      requestCommand: '?81,Sensor Number,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'NA',
      response: r'$81,List of all sensor parameters,#',
      responseDescription:
          'Sensor no, F.G, factory off, senG, S.off, Resolution, sen Min, sens Max, Averag Scheme, vactor, start time, interval, total sample, mode, Tx.G, Tx.O',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setSensorsParametersCommandId,
      testName: 'SET sensors parameters',
      requestCommand:
          '?82,(sensor no,unit,SenSelStatus,BaudRate,ReqLen,Start Char,Fp,Lp,Resp Len,RelayNo,PeriodicSmpl,DerievedPara,RequestString,Sensor name,id, model,rstcnt,datum,dec_len,frac_len,max_threshold,min_threshold)',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'NA',
      response:
          r'$82,Station ID, sensor no,unit,SenSelStatus,BaudRate,ReqLen,Start Char,Fp,Lp,Resp Len,RelayNo,PeriodicSmpl,DerievedPara,RequestString,Sensor name,id, model,rstcnt,datum,dec_len,frac_len,max_threshold,min_threshold, #',
      responseDescription: 'NA',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _getSensorParameter83CommandId,
      testName: 'GET sensor parameter (?83)',
      requestCommand: '?83,Sensor number,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'NA',
      response:
          r'$83,Station ID, sensor no,unit,SenSelStatus,BaudRate,ReqLen,Start Char,Fp,Lp,Resp Len,RelayNo,PeriodicSmpl,DerievedPara,RequestString,Sensor name,id, model,rstcnt,datum,dec_len,frac_len,max_threshold,min_threshold, #',
      responseDescription: 'NA',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _batteryVoltageCommandId,
      testName: 'Battery Voltage',
      requestCommand: '?84,xx,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: 'Where xx is between 00 to 11.',
      response: r'$84,station id ,Battery Voltage, CNT: Counts,#',
      responseDescription: 'NA',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _gprsRssiCommandId,
      testName: 'GPRS RSSI',
      requestCommand: '?89,,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: '',
      response: r'$89,Factory Stationid,RSSI,#',
      responseDescription: 'NA',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setHttpPasswordCommandId,
      testName: 'Set HTTP password',
      requestCommand: '?97,N,password,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription:
          'Max 64 characters. N = 1–4 (HTTP user/server slot). Example: ?97,1,AZISTA123,#',
      response: r'$97,station id,N,password,#',
      responseDescription:
          'Station ID, server slot, and password read-back from device.',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setHttpPortCommandId,
      testName: 'Set HTTP Port',
      requestCommand: '?98,N,PPPPP,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription:
          'N = 0–3 (HTTP user/server slot). PPPPP is port 0–65535. Example: ?98,0,11111,#',
      response:
          r'$98,station id, User1HTTPPort, User2HTTPPort, User3HTTPPort, FactHTTPPort,#',
      responseDescription:
          'Station ID and HTTP ports for User 1–3 and Factory server.',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _memoryTestCommandId,
      testName: 'Memory test',
      requestCommand: '?91,,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'Runs memory test on the device.',
      response: r'$91,station Id ,memorystatus,memory 2 status,#',
      responseDescription:
          'Station ID and memory test status fields (0 = OK, 1 = Not OK).',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _manualFtpCommandId,
      testName: 'manual FTP',
      requestCommand: '?92,,#',
      waitingPeriodSecondsRaw: '1 min',
      requestCommandDescription: r'$92,Factory station id,0',
      response: r'$92,00000000,0,#',
      responseDescription: '0 indicates task is completed.',
      isActive: true,
    ),
  ];

  /// Resolves static catalog text/timeouts when the API returns duplicate Mongo ids.
  static DrifterBuoyCommandModel _catalogEntryForApi(
    DrifterBuoyCommandModel api,
  ) {
    final id = api.id.trim();
    if (id.isEmpty) return api;
    final rows = _staticCommands
        .where((DrifterBuoyCommandModel c) => c.id == id)
        .toList();
    if (rows.isEmpty) return api;
    if (rows.length == 1) return rows.single;
    final want = api.requestCommand.trim();
    for (final DrifterBuoyCommandModel c in rows) {
      if (c.requestCommand.trim() == want) return c;
    }
    return rows.first;
  }

  /// Sheet order for menu taps: walk [_staticCommands] top-to-bottom and keep only
  /// rows allowed by the API. Duplicate Mongo ids disambiguate via [DrifterBuoyCommandModel.requestCommand].
  static List<DrifterBuoyCommandModel> _allowedCommandsInCsvOrder(
    List<DrifterBuoyCommandModel> apiCommands,
  ) {
    final remaining = <DrifterBuoyCommandModel>[
      for (final DrifterBuoyCommandModel a in apiCommands)
        if (a.isActive && a.id.trim().isNotEmpty) a,
    ];

    final idOccurrencesInCatalog = <String, int>{};
    for (final DrifterBuoyCommandModel c in _staticCommands) {
      final String id = c.id.trim();
      idOccurrencesInCatalog[id] = (idOccurrencesInCatalog[id] ?? 0) + 1;
    }

    final out = <DrifterBuoyCommandModel>[];

    for (final DrifterBuoyCommandModel staticRow in _staticCommands) {
      final id = staticRow.id.trim();
      final req = staticRow.requestCommand.trim();

      final idx = remaining.indexWhere(
        (DrifterBuoyCommandModel a) =>
            a.id.trim() == id && a.requestCommand.trim() == req,
      );
      if (idx >= 0) {
        out.add(_catalogEntryForApi(remaining.removeAt(idx)));
        continue;
      }

      // Same Mongo id maps to multiple BLE commands (e.g. `?81` and `?83` both …994).
      // The API often returns only one row per id; still show every catalog variant the
      // user is allowed to run when that id is permitted.
      if (idOccurrencesInCatalog[id] != 1) {
        final permittedForId = apiCommands.any(
          (DrifterBuoyCommandModel a) => a.isActive && a.id.trim() == id,
        );
        if (permittedForId) {
          out.add(staticRow);
        }
        continue;
      }

      final apiIdx = remaining.indexWhere(
        (DrifterBuoyCommandModel a) => a.id.trim() == id,
      );
      if (apiIdx < 0) continue;

      final sameIdLeft = remaining
          .where((DrifterBuoyCommandModel a) => a.id.trim() == id)
          .length;
      if (sameIdLeft != 1) continue;

      out.add(_catalogEntryForApi(remaining.removeAt(apiIdx)));
    }

    return out;
  }

  static final Map<String, DrifterBuoyCommandModel> _staticCommandsById = {
    for (final c in _staticCommands) c.id: c,
  };

  static DrifterBuoyCommandModel? _staticCommandMatching({
    required String id,
    required String requestCommand,
  }) {
    final idT = id.trim();
    final reqT = requestCommand.trim();
    if (reqT.isNotEmpty) {
      for (final c in _staticCommands) {
        if (c.id.trim() == idT && c.requestCommand.trim() == reqT) {
          return c;
        }
      }
    }
    return _staticCommandsById[idT];
  }

  static bool _shouldOpenSetAllGeneralParametersPrompt(
    DrifterBuoyCommandModel cmd,
  ) {
    if (cmd.id == _setAllGeneralSystemParametersCommandId) {
      return true;
    }
    return cmd.requestCommand.trim().startsWith('?05,');
  }

  static SelfTestParameterizedCommandFieldKind? _parameterizedKindFor(
    DrifterBuoyCommandModel cmd,
  ) {
    if (_shouldOpenSetAllGeneralParametersPrompt(cmd)) {
      return null;
    }
    final req = cmd.requestCommand.trim();
    if (req.startsWith('?81') || req.startsWith('?83')) {
      return SelfTestParameterizedCommandFieldKind
          .getSensorParameter83SensorNumber;
    }
    return _parameterizedServerFieldKindByCommandId[cmd.id];
  }

  /// Loads permitted commands from the backend; menu order follows the CSV catalog [_staticCommands].
  Future<void> _onLoadGeneralUserSelfTestDebug(
    LoadGeneralUserSelfTestDebug event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserSelfTestDebug event triggered');
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.loading,
        message: '',
        isSuccessMessage: false,
      ),
    );

    final result = await _remote.getAllDrifterBuoyCommands();
    result.fold(
      (failure) {
        // Fallback: keep self-test usable even when permission API fails.
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            commands: _staticCommands,
            message: '',
            isSuccessMessage: false,
            clearParameterizedCommandPrompt: true,
            clearSetAllGeneralParametersPrompt: true,
            clearTransmissionTimePrompt: true,
            clearTransmissionIntervalPrompt: true,
            clearMeasurementIntervalPrompt: true,
            clearSetApnPrompt: true,
            clearFastSmsCheckPrompt: true,
            clearAdminSmsCellPrompt: true,
          ),
        );
      },
      (data) {
        final apiCommands = data.result;
        final List<DrifterBuoyCommandModel> cmds;

        if (apiCommands.isEmpty) {
          cmds = List<DrifterBuoyCommandModel>.from(_staticCommands);
        } else {
          cmds = _allowedCommandsInCsvOrder(apiCommands);
        }

        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            commands: cmds,
            message: cmds.isEmpty
                ? 'No self-test commands are permitted for this user.'
                : '',
            isSuccessMessage: false,
            clearParameterizedCommandPrompt: true,
            clearSetAllGeneralParametersPrompt: true,
            clearTransmissionTimePrompt: true,
            clearTransmissionIntervalPrompt: true,
            clearMeasurementIntervalPrompt: true,
            clearSetApnPrompt: true,
            clearFastSmsCheckPrompt: true,
            clearAdminSmsCellPrompt: true,
          ),
        );
      },
    );
  }

  /// Runs the tapped catalog row: special prompts, parameterized FTP/SMS, or plain BLE send.
  Future<void> _onRunGeneralUserSelfTestDebugAction(
    RunGeneralUserSelfTestDebugAction event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    if (state.status == GeneralUserSelfTestDebugStatus.running) {
      return;
    }
    final index = event.commandIndex;
    if (index < 0 || index >= state.commands.length) {
      emit(
        state.copyWith(message: 'Invalid command.', isSuccessMessage: false),
      );
      return;
    }

    final cmd = state.commands[index];
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    if (_shouldOpenSetAllGeneralParametersPrompt(cmd)) {
      await _onOpenSetAllGeneralParametersPrompt(cmd, index, emit);
      return;
    }

    if (cmd.requestCommand.trim().startsWith('?06,')) {
      await _onOpenSetStationIdPrompt(cmd, index, emit);
      return;
    }
    if (cmd.requestCommand.trim().startsWith('?07,')) {
      await _onOpenSetStationNamePrompt(cmd, index, emit);
      return;
    }
    if (cmd.id == _transmitterTestCommandId) {
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          transmitterTestPrompt: const SelfTestTransmitterTestPrompt(),
          message: '',
          isSuccessMessage: false,
          clearLastSnapshot: true,
        ),
      );
      return;
    }
    if (cmd.id == _checkStatusCommandId) {
      await _onOpenCheckStatusPrompt(cmd, index, emit);
      return;
    }
    if (cmd.requestCommand.trim().startsWith('?08,')) {
      _onOpenTransmissionTimePrompt(cmd, emit);
      return;
    }
    if (cmd.requestCommand.trim().startsWith('?61,')) {
      await _onOpenMeasurementStartTimePrompt(cmd, index, emit);
      return;
    }
    if (cmd.requestCommand.trim().startsWith('?09,')) {
      await _onOpenTransmissionIntervalPrompt(cmd, index, emit);
      return;
    }
    if (cmd.requestCommand.trim().startsWith('?10,') ||
        cmd.id == _setMeasurementIntervalCommandId) {
      await _onOpenMeasurementIntervalPrompt(cmd, index, emit);
      return;
    }
    if (cmd.id == _setApnCommandId) {
      await _onOpenSetApnPrompt(cmd, index, emit);
      return;
    }
    if (cmd.id == _fastSmsCheckCommandId) {
      await _onOpenFastSmsCheckPrompt(cmd, index, emit);
      return;
    }
    if (cmd.id == _setAdmin1SmsCellNoCommandId ||
        cmd.id == _setAdmin2SmsCellNoCommandId) {
      await _onOpenAdminSmsCellPrompt(cmd, index, emit);
      return;
    }
    if (cmd.id == _transmitterFrequencyCommandId) {
      await _onOpenTransmitterFrequencyPrompt(cmd, index, emit);
      return;
    }
    if (cmd.id == _setAttenuationCommandId) {
      await _onOpenSetAttenuationPrompt(cmd, index, emit);
      return;
    }
    if (cmd.id == _radioSondeTransmitterIdCommandId) {
      await _onOpenRadioSondeTransmitterIdPrompt(cmd, index, emit);
      return;
    }
    if (cmd.id == _restoreDefaultParametersCommandId) {
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          restoreDefaultParametersPrompt:
              SelfTestRestoreDefaultParametersPrompt(
                commandId: cmd.id,
                testName: cmd.testName,
                catalogHelpText: cmd.requestCommandDescription,
              ),
          clearLastSnapshot: true,
          message: '',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (_setAllServerCommandIds.contains(cmd.id)) {
      await _onOpenSetAllServerParametersPrompt(cmd, index, emit);
      return;
    }
    if (_restoreAllServerCommandIds.contains(cmd.id)) {
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          restoreServerParametersPrompt: SelfTestRestoreServerParametersPrompt(
            commandId: cmd.id,
            testName: cmd.testName,
            catalogHelpText: cmd.requestCommandDescription,
          ),
          clearLastSnapshot: true,
          message: '',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (_getAllServerCommandIds.contains(cmd.id)) {
      await _onRunGetAllServerParameters(cmd, index, emit);
      return;
    }
    if (cmd.id == _setSensorAllParameterCommandId) {
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          setSensorAllParametersPrompt: SelfTestSetSensorAllParametersPrompt(
            testName: cmd.testName,
            initial: const SelfTestSetSensorAllParametersDraft(),
            catalogHelpText: cmd.requestCommandDescription,
          ),
          clearLastSnapshot: true,
          message: '',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (cmd.id == _setSensorsParametersCommandId) {
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          setSensorsParametersPrompt: SelfTestSetSensorsParametersPrompt(
            testName: cmd.testName,
            initial: const SelfTestSetSensorsParametersDraft(),
            catalogHelpText: cmd.requestCommandDescription,
          ),
          clearLastSnapshot: true,
          message: '',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final parameterizedKind = _parameterizedKindFor(cmd);
    if (parameterizedKind != null) {
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          parameterizedCommandPrompt: SelfTestParameterizedCommandPrompt(
            commandId: cmd.id,
            testName: cmd.testName,
            fieldKind: parameterizedKind,
            requestCommand: cmd.requestCommand,
            requestHelpText: cmd.requestCommandDescription,
          ),
          clearLastSnapshot: true,
          message: '',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    if (_shouldOpenSetAllGeneralParametersPrompt(cmd)) {
      await _onOpenSetAllGeneralParametersPrompt(cmd, index, emit);
      return;
    }

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
      ),
    );

    try {
      final wait = cmd.responseWaitTimeout;
      final line = await _ble.sendDrifterAsciiCommand(cmd.requestCommand, wait);

      final isGetAllGeneral = cmd.id == _getAllGeneralSystemParametersCommandId;
      final isGprsTransmissionStartTime =
          cmd.id == _getTransmissionStartTimeGprsCommandId;
      final isSleepCurrentTest = cmd.id == _sleepCurrentTestCommandId;
      final isManualRtcUpdate = cmd.id == _manualRtcUpdateCommandId;
      final isEraseMemory = cmd.id == _eraseMemoryCommandId;
      final isMemoryTest = cmd.id == _memoryTestCommandId;
      final helpText = isGetAllGeneral
          ? _formatGeneralSystemParametersBleSummary(line)
          : isGprsTransmissionStartTime
          ? _formatTransmissionStartTimeGprsBleSummary(line)
          : isSleepCurrentTest
          ? _formatSleepCurrentTestBleSummary(line)
          : isManualRtcUpdate
          ? _formatManualRtcUpdateBleSummary(line)
          : isEraseMemory
          ? _formatEraseMemoryBleSummary(line)
          : isMemoryTest
          ? _formatMemoryTestBleSummary(line)
          : (cmd.responseDescription.trim().isEmpty ||
                    cmd.responseDescription.trim().toUpperCase() == 'NA'
                ? cmd.response.trim()
                : cmd.responseDescription.trim());

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          lastSnapshot: SelfTestBleResponseSnapshot(
            testName: cmd.testName,
            responseLine: line,
            hideResponseLine:
                isGetAllGeneral ||
                isGprsTransmissionStartTime ||
                isSleepCurrentTest ||
                isManualRtcUpdate ||
                isEraseMemory ||
                isMemoryTest,
            helpText: helpText,
            descriptionSuccess:
                isGetAllGeneral ||
                    isGprsTransmissionStartTime ||
                    isSleepCurrentTest ||
                    isManualRtcUpdate ||
                    isEraseMemory ||
                    isMemoryTest
                ? true
                : null,
          ),
          message: isGetAllGeneral
              ? 'General system parameters read successfully.'
              : isGprsTransmissionStartTime
              ? 'Transmission start time read successfully.'
              : isSleepCurrentTest
              ? 'Sleep current test completed successfully.'
              : isManualRtcUpdate
              ? 'Manual RTC update completed successfully.'
              : isEraseMemory
              ? 'Memory erased successfully.'
              : isMemoryTest
              ? 'Memory test completed successfully.'
              : '',
          isSuccessMessage:
              isGetAllGeneral ||
              isGprsTransmissionStartTime ||
              isSleepCurrentTest ||
              isManualRtcUpdate ||
              isEraseMemory ||
              isMemoryTest,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Self-test BLE timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message:
              'Timed out waiting for a response ending with # (${cmd.testName}).',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Self-test BLE error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onOpenSetStationIdPrompt(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        _fetchStationIdCommand,
        cmd.responseWaitTimeout,
      );
      final stationId = _extractStationId(line);
      if (stationId == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message: 'Could not parse station id from device response.',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          stationIdPrompt: SelfTestStationIdPrompt(currentStationId: stationId),
          clearLastSnapshot: true,
          message: '',
          isSuccessMessage: false,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Fetch station id timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while reading station id.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Fetch station id error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onOpenSetStationNamePrompt(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
      ),
    );

    String? prefetchWarning;
    var initialName = '';

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        _fetchStationIdCommand,
        cmd.responseWaitTimeout,
      );
      final parsed = _extractStationNameFromGeneralParameters(line);
      if (parsed != null) {
        initialName = parsed;
      } else {
        prefetchWarning =
            'Could not parse current station name from the device. Enter the new name manually.';
      }
    } on TimeoutException catch (e) {
      AppLogger.e('Prefetch station name timeout', error: e);
      prefetchWarning =
          'Timed out reading current parameters. Enter the station name manually.';
    } catch (e, st) {
      AppLogger.e('Prefetch station name error', error: e, stackTrace: st);
      prefetchWarning =
          'Could not read current station name. Enter the new name manually.';
    }

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.loaded,
        clearRunningCommandIndex: true,
        stationNamePrompt: SelfTestStationNamePrompt(
          currentStationName: initialName,
          prefetchWarning: prefetchWarning,
        ),
        clearLastSnapshot: true,
        message: '',
        isSuccessMessage: false,
      ),
    );
  }

  Future<void> _onSubmitGeneralUserSetStationId(
    SubmitGeneralUserSetStationId event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final nextStationId = event.stationId.trim().toUpperCase();
    if (nextStationId.length != 8) {
      emit(
        state.copyWith(
          message: 'Station id must be exactly 8 characters.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere(
      (c) => c.requestCommand.trim().startsWith('?06,'),
    );
    final wait = runningIndex >= 0
        ? state.commands[runningIndex].responseWaitTimeout
        : const Duration(seconds: 60);

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        '?06,$nextStationId,#',
        wait,
      );
      final updatedStationId = _extractStationId(line);
      if (updatedStationId == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message: 'Could not verify updated station id from response.',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      if (updatedStationId.toUpperCase() != nextStationId) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message:
                'Update failed. Device returned station id: $updatedStationId',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearStationIdPrompt: true,
          message: 'Station id updated successfully.',
          isSuccessMessage: true,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Set station id timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while updating station id.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Set station id error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onSubmitGeneralUserSetStationName(
    SubmitGeneralUserSetStationName event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final rawName = event.stationName.trim();
    if (rawName.isEmpty) {
      emit(
        state.copyWith(
          message: 'Station name is required.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (rawName.contains(',')) {
      emit(
        state.copyWith(
          message: 'Station name cannot contain a comma.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final paddedName = _padBleGeneralParameterField(
      rawName,
      16,
      'Station name',
    );

    final runningIndex = state.commands.indexWhere(
      (c) => c.requestCommand.trim().startsWith('?07,'),
    );
    final wait = runningIndex >= 0
        ? state.commands[runningIndex].responseWaitTimeout
        : const Duration(seconds: 60);

    final model = runningIndex >= 0 ? state.commands[runningIndex] : null;

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        '?07,$paddedName,#',
        wait,
      );
      final updatedName = _extractStationNameFromGeneralParameters(line);
      if (updatedName == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message: 'Could not verify updated station name from response.',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      if (updatedName.toUpperCase() != rawName.toUpperCase()) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message:
                'Update may have failed. Device returned station name: $updatedName',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearStationNamePrompt: true,
          message: 'Station name updated successfully.',
          isSuccessMessage: true,
          lastSnapshot: model != null
              ? SelfTestBleResponseSnapshot(
                  testName: model.testName,
                  responseLine: line,
                  hideResponseLine: true,
                  helpText: _formatGeneralSystemParametersBleSummary(line),
                  descriptionSuccess: true,
                )
              : null,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Set station name timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while updating station name.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Set station name error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  void _onOpenTransmissionTimePrompt(
    DrifterBuoyCommandModel cmd,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.loaded,
        clearRunningCommandIndex: true,
        transmissionTimePrompt: SelfTestTransmissionTimePrompt(
          testName: cmd.testName,
        ),
        clearLastSnapshot: true,
        message: '',
        isSuccessMessage: false,
      ),
    );
  }

  Future<void> _onOpenTransmissionIntervalPrompt(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
      ),
    );

    var initialTx = '';
    String? prefetchWarning;

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        _fetchStationIdCommand,
        cmd.responseWaitTimeout,
      );
      final parsed = _extractTxIntervalFromGeneralParameters(line);
      if (parsed != null) {
        initialTx = parsed;
      } else {
        prefetchWarning =
            'Could not parse Tx interval from device response. Enter manually (minimum 00:10:00).';
      }
    } on TimeoutException catch (e) {
      AppLogger.e('Prefetch Tx interval timeout', error: e);
      prefetchWarning =
          'Timed out reading parameters (?04). Enter Tx interval manually (minimum 00:10:00).';
    } catch (e, st) {
      AppLogger.e('Prefetch Tx interval error', error: e, stackTrace: st);
      prefetchWarning =
          'Could not read current Tx interval. Enter manually (minimum 00:10:00).';
    }

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.loaded,
        clearRunningCommandIndex: true,
        transmissionIntervalPrompt: SelfTestTransmissionIntervalPrompt(
          testName: cmd.testName,
          currentTxInterval: initialTx,
          prefetchWarning: prefetchWarning,
          catalogHelpText: cmd.requestCommandDescription,
        ),
        clearLastSnapshot: true,
        message: '',
        isSuccessMessage: false,
      ),
    );
  }

  Future<void> _onOpenMeasurementIntervalPrompt(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
      ),
    );

    var initialMi = '';
    String? prefetchWarning;

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        _fetchStationIdCommand,
        cmd.responseWaitTimeout,
      );
      final parsedMi = _extractMeasurementIntervalFromGeneralParameters(line);
      if (parsedMi != null) {
        initialMi = parsedMi;
      }
      if (parsedMi == null) {
        prefetchWarning =
            'Could not parse measurement interval from device response. Choose a value from the catalog list.';
      }
    } on TimeoutException catch (e) {
      AppLogger.e('Prefetch measurement interval timeout', error: e);
      prefetchWarning =
          'Timed out reading parameters (?04). Choose measurement interval from the list.';
    } catch (e, st) {
      AppLogger.e(
        'Prefetch measurement interval error',
        error: e,
        stackTrace: st,
      );
      prefetchWarning =
          'Could not read current parameters. Choose measurement interval from the catalog list.';
    }

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.loaded,
        clearRunningCommandIndex: true,
        measurementIntervalPrompt: SelfTestMeasurementIntervalPrompt(
          testName: cmd.testName,
          currentMeasurementInterval: initialMi,
          allowedMeasurementIntervals: List<String>.from(
            _allowedMeasurementIntervalHms,
          ),
          prefetchWarning: prefetchWarning,
          catalogHelpText: cmd.requestCommandDescription,
        ),
        clearLastSnapshot: true,
        message: '',
        isSuccessMessage: false,
      ),
    );
  }

  Future<void> _onOpenSetApnPrompt(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
      ),
    );

    var sim1 = '';
    var sim2 = '';
    String? prefetchWarning;

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        _fetchStationIdCommand,
        cmd.responseWaitTimeout,
      );
      final fields = _parseGeneralSystemParametersFields(line);
      if (fields == null || _isGeneralParametersPlaceholderPayload(fields)) {
        prefetchWarning =
            'Could not read current APN values from the device (?04). Enter APN manually.';
      } else {
        sim1 = _extractPrimaryApnFromGeneralParameters(line)?.trim() ?? '';
        sim2 = _extractSecondaryApnFromGeneralParameters(line)?.trim() ?? '';
      }
    } on TimeoutException catch (e) {
      AppLogger.e('Prefetch APN timeout', error: e);
      prefetchWarning =
          'Timed out reading parameters (?04). Enter APN manually.';
    } catch (e, st) {
      AppLogger.e('Prefetch APN error', error: e, stackTrace: st);
      prefetchWarning =
          'Could not read current APN values. Enter APN manually.';
    }

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.loaded,
        clearRunningCommandIndex: true,
        setApnPrompt: SelfTestSetApnPrompt(
          testName: cmd.testName,
          initialSim1Apn: sim1,
          initialSim2Apn: sim2,
          prefetchWarning: prefetchWarning,
          catalogHelpText: cmd.requestCommandDescription,
        ),
        clearLastSnapshot: true,
        message: '',
        isSuccessMessage: false,
      ),
    );
  }

  Future<void> _onOpenMeasurementStartTimePrompt(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        _fetchStationIdCommand,
        cmd.responseWaitTimeout,
      );
      final currentTime = _extractMeasurementStartTime(line);
      if (currentTime == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message:
                'Could not parse measurement start time from device response.',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          measurementTimePrompt: SelfTestMeasurementTimePrompt(
            currentTime: currentTime,
          ),
          clearLastSnapshot: true,
          message: '',
          isSuccessMessage: false,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Fetch measurement start time timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while reading measurement start time.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'Fetch measurement start time error',
        error: e,
        stackTrace: st,
      );
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onSubmitGeneralUserMeasurementStartTime(
    SubmitGeneralUserMeasurementStartTime event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final nextTime = _normalizeTime(event.timeValue);
    if (nextTime == null) {
      emit(
        state.copyWith(
          message: 'Time must be in HH:MM:SS format.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere(
      (c) => c.requestCommand.trim().startsWith('?61,'),
    );
    final wait = runningIndex >= 0
        ? state.commands[runningIndex].responseWaitTimeout
        : const Duration(seconds: 60);

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand('?61,$nextTime,#', wait);
      final updatedTime = _extractMeasurementStartTime(line);
      if (updatedTime == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message: 'Could not verify updated measurement start time.',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      if (updatedTime != nextTime) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message:
                'Update failed. Device returned measurement start time: $updatedTime',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearMeasurementTimePrompt: true,
          message: 'Measurement start time updated successfully.',
          isSuccessMessage: true,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Set measurement start time timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while updating measurement start time.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Set measurement start time error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onSubmitGeneralUserSetTransmissionTime(
    SubmitGeneralUserSetTransmissionTime event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final nextTime = _normalizeTime(event.timeValue);
    if (nextTime == null) {
      emit(
        state.copyWith(
          message: 'Time must be in HH:MM:SS format.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere(
      (c) => c.requestCommand.trim().startsWith('?08,'),
    );
    final wait = runningIndex >= 0
        ? state.commands[runningIndex].responseWaitTimeout
        : const Duration(seconds: 60);

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand('?08,$nextTime,#', wait);
      final updatedTime = _extractMeasurementStartTime(line);
      if (updatedTime == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message: 'Could not verify transmission time from device response.',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      if (updatedTime != nextTime) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message:
                'Update may have failed. Device returned time: $updatedTime',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearTransmissionTimePrompt: true,
          message: 'Transmission time updated successfully.',
          isSuccessMessage: true,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Set transmission time timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while updating transmission time.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Set transmission time error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onSubmitGeneralUserSetTransmissionInterval(
    SubmitGeneralUserSetTransmissionInterval event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final nextTime = _normalizeTime(event.timeValue);
    if (nextTime == null) {
      emit(
        state.copyWith(
          message: 'Time must be in HH:MM:SS format.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    const minTxSecs = 10 * 60;
    if (!_isHmsAtLeastSeconds(nextTime, minTxSecs)) {
      emit(
        state.copyWith(
          message:
              'Transmission interval must be at least 00:10:00 (catalog minimum).',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere(
      (c) => c.requestCommand.trim().startsWith('?09,'),
    );
    final wait = runningIndex >= 0
        ? state.commands[runningIndex].responseWaitTimeout
        : const Duration(seconds: 60);

    final model = runningIndex >= 0 ? state.commands[runningIndex] : null;

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand('?09,$nextTime,#', wait);
      final updatedTx = _extractTxIntervalFromGeneralParameters(line);
      if (updatedTx == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message:
                'Could not verify transmission interval from device response.',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      if (updatedTx != nextTime) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message:
                'Update may have failed. Device returned Tx interval: $updatedTx',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearTransmissionIntervalPrompt: true,
          message: 'Transmission interval updated successfully.',
          isSuccessMessage: true,
          lastSnapshot: model != null
              ? SelfTestBleResponseSnapshot(
                  testName: model.testName,
                  responseLine: line,
                  hideResponseLine: true,
                  helpText: _formatGeneralSystemParametersBleSummary(line),
                  descriptionSuccess: true,
                )
              : null,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Set transmission interval timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while updating transmission interval.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Set transmission interval error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onSubmitGeneralUserSetMeasurementInterval(
    SubmitGeneralUserSetMeasurementInterval event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final mi = _normalizeTime(event.measurementInterval.trim());
    if (mi == null || !_allowedMeasurementIntervalHms.contains(mi)) {
      emit(
        state.copyWith(
          message:
              'Measurement interval must be one of the catalog HH:MM:SS values.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere(
      (c) => c.id == _setMeasurementIntervalCommandId,
    );
    final wait = runningIndex >= 0
        ? state.commands[runningIndex].responseWaitTimeout
        : const Duration(seconds: 60);

    final model = runningIndex >= 0 ? state.commands[runningIndex] : null;

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand('?10,$mi,#', wait);
      final updatedMi = _extractMeasurementIntervalFromGeneralParameters(line);
      if (updatedMi == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message:
                'Could not verify measurement interval from device response.',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      if (updatedMi != mi) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message:
                'Update may have failed. Device returned measurement interval: $updatedMi',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearMeasurementIntervalPrompt: true,
          message: 'Measurement interval updated successfully.',
          isSuccessMessage: true,
          lastSnapshot: model != null
              ? SelfTestBleResponseSnapshot(
                  testName: model.testName,
                  responseLine: line,
                  hideResponseLine: true,
                  helpText: _formatGeneralSystemParametersBleSummary(line),
                  descriptionSuccess: true,
                )
              : null,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Set measurement interval timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while updating measurement interval.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Set measurement interval error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onSubmitGeneralUserSetApn(
    SubmitGeneralUserSetApn event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    late final String bleLine;
    try {
      bleLine = _buildSetApnBleCommand(
        apn: event.apnName,
        vodafoneOrOther: event.vodafoneOrOther,
        simSlot: event.simSlot,
      );
    } catch (e) {
      emit(state.copyWith(message: e.toString(), isSuccessMessage: false));
      return;
    }

    final runningIndex = state.commands.indexWhere(
      (c) => c.id == _setApnCommandId,
    );
    final wait = runningIndex >= 0
        ? state.commands[runningIndex].responseWaitTimeout
        : const Duration(seconds: 60);
    final model = runningIndex >= 0 ? state.commands[runningIndex] : null;

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final responseLine = await _ble.sendDrifterAsciiCommand(bleLine, wait);
      final summary = _summarizeSetAllGeneralParametersResponse(responseLine);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearSetApnPrompt: true,
          message: 'APN updated successfully.',
          isSuccessMessage: true,
          lastSnapshot: model != null
              ? SelfTestBleResponseSnapshot(
                  testName: model.testName,
                  responseLine: responseLine,
                  hideResponseLine: true,
                  helpText: summary,
                  descriptionSuccess: true,
                )
              : null,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Set APN timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message:
              'Timed out waiting for a response ending with # (${model?.testName ?? 'Set APN'}).',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Set APN error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onOpenFastSmsCheckPrompt(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
      ),
    );

    var enabled = false;
    String? prefetchWarning;

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        _fetchStationIdCommand,
        cmd.responseWaitTimeout,
      );
      final parsed = _extractFastSmsCheckFromGeneralParameters(line);
      if (parsed != null) {
        enabled = parsed;
      } else {
        prefetchWarning =
            'Could not parse Fast SMS check from device response. Default is off.';
      }
    } on TimeoutException catch (e) {
      AppLogger.e('Prefetch Fast SMS check timeout', error: e);
      prefetchWarning =
          'Timed out reading parameters (?04). Choose enable or disable.';
    } catch (e, st) {
      AppLogger.e('Prefetch Fast SMS check error', error: e, stackTrace: st);
      prefetchWarning =
          'Could not read current Fast SMS check. Choose enable or disable.';
    }

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.loaded,
        clearRunningCommandIndex: true,
        fastSmsCheckPrompt: SelfTestFastSmsCheckPrompt(
          testName: cmd.testName,
          enabled: enabled,
          prefetchWarning: prefetchWarning,
          catalogHelpText: cmd.requestCommandDescription,
        ),
        clearLastSnapshot: true,
        message: '',
        isSuccessMessage: false,
      ),
    );
  }

  Future<void> _onSubmitGeneralUserFastSmsCheck(
    SubmitGeneralUserFastSmsCheck event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final n = event.enabled ? 1 : 0;
    final runningIndex = state.commands.indexWhere(
      (c) => c.id == _fastSmsCheckCommandId,
    );
    final wait = runningIndex >= 0
        ? state.commands[runningIndex].responseWaitTimeout
        : const Duration(seconds: 60);
    final model = runningIndex >= 0 ? state.commands[runningIndex] : null;

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final responseLine = await _ble.sendDrifterAsciiCommand('?58,$n,#', wait);
      final summary = _summarizeSetAllGeneralParametersResponse(responseLine);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearFastSmsCheckPrompt: true,
          message: 'Fast SMS check updated successfully.',
          isSuccessMessage: true,
          lastSnapshot: model != null
              ? SelfTestBleResponseSnapshot(
                  testName: model.testName,
                  responseLine: responseLine,
                  hideResponseLine: true,
                  helpText: summary,
                  descriptionSuccess: true,
                )
              : null,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Fast SMS check timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message:
              'Timed out waiting for a response ending with # (${model?.testName ?? 'Fast SMS check'}).',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Fast SMS check error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onOpenTransmitterFrequencyPrompt(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        _transmitterFrequencyRequestCommand(n: 0, s: 0),
        cmd.responseWaitTimeout,
      );
      final parsed = _extractTransmitterFrequency(line);
      if (parsed == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message: 'Could not parse transmitter frequency response.',
            isSuccessMessage: false,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          transmitterFrequencyPrompt: SelfTestTransmitterFrequencyPrompt(
            transmitterType: parsed.$1,
            frequencyValue: parsed.$2,
          ),
          clearLastSnapshot: true,
          message: '',
          isSuccessMessage: false,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Fetch transmitter frequency timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while reading transmitter frequency.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'Fetch transmitter frequency error',
        error: e,
        stackTrace: st,
      );
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onSubmitGeneralUserTransmitterFrequency(
    SubmitGeneralUserTransmitterFrequency event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final n = event.transmitterType == 1 ? 1 : 0;
    final ffff = _normalizeFfff(event.frequencyValue);
    if (ffff == null) {
      emit(
        state.copyWith(
          message: 'Frequency must be a 4-digit value.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere(
      (c) => c.id == _transmitterFrequencyCommandId,
    );
    final wait = runningIndex >= 0
        ? state.commands[runningIndex].responseWaitTimeout
        : const Duration(seconds: 60);

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        _transmitterFrequencyRequestCommand(n: n, s: 1, ffffFourDigits: ffff),
        wait,
      );
      final parsed = _extractTransmitterFrequency(line);
      if (parsed == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message: 'Could not verify updated transmitter frequency.',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      final statusCode = parsed.$3;
      final updatedN = parsed.$1;
      final updatedFfff = parsed.$2;
      if (statusCode != 0) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message: 'Frequency update failed. Device status code: $statusCode',
            isSuccessMessage: false,
          ),
        );
        return;
      }
      if (updatedN != n || updatedFfff != ffff) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message:
                'Frequency update mismatch. Device returned N=$updatedN FFFF=$updatedFfff',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearTransmitterFrequencyPrompt: true,
          message: 'Transmitter frequency updated successfully.',
          isSuccessMessage: true,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Set transmitter frequency timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while updating transmitter frequency.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Set transmitter frequency error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onOpenSetAttenuationPrompt(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        '?66,0,0,#',
        cmd.responseWaitTimeout,
      );
      final parsed = _extractSetAttenuation(line);
      if (parsed == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message: 'Could not parse set attenuation response.',
            isSuccessMessage: false,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          setAttenuationPrompt: SelfTestSetAttenuationPrompt(
            transmitterType: parsed.$1,
            attenuationValue: parsed.$2,
          ),
          clearLastSnapshot: true,
          message: '',
          isSuccessMessage: false,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Fetch set attenuation timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while reading attenuation value.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Fetch set attenuation error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onSubmitGeneralUserSetAttenuation(
    SubmitGeneralUserSetAttenuation event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final n = event.transmitterType == 1 ? 1 : 0;
    final xx = _normalizeAttenuationXx(event.attenuationValue);
    if (xx == null) {
      emit(
        state.copyWith(
          message: 'Attenuation must be a 2-digit value.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere(
      (c) => c.id == _setAttenuationCommandId,
    );
    final wait = runningIndex >= 0
        ? state.commands[runningIndex].responseWaitTimeout
        : const Duration(seconds: 60);

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand('?66,$n,1,$xx,#', wait);
      final parsed = _extractSetAttenuation(line);
      if (parsed == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message: 'Could not verify updated attenuation.',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      final updatedN = parsed.$1;
      final statusCode = parsed.$3;
      final updatedXx = parsed.$2;
      if (statusCode != 0 && statusCode != 1) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message: 'Set attenuation failed. Device status code: $statusCode',
            isSuccessMessage: false,
          ),
        );
        return;
      }
      if (updatedN != n || updatedXx != xx) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message:
                'Attenuation update mismatch. Device returned N=$updatedN xx=$updatedXx',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearSetAttenuationPrompt: true,
          message: 'Set attenuation updated successfully.',
          isSuccessMessage: true,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Set attenuation timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while updating attenuation value.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Set attenuation error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onOpenRadioSondeTransmitterIdPrompt(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        _radioSondeTransmitterIdRequestCommand(s: 0),
        cmd.responseWaitTimeout,
      );
      final id = _extractRadioSondeTransmitterId(line);
      if (id == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message:
                'Could not parse radio sonde transmitter id from device response.',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          radioSondeTransmitterIdPrompt: SelfTestRadioSondeTransmitterIdPrompt(
            currentTransmitterId: id,
          ),
          clearLastSnapshot: true,
          message: '',
          isSuccessMessage: false,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Fetch radio sonde transmitter id timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while reading radio sonde transmitter id.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'Fetch radio sonde transmitter id error',
        error: e,
        stackTrace: st,
      );
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onSubmitGeneralUserRadioSondeTransmitterId(
    SubmitGeneralUserRadioSondeTransmitterId event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final nextId = event.transmitterId.trim().toUpperCase();
    if (nextId.length != 5) {
      emit(
        state.copyWith(
          message: 'Radio sonde transmitter id must be exactly 5 characters.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere(
      (c) => c.id == _radioSondeTransmitterIdCommandId,
    );
    final wait = runningIndex >= 0
        ? state.commands[runningIndex].responseWaitTimeout
        : const Duration(seconds: 60);

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        _radioSondeTransmitterIdRequestCommand(s: 1, fiveCharId: nextId),
        wait,
      );
      final updatedId = _extractRadioSondeTransmitterId(line);
      if (updatedId == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message: 'Could not verify updated radio sonde transmitter id.',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      if (updatedId.toUpperCase() != nextId) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message:
                'Update failed. Device returned radio sonde transmitter id: $updatedId',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearRadioSondeTransmitterIdPrompt: true,
          message: 'Radio sonde transmitter id updated successfully.',
          isSuccessMessage: true,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Set radio sonde transmitter id timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while updating radio sonde transmitter id.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'Set radio sonde transmitter id error',
        error: e,
        stackTrace: st,
      );
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  void _onClearGeneralUserSetStationIdPrompt(
    ClearGeneralUserSetStationIdPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearStationIdPrompt: true));
  }

  void _onClearGeneralUserSetStationNamePrompt(
    ClearGeneralUserSetStationNamePrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearStationNamePrompt: true));
  }

  void _onClearGeneralUserMeasurementStartTimePrompt(
    ClearGeneralUserMeasurementStartTimePrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearMeasurementTimePrompt: true));
  }

  void _onClearGeneralUserTransmissionTimePrompt(
    ClearGeneralUserTransmissionTimePrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearTransmissionTimePrompt: true));
  }

  void _onClearGeneralUserTransmissionIntervalPrompt(
    ClearGeneralUserTransmissionIntervalPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearTransmissionIntervalPrompt: true));
  }

  void _onClearGeneralUserMeasurementIntervalPrompt(
    ClearGeneralUserMeasurementIntervalPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearMeasurementIntervalPrompt: true));
  }

  void _onClearGeneralUserSetApnPrompt(
    ClearGeneralUserSetApnPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearSetApnPrompt: true));
  }

  void _onClearGeneralUserFastSmsCheckPrompt(
    ClearGeneralUserFastSmsCheckPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearFastSmsCheckPrompt: true));
  }

  Future<void> _onOpenAdminSmsCellPrompt(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
      ),
    );

    var initialMobile = '';
    String? prefetchWarning;
    final isAdmin1 = cmd.id == _setAdmin1SmsCellNoCommandId;

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        _fetchStationIdCommand,
        cmd.responseWaitTimeout,
      );
      final parsed = isAdmin1
          ? _extractAdminCell1FromGeneralParameters(line)
          : _extractAdminCell2FromGeneralParameters(line);
      if (parsed != null && parsed.isNotEmpty) {
        initialMobile = parsed;
      } else {
        prefetchWarning = isAdmin1
            ? 'Could not parse admin cell no. 1 from device response. Enter manually.'
            : 'Could not parse admin cell no. 2 from device response. Enter manually.';
      }
    } on TimeoutException catch (e) {
      AppLogger.e('Prefetch admin SMS cell timeout', error: e);
      prefetchWarning =
          'Timed out reading parameters (?04). Enter mobile number manually.';
    } catch (e, st) {
      AppLogger.e('Prefetch admin SMS cell error', error: e, stackTrace: st);
      prefetchWarning =
          'Could not read current admin cell number. Enter manually.';
    }

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.loaded,
        clearRunningCommandIndex: true,
        adminSmsCellPrompt: SelfTestAdminSmsCellPrompt(
          commandId: cmd.id,
          testName: cmd.testName,
          initialMobileNumber: initialMobile,
          prefetchWarning: prefetchWarning,
          catalogHelpText: cmd.requestCommandDescription,
        ),
        clearLastSnapshot: true,
        message: '',
        isSuccessMessage: false,
      ),
    );
  }

  Future<void> _onSubmitGeneralUserAdminSmsCell(
    SubmitGeneralUserAdminSmsCell event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    final commandId = event.commandId.trim();
    if (commandId != _setAdmin1SmsCellNoCommandId &&
        commandId != _setAdmin2SmsCellNoCommandId) {
      emit(
        state.copyWith(
          message: 'Unknown admin SMS cell command.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final model = _staticCommandsById[commandId];
    if (model == null) {
      emit(
        state.copyWith(
          message: 'Admin SMS cell command is not configured.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    late final String bleLine;
    try {
      bleLine = _buildParameterizedServerBleCommand(
        model,
        SelfTestParameterizedCommandFieldKind.smsCellPlus91,
        event.mobileNumber,
      );
    } on ArgumentError catch (e) {
      emit(
        state.copyWith(
          message: e.message?.toString() ?? e.toString(),
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere((c) => c.id == commandId);
    final wait = model.responseWaitTimeout;

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final responseLine = await _ble.sendDrifterAsciiCommand(bleLine, wait);
      final summary = _formatAdminSmsCellSetResponseSummary(responseLine);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearAdminSmsCellPrompt: true,
          message: '${model.testName} updated successfully.',
          isSuccessMessage: true,
          lastSnapshot: SelfTestBleResponseSnapshot(
            testName: model.testName,
            responseLine: responseLine,
            hideResponseLine: true,
            helpText: summary,
            descriptionSuccess: true,
          ),
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Admin SMS cell timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message:
              'Timed out waiting for a response ending with # (${model.testName}).',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Admin SMS cell error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  void _onClearGeneralUserAdminSmsCellPrompt(
    ClearGeneralUserAdminSmsCellPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearAdminSmsCellPrompt: true));
  }

  void _onClearGeneralUserTransmitterFrequencyPrompt(
    ClearGeneralUserTransmitterFrequencyPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearTransmitterFrequencyPrompt: true));
  }

  void _onClearGeneralUserSetAttenuationPrompt(
    ClearGeneralUserSetAttenuationPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearSetAttenuationPrompt: true));
  }

  void _onClearGeneralUserRadioSondeTransmitterIdPrompt(
    ClearGeneralUserRadioSondeTransmitterIdPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearRadioSondeTransmitterIdPrompt: true));
  }

  Future<void> _onSubmitGeneralUserTransmitterTest(
    SubmitGeneralUserTransmitterTest event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere(
      (c) => c.id == _transmitterTestCommandId,
    );
    final wait = runningIndex >= 0
        ? state.commands[runningIndex].responseWaitTimeout
        : const Duration(seconds: 60);

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    final desired = <(int, bool)>[
      (0, event.plainCarrierOn),
      (1, event.modulationOn),
      (2, event.prbsOn),
    ];
    final resultLines = <String>[];
    final failures = <String>[];
    const names = ['Plain carrier', 'Modulation', 'PRBS'];

    try {
      for (final item in desired) {
        final n = item.$1;
        final on = item.$2;
        final s = on ? 0 : 1;
        final line = await _ble.sendDrifterAsciiCommand('?64,$n,$s,#', wait);
        resultLines.add(line);
        final status = _extractTransmitterTestStatus(line);
        final isOk = status == 0;
        if (!isOk) {
          failures.add('${names[n]} (${_transmitterTestStatusText(status)})');
        }
      }

      if (failures.isNotEmpty) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message:
                'Transmitter test update partially failed: ${failures.join(', ')}',
            isSuccessMessage: false,
            lastSnapshot: SelfTestBleResponseSnapshot(
              testName: 'Transmitter Test',
              responseLine: resultLines.join('\n'),
              helpText: 'Transmitter test Not OK.',
              hideResponseLine: true,
              descriptionSuccess: false,
            ),
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearTransmitterTestPrompt: true,
          message: 'Transmitter test updated successfully.',
          isSuccessMessage: true,
          lastSnapshot: SelfTestBleResponseSnapshot(
            testName: 'Transmitter Test',
            responseLine: resultLines.join('\n'),
            helpText: 'Transmitter test OK.',
            hideResponseLine: true,
            descriptionSuccess: true,
          ),
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Transmitter test timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while updating transmitter test.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Transmitter test error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onOpenCheckStatusPrompt(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
      ),
    );

    try {
      final line = await _ble.sendDrifterAsciiCommand(
        '?02,,#',
        cmd.responseWaitTimeout,
      );
      final parsed = _parseCheckStatus(line);
      if (parsed == null) {
        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            clearRunningCommandIndex: true,
            message: 'Could not parse check status response.',
            isSuccessMessage: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          checkStatusPrompt: parsed,
          message: 'Check status fetched successfully.',
          isSuccessMessage: true,
          clearLastSnapshot: true,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Check status timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: 'Timed out while fetching check status.',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Check status error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  void _onClearGeneralUserTransmitterTestPrompt(
    ClearGeneralUserTransmitterTestPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearTransmitterTestPrompt: true));
  }

  void _onClearGeneralUserCheckStatusPrompt(
    ClearGeneralUserCheckStatusPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearCheckStatusPrompt: true));
  }

  String? _extractStationNameFromGeneralParameters(String responseLine) {
    final fields = _parseGeneralSystemParametersFields(responseLine);
    if (fields == null ||
        fields.length < 2 ||
        _isGeneralParametersPlaceholderPayload(fields)) {
      return null;
    }
    final name = fields[1].trim();
    if (name.isEmpty || name.toLowerCase().contains('list of general')) {
      return null;
    }
    return name;
  }

  String? _extractTxIntervalFromGeneralParameters(String responseLine) {
    final fields = _parseGeneralSystemParametersFields(responseLine);
    if (fields == null ||
        fields.length < 3 ||
        _isGeneralParametersPlaceholderPayload(fields)) {
      return null;
    }
    final raw = fields[2].trim();
    if (raw.isEmpty || raw.toLowerCase().contains('list of general')) {
      return null;
    }
    return _normalizeTime(raw);
  }

  String? _extractMeasurementIntervalFromGeneralParameters(
    String responseLine,
  ) {
    final fields = _parseGeneralSystemParametersFields(responseLine);
    if (fields == null ||
        fields.length < 4 ||
        _isGeneralParametersPlaceholderPayload(fields)) {
      return null;
    }
    final raw = fields[3].trim();
    if (raw.isEmpty || raw.toLowerCase().contains('list of general')) {
      return null;
    }
    return _normalizeTime(raw);
  }

  String? _extractPrimaryApnFromGeneralParameters(String responseLine) {
    final fields = _parseGeneralSystemParametersFields(responseLine);
    if (fields == null ||
        fields.length < 5 ||
        _isGeneralParametersPlaceholderPayload(fields)) {
      return null;
    }
    final raw = fields[4].trim();
    if (raw.toLowerCase().contains('list of general')) {
      return null;
    }
    return raw;
  }

  String? _extractSecondaryApnFromGeneralParameters(String responseLine) {
    final fields = _parseGeneralSystemParametersFields(responseLine);
    if (fields == null ||
        fields.length < 6 ||
        _isGeneralParametersPlaceholderPayload(fields)) {
      return null;
    }
    final raw = fields[5].trim();
    if (raw.toLowerCase().contains('list of general')) {
      return null;
    }
    return raw;
  }

  /// Fast SMS check — field index 6 in `?04` / `$58` general-parameters payload.
  bool? _extractFastSmsCheckFromGeneralParameters(String responseLine) {
    final fields = _parseGeneralSystemParametersFields(responseLine);
    if (fields == null ||
        fields.length < 7 ||
        _isGeneralParametersPlaceholderPayload(fields)) {
      return null;
    }
    final raw = fields[6].trim();
    if (raw.isEmpty || raw.toLowerCase().contains('list of general')) {
      return null;
    }
    if (raw == '0') {
      return false;
    }
    if (raw == '1') {
      return true;
    }
    return null;
  }

  String? _extractAdminCell1FromGeneralParameters(String responseLine) {
    final fields = _parseGeneralSystemParametersFields(responseLine);
    if (fields == null ||
        fields.length < 8 ||
        _isGeneralParametersPlaceholderPayload(fields)) {
      return null;
    }
    final raw = fields[7].trim();
    if (raw.isEmpty || raw.toLowerCase().contains('list of general')) {
      return null;
    }
    return raw;
  }

  String? _extractAdminCell2FromGeneralParameters(String responseLine) {
    final fields = _parseGeneralSystemParametersFields(responseLine);
    if (fields == null ||
        fields.length < 9 ||
        _isGeneralParametersPlaceholderPayload(fields)) {
      return null;
    }
    final raw = fields[8].trim();
    if (raw.isEmpty || raw.toLowerCase().contains('list of general')) {
      return null;
    }
    return raw;
  }

  static String _buildSetApnBleCommand({
    required String apn,
    required int vodafoneOrOther,
    required int simSlot,
  }) {
    if (vodafoneOrOther != 0 && vodafoneOrOther != 1) {
      throw ArgumentError('Para 2 must be 0 (Vodafone) or 1 (other SIM).');
    }
    if (simSlot != 1 && simSlot != 2) {
      throw ArgumentError('Para 3 must be 1 (SIM1) or 2 (SIM2).');
    }
    final trimmed = apn.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('APN is required.');
    }
    if (trimmed.length > 31) {
      throw ArgumentError('APN must be at most 31 characters.');
    }
    if (trimmed.contains(',')) {
      throw ArgumentError('APN cannot contain a comma.');
    }
    return '?11,$trimmed,$vodafoneOrOther,$simSlot,#';
  }

  bool _isHmsAtLeastSeconds(String normalizedHms, int minTotalSeconds) {
    final m = RegExp(r'^(\d{2}):(\d{2}):(\d{2})$').firstMatch(normalizedHms);
    if (m == null) {
      return false;
    }
    final h = int.parse(m.group(1)!);
    final mm = int.parse(m.group(2)!);
    final s = int.parse(m.group(3)!);
    final total = h * 3600 + mm * 60 + s;
    return total >= minTotalSeconds;
  }

  String? _extractStationId(String responseLine) {
    final fields = _parseGeneralSystemParametersFields(responseLine);
    if (fields != null && fields.isNotEmpty) {
      final id = fields.first.trim();
      if (id.isNotEmpty && !id.toLowerCase().contains('list of general')) {
        return id.length >= 8 ? id.substring(0, 8) : id;
      }
    }
    final cleaned = responseLine.trim();
    if (cleaned.isEmpty) {
      return null;
    }
    final parts = cleaned.split(',');
    if (parts.isEmpty) {
      return null;
    }
    // Typical payload: `$04,KISHAN12,...#`
    // If first token is command marker (`$04`/`?04`), station id is the second token.
    final first = parts.first.trim();
    final candidate =
        ((first.startsWith(r'$') || first.startsWith('?')) && parts.length > 1)
        ? parts[1].trim()
        : first;
    if (candidate.isEmpty) {
      return null;
    }
    return candidate.length >= 8 ? candidate.substring(0, 8) : candidate;
  }

  /// Comma-separated payload after `$04` / `$06` / etc. opcode (11 parameter fields).
  static const List<String> _generalSystemParameterLabels = [
    'Station id',
    'Station name',
    'Tx interval',
    'Measurement interval',
    'APN',
    'APN',
    'Fast SMS check',
    'Admin cell no.1',
    'Admin cell no. 2',
    'Sensor power on time',
    'Measurement start time',
  ];

  static List<String>? _parseGeneralSystemParametersFields(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final hash = trimmed.indexOf('#');
    final noHash = hash >= 0 ? trimmed.substring(0, hash) : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.isEmpty) {
      return null;
    }
    final start = (parts.first.startsWith(r'$') || parts.first.startsWith('?'))
        ? 1
        : 0;
    if (start >= parts.length) {
      return null;
    }
    return parts.sublist(start);
  }

  /// Formats `$03` / `$04` / `$10` / `$58` / `$59` / `$60` as labeled key:value lines.
  static String _formatGeneralSystemParametersBleSummary(
    String rawLine, {
    String heading = 'Read-back from device:',
  }) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'No response text was received.';
    }
    final fields = _parseGeneralSystemParametersFields(rawLine);
    if (fields == null || fields.isEmpty) {
      return 'Could not parse general system parameters.\n\n'
          'Raw response:\n$trimmed';
    }
    if (fields.length == 1) {
      final lower = fields.first.toLowerCase();
      if (lower.contains('list of general') ||
          lower.contains('list of all') ||
          lower.contains('ist of all')) {
        return 'The device did not return parameter values.\n\n'
            'Raw response:\n$trimmed';
      }
    }
    String valueAt(int index) {
      if (index >= fields.length) {
        return '—';
      }
      final v = fields[index].trim();
      if (v.isEmpty) {
        return '—';
      }
      if (index == 6) {
        return switch (v) {
          '0' => '0 — Disable',
          '1' => '1 — Enable',
          _ => v,
        };
      }
      return v;
    }

    final lines = <String>[heading, ''];
    for (var i = 0; i < _generalSystemParameterLabels.length; i++) {
      lines.add('${_generalSystemParameterLabels[i]}: ${valueAt(i)}');
    }
    return lines.join('\n');
  }

  /// Success popup for **Restore Default Parameters** (`?03` → `$03,…,#`).
  static String _formatRestoreDefaultParametersBleSummary(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'No response text was received.';
    }
    final upper = trimmed.toUpperCase();
    if (!upper.contains(r'$03')) {
      return _formatGeneralSystemParametersBleSummary(
        rawLine,
        heading: 'Device response:',
      );
    }
    return _formatGeneralSystemParametersBleSummary(
      rawLine,
      heading: 'Default parameters restored:',
    );
  }

  String? _extractMeasurementStartTime(String responseLine) {
    final cleaned = responseLine.trim();
    if (cleaned.isEmpty) {
      return null;
    }
    final matches = RegExp(r'\b\d{2}:\d{2}:\d{2}\b').allMatches(cleaned);
    if (matches.isEmpty) {
      return null;
    }
    return matches.last.group(0);
  }

  String? _normalizeTime(String value) {
    final raw = value.trim();
    final m = RegExp(r'^(\d{2}):(\d{2}):(\d{2})$').firstMatch(raw);
    if (m == null) {
      return null;
    }
    final hh = int.parse(m.group(1)!);
    final mm = int.parse(m.group(2)!);
    final ss = int.parse(m.group(3)!);
    if (hh < 0 || hh > 23 || mm < 0 || mm > 59 || ss < 0 || ss > 59) {
      return null;
    }
    return '${m.group(1)}:${m.group(2)}:${m.group(3)}';
  }

  (int, String, int)? _extractTransmitterFrequency(String responseLine) {
    final cleaned = responseLine.trim();
    if (cleaned.isEmpty) {
      return null;
    }
    final parts = cleaned.split(',').map((e) => e.trim()).toList();
    if (parts.length < 5) {
      return null;
    }
    final n = int.tryParse(parts[2]);
    final statusCode = int.tryParse(parts[3]);
    final ffff = _normalizeFfff(parts[4]);
    if (n == null || statusCode == null || ffff == null) {
      return null;
    }
    return (n, ffff, statusCode);
  }

  String? _normalizeFfff(String value) {
    final onlyDigits = value.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.length != 4) {
      return null;
    }
    return onlyDigits;
  }

  (int, String, int)? _extractSetAttenuation(String responseLine) {
    final cleaned = responseLine.trim();
    if (cleaned.isEmpty) {
      return null;
    }
    final parts = cleaned.split(',').map((e) => e.trim()).toList();
    if (parts.length < 5) {
      return null;
    }
    final n = int.tryParse(parts[2]);
    final statusCode = int.tryParse(parts[3]);
    final xx = _normalizeAttenuationXx(parts[4]);
    if (n == null || statusCode == null || xx == null) {
      return null;
    }
    return (n, xx, statusCode);
  }

  String? _normalizeAttenuationXx(String value) {
    final onlyDigits = value.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.isEmpty || onlyDigits.length > 2) {
      return null;
    }
    return onlyDigits.padLeft(2, '0');
  }

  String? _extractRadioSondeTransmitterId(String responseLine) {
    final cleaned = responseLine.trim();
    if (cleaned.isEmpty) {
      return null;
    }
    final parts = cleaned.split(',').map((e) => e.trim()).toList();
    if (parts.length < 4) {
      return null;
    }
    final id = parts[3].replaceAll('#', '').trim();
    if (id.isEmpty) {
      return null;
    }
    return id.length >= 5 ? id.substring(0, 5) : id;
  }

  int _extractTransmitterTestStatus(String responseLine) {
    final cleaned = responseLine.trim();
    if (cleaned.isEmpty) {
      return -1;
    }
    final normalized = cleaned.replaceAll('#', '').trim();
    final parts = normalized
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    for (var i = parts.length - 1; i >= 0; i--) {
      final status = int.tryParse(parts[i]);
      if (status != null) {
        return status;
      }
    }
    return -1;
  }

  String _transmitterTestStatusText(int status) {
    if (status == 0) {
      return 'S=0 Transmitter test OK';
    }
    if (status == 1) {
      return 'S=1 Transmitter test Not OK';
    }
    return 'Unknown status=$status';
  }

  /// Parses `$02,PP,GG,GG,GG,GG,F1,MT1,F2,MT2,CH,DL firmware…#` (extra commas in
  /// the firmware segment are re-joined). If CH is omitted, the last field is
  /// treated as firmware and [chargeStatus] is left empty for the UI.
  SelfTestCheckStatusPrompt? _parseCheckStatus(String responseLine) {
    final cleaned = responseLine.trim().replaceAll('#', '').trim();
    if (cleaned.isEmpty) {
      return null;
    }
    final parts = cleaned
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.length < 10) {
      return null;
    }
    final code = parts[0].toUpperCase();
    if (!code.startsWith(r'$02') && code != '02') {
      return null;
    }

    final pp = parts[1];
    final g1 = parts[2];
    final g2 = parts[3];
    final g3 = parts[4];
    final g4 = parts[5];
    final f1 = parts[6];
    final mt1 = parts[7];
    final f2 = parts[8];
    final mt2 = parts[9];

    String ch;
    String fw;
    if (parts.length >= 12) {
      ch = parts[10];
      fw = parts.sublist(11).join(', ');
    } else if (parts.length == 11) {
      final last = parts[10];
      if (last.length == 1) {
        final cv = int.tryParse(last);
        if (cv != null && cv >= 0 && cv <= 2) {
          ch = last;
          fw = '';
        } else {
          ch = '';
          fw = last;
        }
      } else {
        ch = '';
        fw = last;
      }
    } else {
      ch = '';
      fw = '';
    }

    return SelfTestCheckStatusPrompt(
      peripheralStatus: pp,
      gprsPrimary: g1,
      gprsSecondary: g2,
      gprsThird: g3,
      gprsFactory: g4,
      memory1Fail: f1,
      memory1Test: mt1,
      memory2Fail: f2,
      memory2Test: mt2,
      chargeStatus: ch,
      firmwareVersion: fw,
    );
  }

  void _onClearGeneralUserSelfTestDebugMessage(
    ClearGeneralUserSelfTestDebugMessage event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(message: '', isSuccessMessage: false));
  }

  Future<void> _onOpenSetAllGeneralParametersPrompt(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
        clearSetAllGeneralParametersPrompt: true,
      ),
    );

    var draft = const SelfTestSetAllGeneralParametersDraft();
    String? prefetchWarning;

    try {
      final getModel =
          _staticCommandsById[_getAllGeneralSystemParametersCommandId];
      final wait = getModel?.responseWaitTimeout ?? cmd.responseWaitTimeout;
      final line = await _ble.sendDrifterAsciiCommand(
        _fetchStationIdCommand,
        wait,
      );
      final fields = _parseGeneralSystemParametersFields(line);
      if (fields != null &&
          fields.length >= 11 &&
          !_isGeneralParametersPlaceholderPayload(fields)) {
        draft = SelfTestSetAllGeneralParametersDraft(
          stationId: fields[0].trim(),
          stationName: fields[1].trim(),
          txInterval: fields[2].trim(),
          measurementInterval: fields[3].trim(),
          apn: fields[4].trim(),
          fastSmsCheck: fields[6].trim(),
          adminCell1: fields[7].trim(),
          adminCell2: fields[8].trim(),
          measurementStartTime: fields[10].trim(),
        );
      } else {
        prefetchWarning =
            'Could not read current values from the device. Enter all fields manually.';
      }
    } on TimeoutException catch (e) {
      AppLogger.e('Prefetch general parameters timeout', error: e);
      prefetchWarning =
          'Timed out reading current parameters. Enter all fields manually.';
    } catch (e, st) {
      AppLogger.e(
        'Prefetch general parameters error',
        error: e,
        stackTrace: st,
      );
      prefetchWarning =
          'Could not read current parameters. Enter all fields manually.';
    }

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.loaded,
        clearRunningCommandIndex: true,
        setAllGeneralParametersPrompt: SelfTestSetAllGeneralParametersPrompt(
          commandId: _setAllGeneralSystemParametersCommandId,
          testName: cmd.testName,
          initial: draft,
          prefetchWarning: prefetchWarning,
          catalogHelpText: cmd.requestCommandDescription,
        ),
      ),
    );
  }

  Future<void> _runSetAllGeneralParameters(
    Emitter<GeneralUserSelfTestDebugState> emit, {
    required String stationId,
    required String stationName,
    required String txInterval,
    required String measurementInterval,
    required String apn,
    required String fastSmsCheck,
    required String adminCell1,
    required String adminCell2,
    required String measurementStartTime,
  }) async {
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final model = _staticCommandsById[_setAllGeneralSystemParametersCommandId];
    if (model == null) {
      emit(
        state.copyWith(
          message: 'Set all general parameters command is not configured.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    late final String bleLine;
    try {
      bleLine = _buildSetAllGeneralSystemParametersBleCommand(
        stationId: stationId,
        stationName: stationName,
        txInterval: txInterval,
        measurementInterval: measurementInterval,
        apn: apn,
        fastSmsCheck: fastSmsCheck,
        adminCell1: adminCell1,
        adminCell2: adminCell2,
        measurementStartTime: measurementStartTime,
      );
    } on ArgumentError catch (e) {
      emit(
        state.copyWith(
          message: e.message?.toString() ?? e.toString(),
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere(
      (c) => c.id == _setAllGeneralSystemParametersCommandId,
    );
    final wait = model.responseWaitTimeout;

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final responseLine = await _ble.sendDrifterAsciiCommand(bleLine, wait);
      final summary = _summarizeSetAllGeneralParametersResponse(responseLine);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearSetAllGeneralParametersPrompt: true,
          message: 'General system parameters updated successfully.',
          isSuccessMessage: true,
          lastSnapshot: SelfTestBleResponseSnapshot(
            testName: model.testName,
            responseLine: responseLine,
            hideResponseLine: true,
            helpText: summary,
            descriptionSuccess: true,
          ),
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Set all general parameters timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message:
              'Timed out waiting for a response ending with # (${model.testName}).',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Set all general parameters error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onSubmitGeneralUserSetAllGeneralParameters(
    SubmitGeneralUserSetAllGeneralParameters event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    final d = event.draft;
    await _runSetAllGeneralParameters(
      emit,
      stationId: d.stationId,
      stationName: d.stationName,
      txInterval: d.txInterval,
      measurementInterval: d.measurementInterval,
      apn: d.apn,
      fastSmsCheck: d.fastSmsCheck,
      adminCell1: d.adminCell1,
      adminCell2: d.adminCell2,
      measurementStartTime: d.measurementStartTime,
    );
  }

  void _onClearGeneralUserSetAllGeneralParametersPrompt(
    ClearGeneralUserSetAllGeneralParametersPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearSetAllGeneralParametersPrompt: true));
  }

  Future<void> _onOpenSetAllServerParametersPrompt(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
        clearSetAllServerParametersPrompt: true,
      ),
    );

    var draft = const SelfTestSetAllServerParametersDraft();
    String? prefetchWarning;
    final getId = _setAllToGetServerCommandId[cmd.id];

    if (getId != null) {
      final getModel = _staticCommandsById[getId];
      if (getModel != null) {
        try {
          final line = await _ble.sendDrifterAsciiCommand(
            getModel.requestCommand,
            getModel.responseWaitTimeout,
          );
          final fields = _parseServerSettingsFields(line);
          if (fields != null && fields.length >= 8) {
            final r = int.tryParse(fields[7]) ?? 0;
            draft = SelfTestSetAllServerParametersDraft(
              stationId: fields[0],
              ftpAddress: fields[1],
              ftpPort: fields[2],
              ftpPath: fields[3],
              ftpUsername: fields[4],
              ftpPassword: fields[5],
              cellNo: fields[6],
              txRedundancy: (r == 1) ? 1 : 0,
            );
          } else {
            prefetchWarning =
                'Could not read current server values from device. Enter all fields manually.';
          }
        } on TimeoutException catch (e) {
          AppLogger.e('Prefetch set-all-server timeout', error: e);
          prefetchWarning =
              'Timed out reading current server values. Enter all fields manually.';
        } catch (e, st) {
          AppLogger.e(
            'Prefetch set-all-server error',
            error: e,
            stackTrace: st,
          );
          prefetchWarning =
              'Could not read current server values. Enter all fields manually.';
        }
      }
    }

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.loaded,
        clearRunningCommandIndex: true,
        setAllServerParametersPrompt: SelfTestSetAllServerParametersPrompt(
          commandId: cmd.id,
          testName: cmd.testName,
          initial: draft,
          prefetchWarning: prefetchWarning,
          catalogHelpText: cmd.requestCommandDescription,
        ),
      ),
    );
  }

  Future<void> _runSetAllServerParameters(
    Emitter<GeneralUserSelfTestDebugState> emit, {
    required String setCommandId,
    required String stationId,
    required String ftpAddress,
    required String ftpPort,
    required String ftpPath,
    required String ftpUsername,
    required String ftpPassword,
    required String cellNo,
    required String txRedundancy,
  }) async {
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final model = _staticCommandsById[setCommandId];
    if (model == null) {
      emit(
        state.copyWith(
          message: 'Set all server parameters command is not configured.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    late final String bleLine;
    try {
      bleLine = _buildSetAllServerParametersBleCommand(
        model: model,
        stationId: stationId,
        ftpAddress: ftpAddress,
        ftpPort: ftpPort,
        ftpPath: ftpPath,
        ftpUsername: ftpUsername,
        ftpPassword: ftpPassword,
        cellNo: cellNo,
        txRedundancy: txRedundancy,
      );
    } on ArgumentError catch (e) {
      emit(
        state.copyWith(
          message: e.message?.toString() ?? e.toString(),
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere((c) => c.id == setCommandId);
    final wait = model.responseWaitTimeout;

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final responseLine = await _ble.sendDrifterAsciiCommand(bleLine, wait);
      final summary = _formatParameterizedServerBleSummary(responseLine);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearSetAllServerParametersPrompt: true,
          message: '${model.testName} updated successfully.',
          isSuccessMessage: true,
          lastSnapshot: SelfTestBleResponseSnapshot(
            testName: model.testName,
            responseLine: responseLine,
            hideResponseLine: true,
            helpText: summary,
            descriptionSuccess: true,
          ),
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Set all server parameters timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message:
              'Timed out waiting for a response ending with # (${model.testName}).',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Set all server parameters error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  static bool _isGeneralParametersPlaceholderPayload(List<String> fields) {
    if (fields.length == 1) {
      final s = fields.first.toLowerCase();
      return s.contains('list of general') ||
          s.contains('list of all') ||
          s.contains('ist of all');
    }
    return false;
  }

  String _buildSetAllGeneralSystemParametersBleCommand({
    required String stationId,
    required String stationName,
    required String txInterval,
    required String measurementInterval,
    required String apn,
    required String fastSmsCheck,
    required String adminCell1,
    required String adminCell2,
    required String measurementStartTime,
  }) {
    void rejectComma(String label, String value) {
      if (value.contains(',')) {
        throw ArgumentError('$label cannot contain a comma.');
      }
    }

    rejectComma('Station id', stationId);
    rejectComma('Station name', stationName);
    rejectComma('Tx interval', txInterval);
    rejectComma('Measurement interval', measurementInterval);
    rejectComma('APN', apn);
    rejectComma('Fast SMS check', fastSmsCheck);
    rejectComma('Admin cell 1', adminCell1);
    rejectComma('Admin cell 2', adminCell2);
    rejectComma('Measurement start time', measurementStartTime);

    final sid = _padBleGeneralParameterField(stationId, 8, 'Station id');
    final name = _padBleGeneralParameterField(stationName, 16, 'Station name');
    final tx = _normalizeTime(txInterval.trim());
    final mi = _normalizeTime(measurementInterval.trim());
    if (tx == null) {
      throw ArgumentError('Tx interval must be HH:MM:SS (24-hour).');
    }
    if (mi == null) {
      throw ArgumentError('Measurement interval must be HH:MM:SS (24-hour).');
    }
    final apnField = _padBleGeneralParameterField(apn, 31, 'APN');

    final sms = fastSmsCheck.trim();
    if (sms != '0' && sms != '1') {
      throw ArgumentError('Fast SMS check must be 0 or 1.');
    }

    final a1 = _normalizeSecondarySmsCell(adminCell1);
    final a2 = _normalizeSecondarySmsCell(adminCell2);
    if (a1 == null || a2 == null) {
      throw ArgumentError(
        'Admin cell numbers must be 10 digits or +91 followed by 10 digits.',
      );
    }

    final start = _normalizeTime(measurementStartTime.trim());
    if (start == null) {
      throw ArgumentError('Measurement start time must be HH:MM:SS (24-hour).');
    }

    return '?05,$sid,$name,$tx,$mi,$apnField,$sms,$a1,$a2,$start,#';
  }

  static String _padBleGeneralParameterField(
    String raw,
    int maxLen,
    String label,
  ) {
    final t = raw.trim();
    if (t.isEmpty) {
      throw ArgumentError('$label is required.');
    }
    if (t.length > maxLen) {
      return t.substring(0, maxLen);
    }
    return t.padRight(maxLen, ' ');
  }

  /// Success popup for `?59` / `?60` — full general-parameters read-back.
  static String _formatAdminSmsCellSetResponseSummary(String rawLine) {
    final fields = _parseGeneralSystemParametersFields(rawLine);
    if (fields != null &&
        fields.length >= 11 &&
        !_isGeneralParametersPlaceholderPayload(fields)) {
      return _formatGeneralSystemParametersBleSummary(rawLine);
    }
    return _summarizeSetAllGeneralParametersResponse(rawLine);
  }

  static String _summarizeSetAllGeneralParametersResponse(String rawLine) {
    final fields = _parseGeneralSystemParametersFields(rawLine);
    if (fields != null &&
        fields.length >= 11 &&
        !_isGeneralParametersPlaceholderPayload(fields)) {
      return _formatGeneralSystemParametersBleSummary(rawLine);
    }
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'Parameters were sent. No response text was received.';
    }
    return 'Parameters were sent.\n\nRaw response:\n$trimmed';
  }

  void _onNotifyBlePeripheralDisconnected(
    NotifyBlePeripheralDisconnected event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.loaded,
        clearRunningCommandIndex: true,
        clearLastSnapshot: true,
        clearStationIdPrompt: true,
        clearMeasurementTimePrompt: true,
        clearTransmitterFrequencyPrompt: true,
        clearSetAttenuationPrompt: true,
        clearRadioSondeTransmitterIdPrompt: true,
        clearTransmitterTestPrompt: true,
        clearCheckStatusPrompt: true,
        clearParameterizedCommandPrompt: true,
        clearSetAllGeneralParametersPrompt: true,
        clearSetAllServerParametersPrompt: true,
        clearRestoreDefaultParametersPrompt: true,
        clearRestoreServerParametersPrompt: true,
        clearSetSensorAllParametersPrompt: true,
        clearSetSensorsParametersPrompt: true,
        clearStationNamePrompt: true,
        clearTransmissionTimePrompt: true,
        clearTransmissionIntervalPrompt: true,
        clearMeasurementIntervalPrompt: true,
        clearSetApnPrompt: true,
        clearFastSmsCheckPrompt: true,
        clearAdminSmsCellPrompt: true,
        message: '',
        isSuccessMessage: false,
      ),
    );
  }

  /// Sends a single-field server command built from [_buildParameterizedServerBleCommand].
  Future<void> _onSubmitGeneralUserParameterizedCommand(
    SubmitGeneralUserParameterizedCommand event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    final commandId = event.commandId.trim();

    if (commandId == _setAllGeneralSystemParametersCommandId &&
        event.value == setAllGeneralParametersClearPromptMarker) {
      emit(state.copyWith(clearSetAllGeneralParametersPrompt: true));
      return;
    }
    if (event.value.startsWith(setAllGeneralParametersPayloadPrefix)) {
      final jsonPayload = event.value.substring(
        setAllGeneralParametersPayloadPrefix.length,
      );
      try {
        final raw = jsonDecode(jsonPayload);
        if (raw is! Map) {
          throw const FormatException('expected JSON object');
        }
        final map = Map<String, dynamic>.from(raw);
        String field(String k) => map[k]?.toString() ?? '';
        await _runSetAllGeneralParameters(
          emit,
          stationId: field('stationId'),
          stationName: field('stationName'),
          txInterval: field('txInterval'),
          measurementInterval: field('measurementInterval'),
          apn: field('apn'),
          fastSmsCheck: field('fastSmsCheck'),
          adminCell1: field('adminCell1'),
          adminCell2: field('adminCell2'),
          measurementStartTime: field('measurementStartTime'),
        );
      } on FormatException catch (e) {
        emit(
          state.copyWith(
            message: 'Invalid set-all-general payload: ${e.message}.',
            isSuccessMessage: false,
          ),
        );
      }
      return;
    }
    if (_setAllServerCommandIds.contains(commandId) &&
        event.value == setAllServerParametersClearPromptMarker) {
      emit(state.copyWith(clearSetAllServerParametersPrompt: true));
      return;
    }

    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    if (_setAllServerCommandIds.contains(commandId) &&
        event.value.startsWith(setAllServerParametersPayloadPrefix)) {
      final jsonPayload = event.value.substring(
        setAllServerParametersPayloadPrefix.length,
      );
      try {
        final raw = jsonDecode(jsonPayload);
        if (raw is! Map) {
          throw const FormatException('expected JSON object');
        }
        final map = Map<String, dynamic>.from(raw);
        String field(String k) => map[k]?.toString() ?? '';
        await _runSetAllServerParameters(
          emit,
          setCommandId: commandId,
          stationId: field('stationId'),
          ftpAddress: field('ftpAddress'),
          ftpPort: field('ftpPort'),
          ftpPath: field('ftpPath'),
          ftpUsername: field('ftpUsername'),
          ftpPassword: field('ftpPassword'),
          cellNo: field('cellNo'),
          txRedundancy: field('txRedundancy'),
        );
      } on FormatException catch (e) {
        emit(
          state.copyWith(
            message: 'Invalid set-all-server payload: ${e.message}.',
            isSuccessMessage: false,
          ),
        );
      }
      return;
    }

    final requestCommand = event.requestCommand.trim();
    final model = _staticCommandMatching(
      id: commandId,
      requestCommand: requestCommand,
    );
    final kind = model != null ? _parameterizedKindFor(model) : null;
    if (kind == null || model == null) {
      emit(
        state.copyWith(
          message: 'Unknown server command.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    late final String bleLine;
    try {
      bleLine = _buildParameterizedServerBleCommand(model, kind, event.value);
    } on ArgumentError catch (e) {
      emit(
        state.copyWith(
          message: e.message?.toString() ?? e.toString(),
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere((c) {
      if (c.id != commandId) {
        return false;
      }
      if (requestCommand.isEmpty) {
        return true;
      }
      return c.requestCommand.trim() == requestCommand;
    });
    final wait = model.responseWaitTimeout;
    final req = model.requestCommand.trim();

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final responseLine = await _ble.sendDrifterAsciiCommand(bleLine, wait);
      final isBatteryVoltage = commandId == _batteryVoltageCommandId;
      final isHttpServerUsername = commandId == _httpServerUsernameCommandId;
      final isDlCellNo = commandId == _setDlCellNoCommandId;
      final isPowerSwitching = commandId == _powerSwitchingCommandId;
      final isTestMode = commandId == _testModeCommandId;
      final isSetHttpPort = commandId == _setHttpPortCommandId;
      final isSetHttpPassword = commandId == _setHttpPasswordCommandId;
      final isGetSensorParameter81 = req.startsWith('?81');
      final isGetSensorParameter83 = req.startsWith('?83');
      final summary = isBatteryVoltage
          ? _formatBatteryVoltageBleSummary(responseLine)
          : isHttpServerUsername
          ? _formatHttpServerUsernameBleSummary(responseLine)
          : isDlCellNo
          ? _formatDlCellNoBleSummary(responseLine)
          : isPowerSwitching
          ? _formatPowerSwitchingBleSummary(responseLine)
          : isTestMode
          ? _formatTestModeBleSummary(responseLine)
          : isSetHttpPort
          ? _formatSetHttpPortBleSummary(responseLine)
          : isSetHttpPassword
          ? _formatSetHttpPasswordBleSummary(responseLine)
          : isGetSensorParameter81
          ? _formatGetSensorParameter81BleSummary(responseLine)
          : isGetSensorParameter83
          ? _formatGetSensorParameter83BleSummary(responseLine)
          : _formatParameterizedServerBleSummary(responseLine);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearParameterizedCommandPrompt: true,
          message: isBatteryVoltage
              ? 'Battery voltage read successfully.'
              : isHttpServerUsername
              ? 'HTTP server username updated successfully.'
              : isDlCellNo
              ? 'DL cell number updated successfully.'
              : isPowerSwitching
              ? 'Power switching completed successfully.'
              : isTestMode
              ? 'Test mode updated successfully.'
              : isSetHttpPort
              ? 'HTTP port updated successfully.'
              : isSetHttpPassword
              ? 'HTTP password updated successfully.'
              : isGetSensorParameter81 || isGetSensorParameter83
              ? 'Sensor parameters read successfully.'
              : '${model.testName} updated successfully.',
          isSuccessMessage: true,
          lastSnapshot: SelfTestBleResponseSnapshot(
            testName: model.testName,
            responseLine: responseLine,
            hideResponseLine: true,
            helpText: summary,
            descriptionSuccess: true,
          ),
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Parameterized server command timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message:
              'Timed out waiting for a response ending with # (${model.testName}).',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e(
        'Parameterized server command error',
        error: e,
        stackTrace: st,
      );
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  void _onClearGeneralUserParameterizedCommandPrompt(
    ClearGeneralUserParameterizedCommandPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearParameterizedCommandPrompt: true));
  }

  Future<void> _onSubmitGeneralUserRestoreDefaultParameters(
    SubmitGeneralUserRestoreDefaultParameters event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    final commandId = event.commandId.trim();
    if (commandId != _restoreDefaultParametersCommandId) {
      emit(
        state.copyWith(
          message: 'Unknown restore default command.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    final model = _staticCommandsById[commandId];
    if (model == null) {
      emit(
        state.copyWith(
          message: 'Restore default parameters command is not configured.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere((c) => c.id == commandId);
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final responseLine = await _ble.sendDrifterAsciiCommand(
        model.requestCommand,
        model.responseWaitTimeout,
      );
      final summary = _formatRestoreDefaultParametersBleSummary(responseLine);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearRestoreDefaultParametersPrompt: true,
          message: '${model.testName} completed successfully.',
          isSuccessMessage: true,
          lastSnapshot: SelfTestBleResponseSnapshot(
            testName: model.testName,
            responseLine: responseLine,
            hideResponseLine: true,
            helpText: summary,
            descriptionSuccess: true,
          ),
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Restore default parameters timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message:
              'Timed out waiting for a response ending with # (${model.testName}).',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Restore default parameters error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  void _onClearGeneralUserRestoreDefaultParametersPrompt(
    ClearGeneralUserRestoreDefaultParametersPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearRestoreDefaultParametersPrompt: true));
  }

  Future<void> _onSubmitGeneralUserRestoreServerParameters(
    SubmitGeneralUserRestoreServerParameters event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    final commandId = event.commandId.trim();
    final model = _staticCommandsById[commandId];
    if (model == null || !_restoreAllServerCommandIds.contains(commandId)) {
      emit(
        state.copyWith(
          message: 'Unknown restore server command.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere((c) => c.id == commandId);
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final responseLine = await _ble.sendDrifterAsciiCommand(
        model.requestCommand,
        model.responseWaitTimeout,
      );
      final summary = _formatParameterizedServerBleSummary(responseLine);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearRestoreServerParametersPrompt: true,
          message: '${model.testName} completed successfully.',
          isSuccessMessage: true,
          lastSnapshot: SelfTestBleResponseSnapshot(
            testName: model.testName,
            responseLine: responseLine,
            hideResponseLine: true,
            helpText: summary,
            descriptionSuccess: true,
          ),
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Restore server parameters timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message:
              'Timed out waiting for a response ending with # (${model.testName}).',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Restore server parameters error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  void _onClearGeneralUserRestoreServerParametersPrompt(
    ClearGeneralUserRestoreServerParametersPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearRestoreServerParametersPrompt: true));
  }

  Future<void> _runSetSensorBleCommand({
    required Emitter<GeneralUserSelfTestDebugState> emit,
    required String commandId,
    required String bleLine,
    required String successMessage,
    required String Function(String responseLine) formatSummary,
    required bool clearSetSensorAllPrompt,
    required bool clearSetSensorsPrompt,
  }) async {
    final model = _staticCommandsById[commandId];
    if (model == null) {
      emit(
        state.copyWith(
          message: 'Sensor command is not configured.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (_ble.connectedRemoteId == null) {
      emit(
        state.copyWith(
          message:
              'No buoy connected. Pair from Setup and connect over Bluetooth first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final runningIndex = state.commands.indexWhere((c) => c.id == commandId);
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: runningIndex >= 0 ? runningIndex : null,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      final responseLine = await _ble.sendDrifterAsciiCommand(
        bleLine,
        model.responseWaitTimeout,
      );
      final summary = formatSummary(responseLine);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearSetSensorAllParametersPrompt: clearSetSensorAllPrompt,
          clearSetSensorsParametersPrompt: clearSetSensorsPrompt,
          message: successMessage,
          isSuccessMessage: true,
          lastSnapshot: SelfTestBleResponseSnapshot(
            testName: model.testName,
            responseLine: responseLine,
            hideResponseLine: true,
            helpText: summary,
            descriptionSuccess: true,
          ),
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Set sensor command timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message:
              'Timed out waiting for a response ending with # (${model.testName}).',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Set sensor command error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onSubmitGeneralUserSetSensorAllParameters(
    SubmitGeneralUserSetSensorAllParameters event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    late final String bleLine;
    try {
      bleLine = _buildSetSensorAllParameterBleCommand(event.draft);
    } on ArgumentError catch (e) {
      emit(
        state.copyWith(
          message: e.message?.toString() ?? e.toString(),
          isSuccessMessage: false,
        ),
      );
      return;
    }
    await _runSetSensorBleCommand(
      emit: emit,
      commandId: _setSensorAllParameterCommandId,
      bleLine: bleLine,
      successMessage: 'SET Sensor ALL parameter completed successfully.',
      formatSummary: _formatSetSensorAllParameterBleSummary,
      clearSetSensorAllPrompt: true,
      clearSetSensorsPrompt: false,
    );
  }

  void _onClearGeneralUserSetSensorAllParametersPrompt(
    ClearGeneralUserSetSensorAllParametersPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearSetSensorAllParametersPrompt: true));
  }

  Future<void> _onSubmitGeneralUserSetSensorsParameters(
    SubmitGeneralUserSetSensorsParameters event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    late final String bleLine;
    try {
      bleLine = _buildSetSensorsParametersBleCommand(event.draft);
    } on ArgumentError catch (e) {
      emit(
        state.copyWith(
          message: e.message?.toString() ?? e.toString(),
          isSuccessMessage: false,
        ),
      );
      return;
    }
    await _runSetSensorBleCommand(
      emit: emit,
      commandId: _setSensorsParametersCommandId,
      bleLine: bleLine,
      successMessage: 'SET sensors parameters completed successfully.',
      formatSummary: _formatSetSensorsParametersBleSummary,
      clearSetSensorAllPrompt: false,
      clearSetSensorsPrompt: true,
    );
  }

  void _onClearGeneralUserSetSensorsParametersPrompt(
    ClearGeneralUserSetSensorsParametersPrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearSetSensorsParametersPrompt: true));
  }

  Future<void> _onRunGetAllServerParameters(
    DrifterBuoyCommandModel cmd,
    int index,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningCommandIndex: index,
        message: '',
        isSuccessMessage: false,
        clearLastSnapshot: true,
      ),
    );
    try {
      final responseLine = await _ble.sendDrifterAsciiCommand(
        cmd.requestCommand,
        cmd.responseWaitTimeout,
      );
      final summary = _formatParameterizedServerBleSummary(responseLine);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: '${cmd.testName} read successfully.',
          isSuccessMessage: true,
          lastSnapshot: SelfTestBleResponseSnapshot(
            testName: cmd.testName,
            responseLine: responseLine,
            hideResponseLine: true,
            helpText: summary,
            descriptionSuccess: true,
          ),
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.e('Get all server parameters timeout', error: e);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message:
              'Timed out waiting for a response ending with # (${cmd.testName}).',
          isSuccessMessage: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Get all server parameters error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          message: e.toString(),
          isSuccessMessage: false,
        ),
      );
    }
  }

  /// Parses `$84,station id,Battery Voltage,CNT: Counts,#`.
  static final RegExp _transmissionStartTimeHmsPattern = RegExp(
    r'^(\d{2}):(\d{2}):(\d{2})$',
  );

  /// GPRS transmission start time read-back.
  ///
  /// Device may send `$63,HH:MM:SS#` or catalog form `$63,station id,HH:MM:SS#`.
  static String _formatTransmissionStartTimeGprsBleSummary(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'No response text was received.';
    }
    final noHash = trimmed.endsWith('#')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.length < 2 || !parts[0].toUpperCase().contains(r'$63')) {
      return 'The device responded, but the payload could not be parsed as '
          'transmission start time.\n\n'
          'Raw response:\n$trimmed';
    }

    String? stationId;
    late final String time;
    if (parts.length == 2 &&
        _transmissionStartTimeHmsPattern.hasMatch(parts[1])) {
      time = parts[1];
    } else if (parts.length >= 3 &&
        _transmissionStartTimeHmsPattern.hasMatch(parts[2])) {
      stationId = parts[1];
      time = parts[2];
    } else if (_transmissionStartTimeHmsPattern.hasMatch(parts.last)) {
      time = parts.last;
      if (parts.length > 2) {
        stationId = parts[1];
      }
    } else {
      return 'The device responded, but the payload could not be parsed as '
          'transmission start time.\n\n'
          'Raw response:\n$trimmed';
    }

    final lines = <String>['Transmission start time (GPRS):', '', time];
    if (stationId != null && stationId.isNotEmpty) {
      lines.addAll(['', 'Station ID: $stationId']);
    }
    return lines.join('\n');
  }

  /// `$95,factory id,gps,DD/MM/YY HH:MM,rtc status#` — manual RTC update read-back.
  static String _formatManualRtcUpdateBleSummary(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'No response text was received.';
    }
    final noHash = trimmed.endsWith('#')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.length < 5 || !parts[0].toUpperCase().contains(r'$95')) {
      return 'The device responded, but the payload could not be parsed as '
          'manual RTC update status.\n\n'
          'Raw response:\n$trimmed';
    }
    String dash(String s) => s.isEmpty ? '—' : s;
    final factoryId = parts[1];
    final gpsStatus = parts[2];
    final dateTime = parts[3];
    final rtcStatus = parts[4];
    final dateTimeLine = dateTime.contains('99/99/99')
        ? '$dateTime (RTC not updated — placeholder)'
        : dateTime;
    final rtcStatusLine = switch (rtcStatus) {
      '0' => '0 — Success',
      _ => dash(rtcStatus),
    };
    return [
      'Manual RTC update:',
      '',
      dateTimeLine,
      '',
      'RTC update status: $rtcStatusLine',
      'GPS update status: ${dash(gpsStatus)}',
      'Factory station ID: ${dash(factoryId)}',
      'Response code: ${parts[0]}',
    ].join('\n');
  }

  /// `$97,station id,N,password#` — HTTP password read-back.
  static String _formatSetHttpPasswordBleSummary(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'The device acknowledged the update. No response text was received.';
    }
    final noHash = trimmed.endsWith('#')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.length < 4 || !parts[0].toUpperCase().contains(r'$97')) {
      return 'The device responded, but the payload could not be parsed as '
          'HTTP password.\n\n'
          'Raw response:\n$trimmed';
    }
    String dash(String s) => s.isEmpty ? '—' : s;
    final station = parts[1];
    final serverNo = parts[2];
    final password = parts.sublist(3).join(',').trim();
    return [
      'Read-back from device:',
      '',
      password,
      '',
      'HTTP server number (N): ${dash(serverNo)} (1–4)',
      'Station ID: ${dash(station)}',
      'Response code: ${parts[0]}',
    ].join('\n');
  }

  /// `$98,station,port1,port2,port3,factoryPort#` — HTTP ports read-back.
  static String _formatSetHttpPortBleSummary(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'The device acknowledged the update. No response text was received.';
    }
    final noHash = trimmed.endsWith('#')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.length < 6 || !parts[0].toUpperCase().contains(r'$98')) {
      return 'The device responded, but the payload could not be parsed as '
          'HTTP port settings.\n\n'
          'Raw response:\n$trimmed';
    }
    String dash(String s) => s.isEmpty ? '—' : s;
    final station = parts[1];
    final user1 = parts[2];
    final user2 = parts[3];
    final user3 = parts[4];
    final factory = parts[5];
    return [
      'HTTP ports from device:',
      '',
      'User 1 HTTP port: ${dash(user1)}',
      'User 2 HTTP port: ${dash(user2)}',
      'User 3 HTTP port: ${dash(user3)}',
      'Factory HTTP port: ${dash(factory)}',
      '',
      'Station ID: ${dash(station)}',
      'Response code: ${parts[0]}',
    ].join('\n');
  }

  static String _formatMemoryTestOkNotOk(String raw) {
    final t = raw.trim();
    if (t.isEmpty) {
      return '—';
    }
    final v = int.tryParse(t);
    return switch (v) {
      0 => '$t — OK',
      1 => '$t — Not OK',
      _ => t,
    };
  }

  /// `$96,station id,status#` — erase memory result (`1` = success).
  static String _formatEraseMemoryBleSummary(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'No response text was received.';
    }
    final noHash = trimmed.endsWith('#')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.length < 3 || !parts[0].toUpperCase().contains(r'$96')) {
      return 'The device responded, but the payload could not be parsed as '
          'erase memory status.\n\n'
          'Raw response:\n$trimmed';
    }
    String dash(String s) => s.isEmpty ? '—' : s;
    final station = parts[1];
    final status = parts[2];
    final statusLine = switch (status) {
      '1' => '1 — Success',
      '0' => '0 — Not success',
      _ => dash(status),
    };
    return [
      'Erase memory:',
      '',
      statusLine,
      '',
      'Station ID: ${dash(station)}',
      'Response code: ${parts[0]}',
    ].join('\n');
  }

  /// `$91,station id,memory status,...#` — memory test read-back.
  static String _formatMemoryTestBleSummary(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'No response text was received.';
    }
    final noHash = trimmed.endsWith('#')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.length < 4 || !parts[0].toUpperCase().contains(r'$91')) {
      return 'The device responded, but the payload could not be parsed as '
          'memory test status.\n\n'
          'Raw response:\n$trimmed';
    }
    String dash(String s) => s.isEmpty ? '—' : s;
    final station = parts[1];
    final lines = <String>[
      'Memory test:',
      '',
      'Memory status: ${_formatMemoryTestOkNotOk(parts[2])}',
    ];
    if (parts.length > 3) {
      lines.add('Memory 2 status: ${_formatMemoryTestOkNotOk(parts[3])}');
    }
    for (var i = 4; i < parts.length; i++) {
      lines.add('Status ${i - 1}: ${_formatMemoryTestOkNotOk(parts[i])}');
    }
    lines.addAll([
      '',
      'Station ID: ${dash(station)}',
      'Response code: ${parts[0]}',
    ]);
    return lines.join('\n');
  }

  /// `$79,station id,status#` — sleep current test result (`1` = success).
  static String _formatSleepCurrentTestBleSummary(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'No response text was received.';
    }
    final noHash = trimmed.endsWith('#')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.length < 3 || !parts[0].toUpperCase().contains(r'$79')) {
      return 'The device responded, but the payload could not be parsed as '
          'sleep current test status.\n\n'
          'Raw response:\n$trimmed';
    }
    String dash(String s) => s.isEmpty ? '—' : s;
    final station = parts[1];
    final status = parts[2];
    final statusLine = switch (status) {
      '1' => '1 — Success',
      '0' => '0 — Not success',
      _ => dash(status),
    };
    return [
      'Sleep current test:',
      '',
      statusLine,
      '',
      'Station ID: ${dash(station)}',
      'Response code: ${parts[0]}',
    ].join('\n');
  }

  /// `$71,station id,N#` — test mode read-back.
  static String _formatTestModeBleSummary(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'No response text was received.';
    }
    final noHash = trimmed.endsWith('#')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.length < 3 || !parts[0].toUpperCase().contains(r'$71')) {
      return 'The device responded, but the payload could not be parsed as '
          'test mode status.\n\n'
          'Raw response:\n$trimmed';
    }
    String dash(String s) => s.isEmpty ? '—' : s;
    final station = parts[1];
    final mode = parts[2];
    return [
      'Test mode:',
      '',
      mode,
      '',
      'Station ID: ${dash(station)}',
      'Response code: ${parts[0]}',
    ].join('\n');
  }

  /// `$76,station id,status#` — power switching result (`1` = success).
  static String _formatPowerSwitchingBleSummary(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'No response text was received.';
    }
    final noHash = trimmed.endsWith('#')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.length < 3 || !parts[0].toUpperCase().contains(r'$76')) {
      return 'The device responded, but the payload could not be parsed as '
          'power switching status.\n\n'
          'Raw response:\n$trimmed';
    }
    String dash(String s) => s.isEmpty ? '—' : s;
    final station = parts[1];
    final status = parts[2];
    final statusLine = switch (status) {
      '1' => '1 — Success',
      '0' => '0 — Not success',
      _ => dash(status),
    };
    return [
      'Power switching:',
      '',
      statusLine,
      '',
      'Station ID: ${dash(station)}',
      'Response code: ${parts[0]}',
    ].join('\n');
  }

  /// `$68,station id,cell#` — DL cell / MSISDN read-back.
  static String _formatDlCellNoBleSummary(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'The device acknowledged the update. No response text was received.';
    }
    final noHash = trimmed.endsWith('#')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.length < 3 || !parts[0].toUpperCase().contains(r'$68')) {
      return 'The device responded, but the payload could not be parsed as '
          'DL cell number.\n\n'
          'Raw response:\n$trimmed';
    }
    String dash(String s) => s.isEmpty ? '—' : s;
    final station = parts[1];
    final cellNumber = parts.sublist(2).join(',').trim();
    return [
      'Read-back from device:',
      '',
      cellNumber,
      '',
      'Station ID: ${dash(station)}',
      'Response code: ${parts[0]}',
    ].join('\n');
  }

  /// `$62,station id,N,username#` — HTTP server username read-back.
  static String _formatHttpServerUsernameBleSummary(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'The device acknowledged the update. No response text was received.';
    }
    final noHash = trimmed.endsWith('#')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.length < 4 || !parts[0].toUpperCase().contains(r'$62')) {
      return 'The device responded, but the payload could not be parsed as '
          'HTTP server username.\n\n'
          'Raw response:\n$trimmed';
    }
    String dash(String s) => s.isEmpty ? '—' : s;
    final station = parts[1];
    final serverNo = parts[2];
    final username = parts.sublist(3).join(',').trim();
    return [
      'Read-back from device:',
      '',
      'HTTP server number (N): ${dash(serverNo)} (1–4)',
      'Username: ${dash(username)}',
      'Station ID: ${dash(station)}',
      'Response code: ${parts[0]}',
    ].join('\n');
  }

  static String _formatBatteryVoltageBleSummary(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'No response text was received.';
    }
    final noHash = trimmed.endsWith('#')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.length < 3 || !parts[0].startsWith(r'$84')) {
      return 'The device responded, but the payload could not be parsed.\n\n'
          'Raw response:\n$trimmed';
    }
    String dash(String s) => s.isEmpty ? '—' : s;
    final station = parts[1];
    final voltage = parts[2];
    final counts = parts.length > 3 ? parts.sublist(3).join(', ') : '—';
    return [
      'Battery voltage: ${dash(voltage)}',
      '',
      'Station ID: ${dash(station)}',
      'CNT (counts): ${dash(counts)}',
      'Response code: ${parts[0]}',
    ].join('\n');
  }

  /// Parses `$15`–`$19` / `$23`–`$29` style read-back lines:
  /// `$NN,station,addr,port,path,user,pass,cell,R#`
  static String _formatParameterizedServerBleSummary(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'The device acknowledged the update. No response text was received.';
    }
    final noHash = trimmed.endsWith('#')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.length < 9) {
      return 'The device responded, but the payload could not be parsed as '
          'server settings.\n\n'
          'Raw response:\n$trimmed';
    }
    final opcode = parts[0];
    final station = parts[1];
    final addr = parts[2];
    final port = parts[3];
    final path = parts[4];
    final user = parts[5];
    final pass = parts[6];
    final cell = parts[7];
    final r = parts[8];
    if (!opcode.startsWith(r'$')) {
      return 'The device responded, but the payload could not be parsed as '
          'server settings.\n\n'
          'Raw response:\n$trimmed';
    }
    String dash(String s) => s.isEmpty ? '—' : s;
    final rText = switch (r) {
      '0' => '0 — GSM and GPRS',
      '1' => '1 — GSM if GPRS fail',
      _ => dash(r),
    };
    return [
      'Read-back from device:',
      '',
      'Response code: $opcode',
      'Station ID: ${dash(station)}',
      'FTP server address: ${dash(addr)}',
      'FTP port: ${dash(port)}',
      'FTP path: ${dash(path)}',
      'FTP username: ${dash(user)}',
      'FTP password: ${dash(pass)}',
      'Cell number: ${dash(cell)}',
      'TX redundancy: $rText',
    ].join('\n');
  }

  static List<String>? _parseServerSettingsFields(String rawLine) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final noHash = trimmed.endsWith('#')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parts = noHash.split(',').map((e) => e.trim()).toList();
    if (parts.length < 9 || !parts.first.startsWith(r'$')) {
      return null;
    }
    return parts.sublist(1, 9);
  }

  /// HTTP server username (`?62`): max 64 chars; shorter values padded with spaces.
  static String _padHttpServerUsernameTo64(String raw) {
    final t = raw.trim();
    if (t.isEmpty) {
      throw ArgumentError('Enter a username (max 64 characters).');
    }
    if (t.contains(',')) {
      throw ArgumentError('Username cannot contain a comma.');
    }
    if (!RegExp(r'^[\x20-\x7E]+$').hasMatch(t)) {
      throw ArgumentError('Username must use printable ASCII only.');
    }
    if (t.length > 64) {
      return t.substring(0, 64);
    }
    return t.padRight(64, ' ');
  }

  /// FTP-style fields: max 20 chars; shorter values padded with trailing spaces.
  static String _padFtpFieldTo20(String raw) {
    final t = raw.trim();
    if (t.length > 20) {
      return t.substring(0, 20);
    }
    return t.padRight(20, ' ');
  }

  static String _normalizeSetAllServerStationId(String raw) {
    final t = raw.trim();
    if (t.isEmpty) {
      throw ArgumentError('Station id is required.');
    }
    if (t.contains(',')) {
      throw ArgumentError('Station id cannot contain a comma.');
    }
    if (!RegExp(r'^[\x20-\x7E]+$').hasMatch(t)) {
      throw ArgumentError('Station id must use printable ASCII only.');
    }
    if (t.length > 8) {
      return t.substring(0, 8);
    }
    return t.padRight(8, ' ');
  }

  static String _normalizeSetAllServerTxRedundancy(String raw) {
    final t = raw.trim();
    if (t != '0' && t != '1') {
      throw ArgumentError('TX redundancy must be 0 (disable) or 1 (enable).');
    }
    return t;
  }

  static String _buildSetAllServerParametersBleCommand({
    required DrifterBuoyCommandModel model,
    required String stationId,
    required String ftpAddress,
    required String ftpPort,
    required String ftpPath,
    required String ftpUsername,
    required String ftpPassword,
    required String cellNo,
    required String txRedundancy,
  }) {
    final m = RegExp(r'^\?(\d+),').firstMatch(model.requestCommand.trim());
    if (m == null) {
      throw ArgumentError('Invalid request template for ${model.testName}.');
    }
    final opcode = m.group(1)!;
    final sid = _normalizeSetAllServerStationId(stationId);
    final addr = _padFtpFieldTo20(ftpAddress);
    final port = _normalizePortFiveDigits(ftpPort);
    if (port == null) {
      throw ArgumentError(
        'FTP port must be a number from 0 to 65535 (sent as 5 digits).',
      );
    }
    final path = _padFtpFieldTo20(ftpPath);
    final user = _padFtpFieldTo20(ftpUsername);
    final pass = _padFtpFieldTo20(ftpPassword);
    final cell = _normalizeSecondarySmsCell(cellNo);
    if (cell == null) {
      throw ArgumentError(
        'Cell number must be 10 digits or +91 followed by 10 digits.',
      );
    }
    final redundancy = _normalizeSetAllServerTxRedundancy(txRedundancy);
    return '?$opcode,$sid,$addr,$port,$path,$user,$pass,$cell,$redundancy,#';
  }

  static String? _normalizePortFiveDigits(String raw) {
    final digits = raw.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return null;
    }
    final v = int.tryParse(digits);
    if (v == null || v < 0 || v > 65535) {
      return null;
    }
    return v.toString().padLeft(5, '0');
  }

  static String? _normalizeSecondarySmsCell(String raw) {
    var s = raw.trim().replaceAll(RegExp(r'\s'), '');
    if (s.startsWith('+91')) {
      s = s.substring(3);
    }
    if (s.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(s)) {
      return null;
    }
    return '+91$s';
  }

  /// `?68,N,number,#` — N 1–2: `+91` + 10 digits or 13 digits; N 3–4: 13 digits only.
  static String? _normalizeDlCellNumber(int slot, String raw) {
    if (slot < 1 || slot > 4) {
      return null;
    }
    var s = raw.trim().replaceAll(RegExp(r'\s'), '');
    if (s.isEmpty) {
      return null;
    }
    if (slot == 1 || slot == 2) {
      if (s.startsWith('+91')) {
        final digits = s.substring(3);
        if (digits.length == 10 && RegExp(r'^[0-9]{10}$').hasMatch(digits)) {
          return '+91$digits';
        }
        return null;
      }
      if (s.length == 13 && RegExp(r'^[0-9]{13}$').hasMatch(s)) {
        return s;
      }
      return null;
    }
    if (s.startsWith('+91')) {
      return null;
    }
    if (s.length == 13 && RegExp(r'^[0-9]{13}$').hasMatch(s)) {
      return s;
    }
    return null;
  }

  static void _rejectCommaInSensorField(String label, String value) {
    if (value.contains(',')) {
      throw ArgumentError('$label cannot contain a comma.');
    }
  }

  static String _requireTrimmedSensorField(String label, String raw) {
    final t = raw.trim();
    if (t.isEmpty) {
      throw ArgumentError('$label is required.');
    }
    _rejectCommaInSensorField(label, t);
    return t;
  }

  static String _padFixedSensorTextField(String raw, int maxLen, String label) {
    final t = _requireTrimmedSensorField(label, raw);
    if (t.length > maxLen) {
      return t.substring(0, maxLen);
    }
    return t.padRight(maxLen, ' ');
  }

  String _buildSetSensorAllParameterBleCommand(
    SelfTestSetSensorAllParametersDraft d,
  ) {
    final sensorNo = _normalizeSensorNumber83(d.sensorNo);
    if (sensorNo == null) {
      throw ArgumentError('Sensor no must be 00–99.');
    }
    final channelNo = _normalizeSensorNumber83(d.channelNo);
    if (channelNo == null) {
      throw ArgumentError('Channel no must be 00–99.');
    }
    final start = _normalizeTime(d.startTime.trim());
    final interval = _normalizeTime(d.interval.trim());
    if (start == null) {
      throw ArgumentError('Start time must be HH:MM:SS (24-hour).');
    }
    if (interval == null) {
      throw ArgumentError('Interval must be HH:MM:SS (24-hour).');
    }
    final fields = <String>[
      sensorNo,
      channelNo,
      _requireTrimmedSensorField('F.G', d.fg),
      _requireTrimmedSensorField('Factory off', d.factoryOff),
      _requireTrimmedSensorField('senG', d.senG),
      _requireTrimmedSensorField('S.off', d.soff),
      _requireTrimmedSensorField('Resolution', d.resolution),
      _requireTrimmedSensorField('Sen Min', d.senMin),
      _requireTrimmedSensorField('Sens Max', d.sensMax),
      _requireTrimmedSensorField('Averag Scheme', d.averagScheme),
      _requireTrimmedSensorField('Vactor', d.vactor),
      start,
      interval,
      _requireTrimmedSensorField('Total sample', d.totalSample),
      _requireTrimmedSensorField('Mode', d.mode),
      _requireTrimmedSensorField('Tx.G', d.txG),
      _requireTrimmedSensorField('Tx.O', d.txO),
    ];
    return '?80,${fields.join(',')},#';
  }

  String _buildSetSensorsParametersBleCommand(
    SelfTestSetSensorsParametersDraft d,
  ) {
    final sensorNo = _normalizeSensorNumber83(d.sensorNo);
    if (sensorNo == null) {
      throw ArgumentError('Sensor no must be 00–99.');
    }
    final unit = _normalizeSensorNumber83(d.unit);
    if (unit == null) {
      throw ArgumentError('Unit must be 00–99.');
    }
    final id = _normalizeSensorNumber83(d.id);
    if (id == null) {
      throw ArgumentError('id must be 00–99.');
    }
    final model = _normalizeSensorNumber83(d.model);
    if (model == null) {
      throw ArgumentError('model must be 00–99.');
    }
    final datum = _requireTrimmedSensorField('datum', d.datum);
    final datumField = datum.length > 4
        ? datum.substring(0, 4)
        : datum.padLeft(4, '0');
    final fields = <String>[
      sensorNo,
      unit,
      _requireTrimmedSensorField('SenSelStatus', d.senSelStatus),
      _requireTrimmedSensorField('BaudRate', d.baudRate),
      _requireTrimmedSensorField('ReqLen', d.reqLen),
      _requireTrimmedSensorField('Start Char', d.startChar),
      _requireTrimmedSensorField('Fp', d.fp),
      _requireTrimmedSensorField('Lp', d.lp),
      _requireTrimmedSensorField('Resp Len', d.respLen),
      _requireTrimmedSensorField('RelayNo', d.relayNo),
      _requireTrimmedSensorField('PeriodicSmpl', d.periodicSmpl),
      _requireTrimmedSensorField('DerievedPara', d.derievedPara),
      _padFixedSensorTextField(d.requestString, 17, 'RequestString'),
      _padFixedSensorTextField(d.sensorName, 16, 'Sensor name'),
      id,
      model,
      _requireTrimmedSensorField('rstcnt', d.rstcnt),
      datumField,
      _requireTrimmedSensorField('dec_len', d.decLen),
      _requireTrimmedSensorField('frac_len', d.fracLen),
      _requireTrimmedSensorField('max_threshold', d.maxThreshold),
      _requireTrimmedSensorField('min_threshold', d.minThreshold),
    ];
    return '?82,${fields.join(',')},#';
  }

  static String _formatSetSensorAllParameterBleSummary(String rawLine) {
    return _formatSensorAllStyleBleSummary(
      rawLine,
      opcode: '80',
      heading: 'Parameters set on device:',
    );
  }

  static String _formatSetSensorsParametersBleSummary(String rawLine) {
    return _formatSensorConfigStyleBleSummary(
      rawLine,
      opcode: '82',
      heading: 'Parameters set on device:',
    );
  }

  /// `?84,xx,#` — xx is 00–11 (two digits).
  static String? _normalizeBatteryVoltageIndex(String raw) {
    final t = raw.trim();
    if (t.isEmpty) {
      return null;
    }
    final v = int.tryParse(t);
    if (v == null || v < 0 || v > 11) {
      return null;
    }
    return v.toString().padLeft(2, '0');
  }

  static String? _normalizeSensorNumber83(String raw) {
    final t = raw.trim();
    if (t.isEmpty) {
      return null;
    }
    final v = int.tryParse(t);
    if (v == null || v < 0 || v > 99) {
      return null;
    }
    return v.toString().padLeft(2, '0');
  }

  static const int _getSensorParameter81PayloadFieldCount = 16;

  static const List<String> _getSensorParameter81FieldLabels = [
    'Sensor no',
    'F.G',
    'Factory off',
    'senG',
    'S.off',
    'Resolution',
    'Sen Min',
    'Sens Max',
    'Averag Scheme',
    'Vactor',
    'Start time',
    'Interval',
    'Total sample',
    'Mode',
    'Tx.G',
    'Tx.O',
  ];

  /// Parsed `$80` / `$81` body: optional leading station id + 16 sensor fields.
  static ({List<String> fields, int valueStartIndex})?
  _parseSensorAllStyleBlePayload(String rawLine, {required String opcode}) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final hash = trimmed.indexOf('#');
    final core = (hash >= 0 ? trimmed.substring(0, hash) : trimmed).trim();
    final header = r'$' + opcode;
    if (!core.toUpperCase().startsWith(header)) {
      return null;
    }
    final prefix = '$header,';
    final body = core.startsWith(prefix)
        ? core.substring(prefix.length)
        : core.substring(header.length).replaceFirst(RegExp(r'^,?'), '');
    final parts = body.split(',').map((e) => e.trim()).toList();
    if (parts.isEmpty) {
      return null;
    }
    if (parts.length == 1 &&
        parts.first.toLowerCase().contains('list of all sensor')) {
      return (fields: parts, valueStartIndex: 0);
    }
    if (parts.length == _getSensorParameter81PayloadFieldCount) {
      return (fields: parts, valueStartIndex: 0);
    }
    if (parts.length == _getSensorParameter81PayloadFieldCount + 1) {
      return (fields: parts, valueStartIndex: 1);
    }
    if (parts.length > _getSensorParameter81PayloadFieldCount + 1) {
      return (
        fields: parts,
        valueStartIndex: parts.length - _getSensorParameter81PayloadFieldCount,
      );
    }
    return null;
  }

  static String _displaySensorParameterFieldValue(String raw) {
    if (raw.trim().isEmpty) {
      return '—';
    }
    return raw.trim();
  }

  static String _formatSensorAllStyleBleSummary(
    String rawLine, {
    required String opcode,
    required String heading,
  }) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'No response text was received.';
    }
    final parsed = _parseSensorAllStyleBlePayload(rawLine, opcode: opcode);
    if (parsed == null) {
      return 'The device responded, but sensor parameters could not be parsed.\n\n'
          'Raw response:\n$trimmed';
    }
    final fields = parsed.fields;
    if (fields.length == 1 &&
        fields.first.toLowerCase().contains('list of all sensor')) {
      return 'The device did not return sensor parameter values.\n\n'
          'Raw response:\n$trimmed';
    }
    final start = parsed.valueStartIndex;
    String valueAt(int labelIndex) {
      final idx = start + labelIndex;
      if (idx >= fields.length) {
        return '—';
      }
      return _displaySensorParameterFieldValue(fields[idx]);
    }

    final lines = <String>[heading, ''];
    if (start > 0) {
      lines.add('Station ID: ${_displaySensorParameterFieldValue(fields[0])}');
    }
    for (var i = 0; i < _getSensorParameter81FieldLabels.length; i++) {
      lines.add('${_getSensorParameter81FieldLabels[i]}: ${valueAt(i)}');
    }
    return lines.join('\n');
  }

  static String _formatGetSensorParameter81BleSummary(String rawLine) {
    return _formatSensorAllStyleBleSummary(
      rawLine,
      opcode: '81',
      heading: 'Sensor parameters read back:',
    );
  }

  static const List<String> _getSensorParameter83FieldLabels = [
    'Station ID',
    'Sensor no',
    'Unit',
    'SenSelStatus',
    'BaudRate',
    'ReqLen',
    'Start Char',
    'Fp',
    'Lp',
    'Resp Len',
    'RelayNo',
    'PeriodicSmpl',
    'DerievedPara',
    'RequestString',
    'Sensor name',
    'id',
    'model',
    'rstcnt',
    'datum',
    'dec_len',
    'frac_len',
    'max_threshold',
    'min_threshold',
  ];

  static const int _getSensorParameter83FieldCount = 23;

  static List<String>? _parseSensorConfigStyleBlePayload(
    String rawLine, {
    required String opcode,
  }) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final hash = trimmed.indexOf('#');
    final core = (hash >= 0 ? trimmed.substring(0, hash) : trimmed).trim();
    final header = r'$' + opcode;
    if (!core.toUpperCase().startsWith(header)) {
      return null;
    }
    final prefix = '$header,';
    final body = core.startsWith(prefix)
        ? core.substring(prefix.length)
        : core.substring(header.length).replaceFirst(RegExp(r'^,?'), '');
    final parts = body.split(',').map((e) => e.trim()).toList();
    if (parts.length < _getSensorParameter83FieldCount) {
      return null;
    }
    return parts;
  }

  static String _formatSensorConfigStyleBleSummary(
    String rawLine, {
    required String opcode,
    required String heading,
  }) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      return 'No response text was received.';
    }
    final fields = _parseSensorConfigStyleBlePayload(rawLine, opcode: opcode);
    if (fields == null) {
      return 'The device responded, but sensor parameters could not be parsed.\n\n'
          'Raw response:\n$trimmed';
    }
    final lines = <String>[heading, ''];
    for (var i = 0; i < _getSensorParameter83FieldLabels.length; i++) {
      final v = i < fields.length ? fields[i] : '';
      lines.add(
        '${_getSensorParameter83FieldLabels[i]}: ${_displaySensorParameterFieldValue(v)}',
      );
    }
    return lines.join('\n');
  }

  static String _formatGetSensorParameter83BleSummary(String rawLine) {
    return _formatSensorConfigStyleBleSummary(
      rawLine,
      opcode: '83',
      heading: 'Sensor parameters read back:',
    );
  }

  /// Printable ASCII without comma; appends one trailing space when shorter than
  /// [appendTrailingSpaceWhenLenLt] (catalog rule for RTC / HTTP website fields).
  static String _asciiPrintableNoCommaWithTrailingSpaceRule(
    String raw, {
    required int maxLen,
    required int appendTrailingSpaceWhenLenLt,
  }) {
    final t = raw.trim();
    if (t.isEmpty) {
      throw ArgumentError('Enter a value.');
    }
    if (t.contains(',')) {
      throw ArgumentError('Value cannot contain a comma.');
    }
    if (!RegExp(r'^[\x20-\x7E]+$').hasMatch(t)) {
      throw ArgumentError('Use printable ASCII only.');
    }
    var out = t.length > maxLen ? t.substring(0, maxLen) : t;
    if (out.length < appendTrailingSpaceWhenLenLt && out.length < maxLen) {
      out = '$out ';
    }
    return out;
  }

  static Map<String, dynamic> _parseIndexedHttpJsonPayload(String userJson) {
    dynamic raw;
    try {
      raw = jsonDecode(userJson.trim());
    } catch (_) {
      throw ArgumentError('Invalid HTTP server payload.');
    }
    if (raw is! Map) {
      throw ArgumentError('Invalid HTTP server payload.');
    }
    return Map<String, dynamic>.from(raw);
  }

  static String _buildParameterizedServerBleCommand(
    DrifterBuoyCommandModel cmd,
    SelfTestParameterizedCommandFieldKind kind,
    String userValue,
  ) {
    final m = RegExp(r'^\?(\d+),').firstMatch(cmd.requestCommand.trim());
    if (m == null) {
      throw ArgumentError('Invalid request template for ${cmd.testName}.');
    }
    final opcode = m.group(1)!;
    switch (kind) {
      case SelfTestParameterizedCommandFieldKind.ftpField20:
        if (userValue.trim().isEmpty) {
          throw ArgumentError('Enter a value (max 20 characters).');
        }
        return '?$opcode,${_padFtpFieldTo20(userValue)},#';
      case SelfTestParameterizedCommandFieldKind.portFiveDigits:
        final p = _normalizePortFiveDigits(userValue);
        if (p == null) {
          throw ArgumentError(
            'Port must be a number from 0 to 65535 (sent as 5 digits).',
          );
        }
        return '?$opcode,$p,#';
      case SelfTestParameterizedCommandFieldKind.smsCellPlus91:
        final c = _normalizeSecondarySmsCell(userValue);
        if (c == null) {
          throw ArgumentError(
            'Enter a 10-digit mobile number (optional +91 prefix).',
          );
        }
        return '?$opcode,$c,#';
      case SelfTestParameterizedCommandFieldKind.txRedundancy01:
        final v = userValue.trim();
        if (v != '0' && v != '1') {
          throw ArgumentError(
            'Select 0 (GSM and GPRS) or 1 (GSM if GPRS fail).',
          );
        }
        return '?$opcode,$v,#';
      case SelfTestParameterizedCommandFieldKind.rtcHttpWebsite128:
        final encoded = _asciiPrintableNoCommaWithTrailingSpaceRule(
          userValue,
          maxLen: 128,
          appendTrailingSpaceWhenLenLt: 40,
        );
        return '?$opcode,$encoded,#';
      case SelfTestParameterizedCommandFieldKind.rtcHttpKey15:
        final encoded = _asciiPrintableNoCommaWithTrailingSpaceRule(
          userValue,
          maxLen: 15,
          appendTrailingSpaceWhenLenLt: 40,
        );
        return '?$opcode,$encoded,#';
      case SelfTestParameterizedCommandFieldKind.primaryHttpWebsiteIndex128:
        final map = _parseIndexedHttpJsonPayload(userValue);
        final nRaw = map['n'];
        final ni = nRaw is int ? nRaw : int.tryParse(nRaw?.toString() ?? '');
        if (ni == null || ni < 0 || ni > 9) {
          throw ArgumentError('HTTP server number (N) must be from 0 to 9.');
        }
        final url = map['v']?.toString() ?? '';
        final encoded = _asciiPrintableNoCommaWithTrailingSpaceRule(
          url,
          maxLen: 128,
          appendTrailingSpaceWhenLenLt: 128,
        );
        return '?$opcode,$ni,$encoded,#';
      case SelfTestParameterizedCommandFieldKind
          .secondaryHttpWebsiteIndex0to3And128:
        final map = _parseIndexedHttpJsonPayload(userValue);
        final nRaw = map['n'];
        final ni = nRaw is int ? nRaw : int.tryParse(nRaw?.toString() ?? '');
        if (ni == null || ni < 0 || ni > 3) {
          throw ArgumentError('HTTP server number (N) must be from 0 to 3.');
        }
        final url = map['v']?.toString() ?? '';
        final encoded = _asciiPrintableNoCommaWithTrailingSpaceRule(
          url,
          maxLen: 128,
          appendTrailingSpaceWhenLenLt: 128,
        );
        return '?$opcode,$ni,$encoded,#';
      case SelfTestParameterizedCommandFieldKind
          .thirdHttpWebsiteIndex0to3And128Trailing40:
        final map = _parseIndexedHttpJsonPayload(userValue);
        final nRaw = map['n'];
        final ni = nRaw is int ? nRaw : int.tryParse(nRaw?.toString() ?? '');
        if (ni == null || ni < 0 || ni > 3) {
          throw ArgumentError('HTTP server number (N) must be from 0 to 3.');
        }
        final url = map['v']?.toString() ?? '';
        final encoded = _asciiPrintableNoCommaWithTrailingSpaceRule(
          url,
          maxLen: 128,
          appendTrailingSpaceWhenLenLt: 40,
        );
        return '?$opcode,$ni,$encoded,#';
      case SelfTestParameterizedCommandFieldKind
          .factoryHttpWebsiteIndex0to3And128:
        final map = _parseIndexedHttpJsonPayload(userValue);
        final nRaw = map['n'];
        final ni = nRaw is int ? nRaw : int.tryParse(nRaw?.toString() ?? '');
        if (ni == null || ni < 0 || ni > 3) {
          throw ArgumentError('HTTP server number (N) must be from 0 to 3.');
        }
        final url = map['v']?.toString() ?? '';
        final encoded = _asciiPrintableNoCommaWithTrailingSpaceRule(
          url,
          maxLen: 128,
          appendTrailingSpaceWhenLenLt: 128,
        );
        return '?$opcode,$ni,$encoded,#';
      case SelfTestParameterizedCommandFieldKind.batteryVoltageIndex00to11:
        final index = _normalizeBatteryVoltageIndex(userValue);
        if (index == null) {
          throw ArgumentError('Enter an index from 00 to 11.');
        }
        return '?$opcode,$index,#';
      case SelfTestParameterizedCommandFieldKind
          .getSensorParameter83SensorNumber:
        final sensorNo = _normalizeSensorNumber83(userValue);
        if (sensorNo == null) {
          throw ArgumentError('Enter a sensor number from 00 to 99.');
        }
        return '?$opcode,$sensorNo,#';
      case SelfTestParameterizedCommandFieldKind
          .httpServerUsernameIndex1to4And64:
        final map = _parseIndexedHttpJsonPayload(userValue);
        final nRaw = map['n'];
        final ni = nRaw is int ? nRaw : int.tryParse(nRaw?.toString() ?? '');
        if (ni == null || ni < 1 || ni > 4) {
          throw ArgumentError('HTTP server number (N) must be from 1 to 4.');
        }
        final username = map['v']?.toString() ?? '';
        final encoded = _padHttpServerUsernameTo64(username);
        return '?$opcode,$ni,$encoded,#';
      case SelfTestParameterizedCommandFieldKind.dlCellNumberIndex1to4:
        final map = _parseIndexedHttpJsonPayload(userValue);
        final nRaw = map['n'];
        final ni = nRaw is int ? nRaw : int.tryParse(nRaw?.toString() ?? '');
        if (ni == null || ni < 1 || ni > 4) {
          throw ArgumentError('Select slot N from 1 to 4.');
        }
        final number = map['v']?.toString() ?? '';
        final encoded = _normalizeDlCellNumber(ni, number);
        if (encoded == null) {
          throw ArgumentError(
            ni <= 2
                ? 'Enter +91 and 10 digits, or a 13-digit number.'
                : 'Enter exactly 13 digits (no +91).',
          );
        }
        return '?$opcode,$ni,$encoded,#';
      case SelfTestParameterizedCommandFieldKind.testModeValue01:
        final n = userValue.trim();
        if (n != '0' && n != '1') {
          throw ArgumentError('Select test mode N: 0 or 1.');
        }
        return '?$opcode,$n,#';
      case SelfTestParameterizedCommandFieldKind.powerSwitchingValueN:
        final n = userValue.trim();
        if (!RegExp(r'^\d+$').hasMatch(n)) {
          throw ArgumentError('Enter a numeric value for N (digits only).');
        }
        return '?$opcode,$n,#';
      case SelfTestParameterizedCommandFieldKind.setHttpPortIndex1to4FiveDigits:
        final map = _parseIndexedHttpJsonPayload(userValue);
        final nRaw = map['n'];
        final ni = nRaw is int ? nRaw : int.tryParse(nRaw?.toString() ?? '');
        if (ni == null || ni < 0 || ni > 3) {
          throw ArgumentError('Select server number N from 0 to 3.');
        }
        final port = _normalizePortFiveDigits(map['v']?.toString() ?? '');
        if (port == null) {
          throw ArgumentError(
            'Port must be a number from 0 to 65535 (sent as 5 digits).',
          );
        }
        return '?$opcode,$ni,$port,#';
      case SelfTestParameterizedCommandFieldKind.setHttpPasswordIndex1to4And64:
        final map = _parseIndexedHttpJsonPayload(userValue);
        final nRaw = map['n'];
        final ni = nRaw is int ? nRaw : int.tryParse(nRaw?.toString() ?? '');
        if (ni == null || ni < 1 || ni > 4) {
          throw ArgumentError('Select server number N from 1 to 4.');
        }
        final encoded = _padHttpServerUsernameTo64(map['v']?.toString() ?? '');
        return '?$opcode,$ni,$encoded,#';
    }
  }

  @override
  Future<void> close() async {
    await _disconnectSub?.cancel();
    return super.close();
  }
}
