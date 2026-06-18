import 'package:drifter_buoy/core/bluetooth/ble_connection_service.dart';
import 'package:drifter_buoy/core/bluetooth/ble_drifter_runtime_settings.dart';
import 'package:drifter_buoy/core/constants/ble_gatt_constants.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserSetupDetailBloc
    extends Bloc<GeneralUserSetupDetailEvent, GeneralUserSetupDetailState> {
  GeneralUserSetupDetailBloc({
    required BleConnectionService ble,
    required BleDrifterRuntimeSettings bleSettings,
  }) : _ble = ble,
       _bleSettings = bleSettings,
       super(const GeneralUserSetupDetailState.initial()) {
    on<LoadGeneralUserSetupDetail>(_onLoadGeneralUserSetupDetail);
    on<ToggleGeneralUserEnableConfiguration>(
      _onToggleGeneralUserEnableConfiguration,
    );
    on<ClearBluetoothSetup>(_onClearBluetoothSetup);
    on<SyncBluetoothDisconnected>(_onSyncBluetoothDisconnected);
    on<SelectBluetoothDevice>(_onSelectBluetoothDevice);
    on<SaveBleTimingSettings>(_onSaveBleTimingSettings);
    on<ClearBleTimingSettingsMessage>(_onClearBleTimingSettingsMessage);
  }

  final BleConnectionService _ble;
  final BleDrifterRuntimeSettings _bleSettings;

  Future<void> _onLoadGeneralUserSetupDetail(
    LoadGeneralUserSetupDetail event,
    Emitter<GeneralUserSetupDetailState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserSetupDetail event triggered');
    final trimmedId = event.buoyId?.trim();
    final contextBuoyId =
        trimmedId != null && trimmedId.isNotEmpty ? trimmedId : null;

    emit(
      GeneralUserSetupDetailState(
        status: GeneralUserSetupDetailStatus.loading,
        enableConfiguration: false,
        signalStrength: '--',
        bluetoothDevice: '--',
        bluetoothRemoteId: null,
        lastSync: '--',
        connectionStatus: 'Disconnected',
        memoryStatus: '0 Records',
        message: '',
        contextBuoyId: contextBuoyId,
        chunkWriteDelayMs: DrifterBleGatt.defaultChunkWriteDelayMs,
        commandResponseTimeoutSec:
            DrifterBleGatt.defaultCommandResponseTimeoutSec,
      ),
    );

    await _bleSettings.load();

    await Future<void>.delayed(const Duration(milliseconds: 160));
    emit(
      state.copyWith(
        status: GeneralUserSetupDetailStatus.loaded,
        chunkWriteDelayMs: _bleSettings.chunkWriteDelayMs,
        commandResponseTimeoutSec: _bleSettings.commandResponseTimeoutSec,
      ),
    );
  }

  Future<void> _onSaveBleTimingSettings(
    SaveBleTimingSettings event,
    Emitter<GeneralUserSetupDetailState> emit,
  ) async {
    try {
      await _bleSettings.save(
        chunkWriteDelayMs: event.chunkWriteDelayMs,
        commandResponseTimeoutSec: event.commandResponseTimeoutSec,
      );
      emit(
        state.copyWith(
          chunkWriteDelayMs: _bleSettings.chunkWriteDelayMs,
          commandResponseTimeoutSec: _bleSettings.commandResponseTimeoutSec,
          bleSettingsMessage: 'BLE timing settings saved.',
          bleSettingsMessageIsSuccess: true,
        ),
      );
    } on ArgumentError catch (e) {
      emit(
        state.copyWith(
          bleSettingsMessage: e.message?.toString() ?? e.toString(),
          bleSettingsMessageIsSuccess: false,
        ),
      );
    } catch (e, st) {
      AppLogger.e('Save BLE timing settings failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          bleSettingsMessage: 'Could not save BLE timing settings.',
          bleSettingsMessageIsSuccess: false,
        ),
      );
    }
  }

  void _onClearBleTimingSettingsMessage(
    ClearBleTimingSettingsMessage event,
    Emitter<GeneralUserSetupDetailState> emit,
  ) {
    emit(state.copyWith(clearBleSettingsMessage: true));
  }

  void _onToggleGeneralUserEnableConfiguration(
    ToggleGeneralUserEnableConfiguration event,
    Emitter<GeneralUserSetupDetailState> emit,
  ) {
    final enabled = !state.enableConfiguration;
    emit(
      state.copyWith(
        enableConfiguration: enabled,
        memoryStatus: _memoryLabel(enabled),
      ),
    );
  }

  Future<void> _onClearBluetoothSetup(
    ClearBluetoothSetup event,
    Emitter<GeneralUserSetupDetailState> emit,
  ) async {
    try {
      await _ble.disconnect();
    } catch (e, st) {
      AppLogger.e('BLE disconnect failed', error: e, stackTrace: st);
    }
    emit(
      state.copyWith(
        bluetoothDevice: '--',
        clearBluetoothRemoteId: true,
        connectionStatus: 'Disconnected',
        signalStrength: '--',
        lastSync: '--',
      ),
    );
  }

  void _onSelectBluetoothDevice(
    SelectBluetoothDevice event,
    Emitter<GeneralUserSetupDetailState> emit,
  ) {
    final name = event.displayName.trim().isNotEmpty
        ? event.displayName.trim()
        : event.bluetoothId;
    emit(
      state.copyWith(
        bluetoothDevice: name,
        bluetoothRemoteId: event.bluetoothId,
        connectionStatus: 'Connected',
        signalStrength: '82%',
        lastSync: '10:45 AM',
      ),
    );
  }

  void _onSyncBluetoothDisconnected(
    SyncBluetoothDisconnected event,
    Emitter<GeneralUserSetupDetailState> emit,
  ) {
    emit(
      state.copyWith(
        bluetoothDevice: '--',
        clearBluetoothRemoteId: true,
        connectionStatus: 'Disconnected',
        signalStrength: '--',
        lastSync: '--',
      ),
    );
  }

  String _memoryLabel(bool configEnabled) {
    return configEnabled ? '234 Logs' : '0 Records';
  }
}
