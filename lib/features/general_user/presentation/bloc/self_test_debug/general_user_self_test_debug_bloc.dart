import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserSelfTestDebugBloc extends Bloc<
  GeneralUserSelfTestDebugEvent,
  GeneralUserSelfTestDebugState
> {
  GeneralUserSelfTestDebugBloc()
    : super(const GeneralUserSelfTestDebugState.initial()) {
    on<LoadGeneralUserSelfTestDebug>(_onLoadGeneralUserSelfTestDebug);
    on<RunGeneralUserSelfTestDebugAction>(_onRunGeneralUserSelfTestDebugAction);
    on<ClearGeneralUserSelfTestDebugMessage>(
      _onClearGeneralUserSelfTestDebugMessage,
    );
  }

  Future<void> _onLoadGeneralUserSelfTestDebug(
    LoadGeneralUserSelfTestDebug event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserSelfTestDebug event triggered');
    emit(state.copyWith(status: GeneralUserSelfTestDebugStatus.loading));
    await Future<void>.delayed(const Duration(milliseconds: 160));
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.loaded,
        actions: const [
          'Manual RTC Update',
          'System Date & Time Change',
          'Manual Data Acquisition',
          'Transmitter Test',
          'System Event Log',
          'Set Transmission Time',
          'Erase Memory',
          'Restore System Parameters',
          'View GPS C/No and DOP Level',
          'Modulation',
          'Sensor Measurement Interval',
          'Measurement Start Time',
        ],
      ),
    );
  }

  Future<void> _onRunGeneralUserSelfTestDebugAction(
    RunGeneralUserSelfTestDebugAction event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) async {
    if (state.status == GeneralUserSelfTestDebugStatus.running) {
      return;
    }

    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.running,
        runningAction: event.action,
        message: '',
        isSuccessMessage: false,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 450));
    emit(
      state.copyWith(
        status: GeneralUserSelfTestDebugStatus.loaded,
        clearRunningAction: true,
        message: '${event.action} completed.',
        isSuccessMessage: true,
      ),
    );
  }

  void _onClearGeneralUserSelfTestDebugMessage(
    ClearGeneralUserSelfTestDebugMessage event,
    Emitter<GeneralUserSelfTestDebugState> emit,
  ) {
    emit(state.copyWith(message: '', isSuccessMessage: false));
  }
}
