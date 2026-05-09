import 'dart:async';

import 'package:drifter_buoy/core/bluetooth/ble_connection_service.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_self_test_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/models/drifter_buoy_command_model.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserSelfTestDebugBloc extends Bloc<
    GeneralUserSelfTestDebugEvent, GeneralUserSelfTestDebugState> {
  GeneralUserSelfTestDebugBloc({
    required GeneralUserSelfTestRemoteDataSource remoteDataSource,
    required BleConnectionService ble,
  })  : _remote = remoteDataSource,
        _ble = ble,
        super(const GeneralUserSelfTestDebugState.initial()) {
    on<LoadGeneralUserSelfTestDebug>(_onLoadGeneralUserSelfTestDebug);
    on<RunGeneralUserSelfTestDebugAction>(_onRunGeneralUserSelfTestDebugAction);
    on<ClearGeneralUserSelfTestDebugMessage>(
      _onClearGeneralUserSelfTestDebugMessage,
    );
    on<SubmitGeneralUserSetStationId>(_onSubmitGeneralUserSetStationId);
    on<ClearGeneralUserSetStationIdPrompt>(_onClearGeneralUserSetStationIdPrompt);
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
  }

  final GeneralUserSelfTestRemoteDataSource _remote;
  final BleConnectionService _ble;

  static const String _setStationIdCommandId = '69f04328523c7ca665297e81';
  static const String _transmitterTestCommandId = '69f04328523c7ca665297e78';
  static const String _checkStatusCommandId = '69f04328523c7ca665297e7e';
  static const String _measurementStartTimeCommandId = '69f04328523c7ca665297e7d';
  static const String _transmitterFrequencyCommandId = '69f04328523c7ca665297eb8';
  static const String _setAttenuationCommandId = '69f04328523c7ca665297eb9';
  static const String _radioSondeTransmitterIdCommandId = '69f04328523c7ca665297eba';
  static const String _fetchStationIdCommand = '?04,,#';

  static const List<DrifterBuoyCommandModel> _staticCommands = [
    DrifterBuoyCommandModel(
      id: '69f04328523c7ca665297e78',
      testName: 'Transmitter Test',
      requestCommand: '?64,N,S,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription:
          'where, N = 0 - Enable plain carrier,N = 1 - Modulation, N= 2 - PRBS where S = 0 -ON,S = 1- OFF',
      response: r'$64,station id,S,#',
      responseDescription:
          'Where,S = 0 - Transmitter test OK,S = 1 - Transmitter test Not OK',
    ),
    DrifterBuoyCommandModel(
      id: '69f04328523c7ca665297e7d',
      testName: 'Measurement Start Time',
      requestCommand: '?61,HH:MM:SS,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: '',
      response: r'$61,list of general parameters#',
      responseDescription:
          'IIIIIIII, NNNNNNNNNNNNNNNN,HH:MM:SS,hh:mm:ss,AAAAAAAAAAAAAAAA,HHH...,S, +91nnnnnnnnnn, +91nnnnnnnnnn,YY,HH:MM:SS',
    ),
    DrifterBuoyCommandModel(
      id: '69f04328523c7ca665297e7e',
      testName: 'Check Status',
      requestCommand: '?02,,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'Returns Status of GPRS and Peripheral Devices',
      response: r'$02,C4,00,00,00,00,0,0,0,0,1,VERSION  1.0.2  ,#',
      responseDescription: r'$02,PP,GG,GG,GG,GG, F1, MT1, F2, MT2, CH, D. L Firmware Version#',
    ),
    DrifterBuoyCommandModel(
      id: '69f04328523c7ca665297e81',
      testName: 'Set Station Id',
      requestCommand: '?04,,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription: 'Fetch current station id and update (8 chars).',
      response: r'IIIIIIII,...',
      responseDescription: 'Opens popup for station id update.',
    ),
    DrifterBuoyCommandModel(
      id: '69f04328523c7ca665297eb8',
      testName: 'Set/Get transmitter frequency',
      requestCommand: '?65,N,S,FFFF,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription:
          'S = 0 get, 1 set. N=0 UHF, 1 Radio Sonde. Freq 402.0000 to 403.0000 MHz.',
      response: r'$65,station id ,N,S,FFFF,#',
      responseDescription: 'Set/get frequency status and value.',
    ),
    DrifterBuoyCommandModel(
      id: '69f04328523c7ca665297eb9',
      testName: 'Set Attenuation',
      requestCommand: '?66,N,S,xx,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription:
          'N=0 UHF, 1 Radio Sonde. S=0 get, S=1 set. xx is attenuation value.',
      response: r'$66,station id,N,S,xx,#',
      responseDescription: 'Returns attenuation status/value.',
    ),
    DrifterBuoyCommandModel(
      id: '69f04328523c7ca665297eba',
      testName: 'Get station ID of Radio sonde Transmitter',
      requestCommand: '?67,S,xxxxx,#',
      waitingPeriodSecondsRaw: 'NA',
      requestCommandDescription:
          'S=0 get, 1 set. xxxxx = station id of sonde transmitter (5 chars).',
      response: r'$67,station id,S,xxxx,#',
      responseDescription:
          'S = 0 get, 1 set. xxxxx = station id of sonde transmitter (5 chars).',
    ),
  ];


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
          ),
        );
      },
      (data) {
        final allowedIds = data.result
            .where((c) => c.isActive)
            .map((c) => c.id.trim())
            .where((id) => id.isNotEmpty)
            .toSet();

        final cmds = allowedIds.isEmpty
            ? _staticCommands
            : _staticCommands
                .where((c) => allowedIds.contains(c.id))
                .toList();

        emit(
          state.copyWith(
            status: GeneralUserSelfTestDebugStatus.loaded,
            commands: cmds,
            message: cmds.isEmpty
                ? 'No self-test commands are permitted for this user.'
                : '',
            isSuccessMessage: false,
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
        state.copyWith(
          message: 'Invalid command.',
          isSuccessMessage: false,
        ),
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
      final line = await _ble.sendDrifterAsciiCommand(
        cmd.requestCommand,
        wait,
      );

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
          message: 'No buoy connected. Pair from Setup and connect over Bluetooth first.',
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
            message: 'Update failed. Device returned station id: $updatedStationId',
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
            message: 'Could not parse measurement start time from device response.',
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
      AppLogger.e('Fetch measurement start time error', error: e, stackTrace: st);
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
      final line = await _ble.sendDrifterAsciiCommand(
        '?61,$nextTime,#',
        wait,
      );
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
        '?65,0,0,#',
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
      AppLogger.e('Fetch transmitter frequency error', error: e, stackTrace: st);
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
        '?65,$n,1,$ffff,#',
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
      final line = await _ble.sendDrifterAsciiCommand(
        '?66,$n,1,$xx,#',
        wait,
      );
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
        '?67,0,#',
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
      AppLogger.e('Fetch radio sonde transmitter id error', error: e, stackTrace: st);
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
        '?67,1,$nextId,#',
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
      AppLogger.e('Set radio sonde transmitter id error', error: e, stackTrace: st);
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
        final line = await _ble.sendDrifterAsciiCommand(
          '?64,$n,$s,#',
          wait,
        );
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
              helpText:
                  'One or more responses returned S=1 (Transmitter test Not OK).',
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
            helpText: 'S = 0 means Transmitter test OK. S = 1 means Not OK.',
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
    final candidate = ((first.startsWith(r'$') || first.startsWith('?')) &&
            parts.length > 1)
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

  SelfTestCheckStatusPrompt? _parseCheckStatus(String responseLine) {
    final cleaned = responseLine.trim();
    if (cleaned.isEmpty) {
      return null;
    }
    final parts = cleaned.split(',').map((e) => e.trim()).toList();
    if (parts.length < 12) {
      return null;
    }
    final fw = parts.length > 12
        ? parts.sublist(12).join(',').replaceAll('#', '').trim()
        : '';

    return SelfTestCheckStatusPrompt(
      peripheralStatus: parts[2],
      gprsPrimary: parts[3],
      gprsSecondary: parts[4],
      gprsThird: parts[5],
      gprsFactory: parts[6],
      memory1Fail: parts[7],
      memory1Test: parts[8],
      memory2Fail: parts[9],
      memory2Test: parts[10],
      chargeStatus: parts[11],
      firmwareVersion: fw,
      rawResponse: cleaned,
    );
  }

  void _onClearGeneralUserSelfTestDebugMessage(
    ClearGeneralUserSelfTestDebugMessage event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(message: '', isSuccessMessage: false));
  }
}
