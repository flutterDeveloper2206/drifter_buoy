import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserSetupDetailBloc
    extends Bloc<GeneralUserSetupDetailEvent, GeneralUserSetupDetailState> {
  GeneralUserSetupDetailBloc()
    : super(const GeneralUserSetupDetailState.initial()) {
    on<LoadGeneralUserSetupDetail>(_onLoadGeneralUserSetupDetail);
    on<ChangeGeneralUserSetupDetailTab>(_onChangeGeneralUserSetupDetailTab);
    on<ToggleGeneralUserEnableConfiguration>(
      _onToggleGeneralUserEnableConfiguration,
    );
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

  void _onChangeGeneralUserSetupDetailTab(
    ChangeGeneralUserSetupDetailTab event,
    Emitter<GeneralUserSetupDetailState> emit,
  ) {
    emit(state.copyWith(selectedTab: event.tab));
  }

  void _onToggleGeneralUserEnableConfiguration(
    ToggleGeneralUserEnableConfiguration event,
    Emitter<GeneralUserSetupDetailState> emit,
  ) {
    final enabled = !state.enableConfiguration;
    emit(
      state.copyWith(
        enableConfiguration: enabled,
        signalStrength: enabled ? '82%' : '--',
        bluetoothDevice: enabled ? 'DB021_BT' : '--',
        lastSync: enabled ? '10:45 AM' : '--',
        connectionStatus: enabled ? 'Connected' : 'Disconnected',
        memoryStatus: enabled
            ? (state.selectedTab == SetupDetailTab.backup ? '0 Records' : '234 Logs')
            : '234 Logs',
      ),
    );
  }
}
