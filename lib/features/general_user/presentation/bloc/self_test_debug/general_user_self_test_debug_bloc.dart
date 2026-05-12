import 'dart:async';

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
    on<SubmitGeneralUserMeasurementStartTime>(
      _onSubmitGeneralUserMeasurementStartTime,
    );
    on<ClearGeneralUserMeasurementStartTimePrompt>(
      _onClearGeneralUserMeasurementStartTimePrompt,
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
    _disconnectSub = _ble.disconnectedRemoteIds.listen((_) {
      add(const NotifyBlePeripheralDisconnected());
    });
  }

  final GeneralUserSelfTestRemoteDataSource _remote;
  final BleConnectionService _ble;
  StreamSubscription<String>? _disconnectSub;

  /// Command document ids (Admin/Command/GetAllDrifterBuoyCommands); order
  /// matches [_staticCommands].
  static const String _transmitterTestCommandId = '69f04328523c7ca665297e78';
  static const String _measurementStartTimeCommandId =
      '69f04328523c7ca665297e7d';
  static const String _checkStatusCommandId = '69f04328523c7ca665297e7e';
  static const String _setStationIdCommandId = '69f04328523c7ca665297e81';
  static const String _primaryServerFtpAddressCommandId =
      '69f04328523c7ca665297e88';
  static const String _primaryServerFtpPortCommandId =
      '69f04328523c7ca665297e89';
  static const String _primaryServerFtpPathCommandId =
      '69f04328523c7ca665297e8a';
  static const String _primaryServerFtpUsernameCommandId =
      '69f04328523c7ca665297e8b';
  static const String _primaryServerFtpPasswordCommandId =
      '69f04328523c7ca665297e8c';
  static const String _secondaryServerFtpAddressCommandId =
      '69f04328523c7ca665297e90';
  static const String _secondaryServerFtpPortCommandId =
      '69f04328523c7ca665297e91';
  static const String _secondaryServerFtpPathCommandId =
      '69f04328523c7ca665297e92';
  static const String _secondaryServerFtpUsernameCommandId =
      '69f04328523c7ca665297e93';
  static const String _secondaryServerFtpPasswordCommandId =
      '69f04328523c7ca665297e94';
  static const String _secondaryServerSmsCellNoCommandId =
      '69f04328523c7ca665297e95';
  static const String _secondaryServerTxMediaRedundancyCommandId =
      '69f04328523c7ca665297e96';
  static const String _transmitterFrequencyCommandId =
      '69f04328523c7ca665297eb8';
  static const String _setAttenuationCommandId = '69f04328523c7ca665297eb9';
  static const String _radioSondeTransmitterIdCommandId =
      '69f04328523c7ca665297eba';

  /// Catalog ids (see Command reposne BLE Sheet1.csv) → how to embed user input.
  static const Map<String, SelfTestParameterizedCommandFieldKind>
      _parameterizedServerFieldKindByCommandId = {
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
  };

  static const String _fetchStationIdCommand = '?04,,#';

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

  /// Full catalog aligned with Admin/Command/GetAllDrifterBuoyCommands. Only
  /// commands marked active by the API are shown when the request succeeds.
  static const List<DrifterBuoyCommandModel> _staticCommands = [
    DrifterBuoyCommandModel(
      id: _transmitterTestCommandId,
      testName: 'Transmitter Test',
      requestCommand: '?64,N,S,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription:
          'where, N = 0 – Enable plain carrier,N = 1 – Modulation, N= 2 - PRBS   where   S = 0 -ON,S = 1- OFF',
      response: r'$64,station id,S,#',
      responseDescription:
          'Where,S = 0 – Transmitter test OK,S = 1 – Transmitter test Not OK ',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _measurementStartTimeCommandId,
      testName: 'Measurement Start Time',
      requestCommand: '?61,HH:MM:SS,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: '',
      response: r'$61,list of general parameters#',
      responseDescription:
          '''IIIIIIII, NNNNNNNNNNNNNNNN,HH:MM:SS,hh:mm:ss,AAAAAAAAAAAAAAAA,HHH…,S, +91nnnnnnnnnn, +91nnnnnnnnnn,YY,HH:MM:SS
 (Station id, station name, Tx interval, measurement interval, APN , APN, Fast SMS check, admin cell no.1, admin cell no. 2s, sensor power on time, measurement start time)
Max length = 8+1+16+1+8+1+8+1+31+1+31+1+1+1+13+1+13+1+2+1+8= 149 characters''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _checkStatusCommandId,
      testName: 'Check Status',
      requestCommand: '?02,,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription:
          'Returns Status of GPRS and Peripheral Devices',
      response: r'$02,C4,00,00,00,00,0,0,0,0,1,VERSION  1.0.2  ,#',
      responseDescription:
          r'''$02,PP,GG,GG,GG,GG, F1, MT1, F2, MT2, CH, D. L Firmware Version# 
(Peripheral status, GPRS status of primary server, GPRS status of secondary server, GPRS status of third server, GPRS status of factory server)
F1 – Memory 1 Fail Status (0 = OK, 1 = Not OK)
MT1– Memory 1 Test Result (0 = OK, 1 = Not OK)
F2 – Memory 2 Fail Status (0 = OK, 1 = Not OK)
MT2– Memory 2 Test Result (0 = OK, 1 = Not OK)
CH – Battery Charging Status (0 = Charging ON, 1 = Charging OFF, 2 = Fault)
DL Firmware Version – Indicates the latest Data Logger firmware version. ''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setStationIdCommandId,
      testName: 'Set Station Id',
      requestCommand: '?06,XXXXXXXX,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'Sets 8 char station id',
      response: r'$06,list of general parameters#',
      responseDescription:
          '''IIIIIIII, NNNNNNNNNNNNNNNN,HH:MM:SS,hh:mm:ss,AAAAAAAAAAAAAAAA,HHH…,S, +91nnnnnnnnnn, +91nnnnnnnnnn,YY,HH:MM:SS
 (Station id, station name, Tx interval, measurement interval, APN , APN, Fast SMS check, admin cell no.1, admin cell no. 2s, sensor power on time, measurement start time)
Max length = 8+1+16+1+8+1+8+1+31+1+31+1+1+1+13+1+13+1+2+1+8= 149 characters''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _primaryServerFtpAddressCommandId,
      testName: 'Primary server FTP address',
      requestCommand: '?15,xxxx..,#',
      waitingPeriodSecondsRaw: '60',
      requestCommandDescription:
          '(max 20 char) .Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$15,all primary server settings#',
      responseDescription:
          '''IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _primaryServerFtpPortCommandId,
      testName: 'Primary server FTP port no.',
      requestCommand: '?16,PPPPP,#',
      waitingPeriodSecondsRaw: '60',
      requestCommandDescription:
          'PPPPP(Port no. – 5 digit long, Range = 0 to 65535)',
      response: r'$16,all primary server settings#',
      responseDescription:
          '''IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _primaryServerFtpPathCommandId,
      testName: 'Primary server FTP path',
      requestCommand: '?17,xxxx..,#',
      waitingPeriodSecondsRaw: '60',
      requestCommandDescription:
          '(Max 20 characters)\n'
          'Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$17,all primary server settings#',
      responseDescription:
          '''IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _primaryServerFtpUsernameCommandId,
      testName: 'Primary server FTP username',
      requestCommand: '?18,xxxx..,#',
      waitingPeriodSecondsRaw: '60',
      requestCommandDescription:
          '(Max 20 characters)\n'
          'Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$18,all primary server settings#',
      responseDescription:
          '''IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _primaryServerFtpPasswordCommandId,
      testName: 'Primary server FTP password',
      requestCommand: '?19,xxxx..,#',
      waitingPeriodSecondsRaw: '60',
      requestCommandDescription:
          '(Max 20 characters)\n'
          'Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$19,all primary server settings#',
      responseDescription:
          '''IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerFtpAddressCommandId,
      testName: 'Secondary server FTP address',
      requestCommand: '?23,xxxx..,#',
      waitingPeriodSecondsRaw: '60',
      requestCommandDescription:
          '(max 20 char) Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$23,all secondary server settings#',
      responseDescription:
          '''IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerFtpPortCommandId,
      testName: 'Secondary server FTP port no.',
      requestCommand: '?24,PPPPP,#',
      waitingPeriodSecondsRaw: '60',
      requestCommandDescription:
          'PPPPP(Port no. – 5 digit long, Range = 0 to 65535)',
      response: r'$24,all secondary server settings#',
      responseDescription:
          '''IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerFtpPathCommandId,
      testName: 'Secondary server FTP path',
      requestCommand: '?25,xxxx..,#',
      waitingPeriodSecondsRaw: '60',
      requestCommandDescription:
          '(Max 20 characters)\n'
          'Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$25,all secondary server settings#',
      responseDescription:
          '''IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerFtpUsernameCommandId,
      testName: 'Secondary server FTP user name',
      requestCommand: '?26,xxxx..,#',
      waitingPeriodSecondsRaw: '60',
      requestCommandDescription:
          '(Max 20 characters)\n'
          'Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$26,all secondary server settings#',
      responseDescription:
          '''IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerFtpPasswordCommandId,
      testName: 'Secondary server FTP password',
      requestCommand: '?27,xxxx..,#',
      waitingPeriodSecondsRaw: '60',
      requestCommandDescription:
          '(Max 20 characters)\n'
          'Alphanumeric ASCII characters. Use ‘ ‘(space) as last character if < 20 char. Space char will not be part of address',
      response: r'$27,all secondary server settings#',
      responseDescription:
          '''IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerSmsCellNoCommandId,
      testName: 'Set secondary server SMS cell no',
      requestCommand: '?28,+91nnnnnnnnnn,#',
      waitingPeriodSecondsRaw: '60',
      requestCommandDescription:
          'PPPPP(nnnnnnnnnn: Cellular no. – 10 digit long)',
      response: r'$28,all secondary server settings#',
      responseDescription:
          '''IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _secondaryServerTxMediaRedundancyCommandId,
      testName: 'Secondary server tx media redundancy',
      requestCommand: '?29,n,#',
      waitingPeriodSecondsRaw: '60',
      requestCommandDescription:
          'n = 0-GSM and GPRS, 1-GSM if GPRS Fail',
      response: r'$29,all secondary server settings#',
      responseDescription:
          '''IIIIII, HHHH…, FFF…, PPPPP,ffff…,uuuu…,pppp…,+91nnnnnnnnnn,R-(Station id,FTP server address, FTP port no., FTP file path, FTP username, FTP password, cell no., TX redundancy),Max length = 8+1+20+1+5+1+20+1+20+1+20+1+13+1+1 = 114 characters''',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _transmitterFrequencyCommandId,
      testName: 'Set/Get transmitter frequency',
      requestCommand: '?65,N,S,FFFF,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription:
          'S = 0 – to get ,1- set if S =0 no need to send FFFF. N= 0 for UHF, 1 for Radio Sonde. Freq from 402.0000 to 403.0000Mhz.FFFF - value of Frequency',
      response: r'$65,station id ,N,S,FFFF,#',
      responseDescription:
          'If S = 0, then only consider valid FFFF value. Value of S below: 0 - frequency set successful,1 - Checksum error,2 - frequency not set,3 -transmitter communication problem or not connected  4 - get successful,N= 0 for UHF, 1 for Radio Sonde FFFF - value of Frequency',
      isActive: true,
    ),
    DrifterBuoyCommandModel(
      id: _setAttenuationCommandId,
      testName: 'Set Attenuation',
      requestCommand: '?66,N,S,xx,#',
      waitingPeriodSecondsRaw: 'NA',
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
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription:
          'S = 0 – get, 1- set in case of S =0 no need to send xxxxx xxxxx = station id of sonde transmitter (5 char)',
      response: r'$67,station id,S,xxxx,#',
      responseDescription:
          'S = 0 – get, 1- set xxxxx = station id of sonde transmitter (5 char)',
      isActive: true,
    ),
  ];

  static final Map<String, DrifterBuoyCommandModel> _staticCommandsById = {
    for (final c in _staticCommands) c.id: c,
  };

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
          ),
        );
      },
      (data) {
        final apiCommands = data.result;
        final List<DrifterBuoyCommandModel> cmds;

        if (apiCommands.isEmpty) {
          cmds = List<DrifterBuoyCommandModel>.from(_staticCommands);
        } else {
          cmds = <DrifterBuoyCommandModel>[];
          for (final api in apiCommands) {
            if (!api.isActive) continue;
            final id = api.id.trim();
            if (id.isEmpty) continue;
            cmds.add(_staticCommandsById[id] ?? api);
          }
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
          ),
        );
      },
    );
  }

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

    if (cmd.id == _setStationIdCommandId) {
      await _onOpenSetStationIdPrompt(cmd, index, emit);
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
    if (cmd.id == _measurementStartTimeCommandId) {
      await _onOpenMeasurementStartTimePrompt(cmd, index, emit);
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

    final parameterizedKind = _parameterizedServerFieldKindByCommandId[cmd.id];
    if (parameterizedKind != null) {
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          parameterizedCommandPrompt: SelfTestParameterizedCommandPrompt(
            commandId: cmd.id,
            testName: cmd.testName,
            fieldKind: parameterizedKind,
            requestHelpText: cmd.requestCommandDescription,
          ),
          clearLastSnapshot: true,
          message: '',
          isSuccessMessage: false,
        ),
      );
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

      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          lastSnapshot: SelfTestBleResponseSnapshot(
            testName: cmd.testName,
            responseLine: line,
            helpText: cmd.responseDescription.trim().isEmpty
                ? cmd.response.trim()
                : cmd.responseDescription.trim(),
          ),
          message: '',
          isSuccessMessage: false,
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
      (c) => c.id == _setStationIdCommandId,
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
      (c) => c.id == _measurementStartTimeCommandId,
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

  void _onClearGeneralUserMeasurementStartTimePrompt(
    ClearGeneralUserMeasurementStartTimePrompt event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(clearMeasurementTimePrompt: true));
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

  String? _extractStationId(String responseLine) {
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
        message: '',
        isSuccessMessage: false,
      ),
    );
  }

  Future<void> _onSubmitGeneralUserParameterizedCommand(
    SubmitGeneralUserParameterizedCommand event,
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

    final commandId = event.commandId.trim();
    final kind = _parameterizedServerFieldKindByCommandId[commandId];
    final model = _staticCommandsById[commandId];
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
      final summary = _formatParameterizedServerBleSummary(responseLine);
      emit(
        state.copyWith(
          status: GeneralUserSelfTestDebugStatus.loaded,
          clearRunningCommandIndex: true,
          clearParameterizedCommandPrompt: true,
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

  /// FTP-style fields: max 20 chars; shorter values padded with trailing spaces.
  static String _padFtpFieldTo20(String raw) {
    final t = raw.trim();
    if (t.length > 20) {
      return t.substring(0, 20);
    }
    return t.padRight(20, ' ');
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

  static String _buildParameterizedServerBleCommand(
    DrifterBuoyCommandModel cmd,
    SelfTestParameterizedCommandFieldKind kind,
    String userValue,
  ) {
    final m = RegExp(r'^\?(\d+),').firstMatch(cmd.requestCommand.trim());
    if (m == null) {
      throw ArgumentError(
        'Invalid request template for ${cmd.testName}.',
      );
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
          throw ArgumentError('Select 0 (GSM and GPRS) or 1 (GSM if GPRS fail).');
        }
        return '?$opcode,$v,#';
    }
  }

  @override
  Future<void> close() async {
    await _disconnectSub?.cancel();
    return super.close();
  }
}
