import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserSetupDetailBloc
    extends Bloc<GeneralUserSetupDetailEvent, GeneralUserSetupDetailState> {
  GeneralUserSetupDetailBloc()
    : super(const GeneralUserSetupDetailState.initial()) {
    on<LoadGeneralUserSetupDetail>(_onLoadGeneralUserSetupDetail);
    on<ToggleGeneralUserEnableConfiguration>(
      _onToggleGeneralUserEnableConfiguration,
    );
    on<ClearBluetoothSetup>(_onClearBluetoothSetup);
    on<SelectBluetoothDevice>(_onSelectBluetoothDevice);
  }

  Future<void> _onLoadGeneralUserSetupDetail(
    LoadGeneralUserSetupDetail event,
    Emitter<GeneralUserSetupDetailState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserSetupDetail event triggered');
    emit(
      state.copyWith(
        status: GeneralUserSetupDetailStatus.loading,
        message: '',
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 160));
    emit(
      state.copyWith(
        status: GeneralUserSetupDetailStatus.loaded,
      ),
    );
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

  void _onClearBluetoothSetup(
    ClearBluetoothSetup event,
    Emitter<GeneralUserSetupDetailState> emit,
  ) {
    emit(
      state.copyWith(
        bluetoothDevice: '--',
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
    emit(
      state.copyWith(
        bluetoothDevice: event.bluetoothId,
        connectionStatus: 'Connected',
        signalStrength: '82%',
        lastSync: '10:45 AM',
      ),
    );
  }

  String _memoryLabel(bool configEnabled) {
    return configEnabled ? '234 Logs' : '0 Records';
  }
}
