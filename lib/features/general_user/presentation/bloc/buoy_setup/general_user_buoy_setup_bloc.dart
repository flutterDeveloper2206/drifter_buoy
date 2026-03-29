import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserBuoySetupBloc
    extends Bloc<GeneralUserBuoySetupEvent, GeneralUserBuoySetupState> {
  GeneralUserBuoySetupBloc() : super(const GeneralUserBuoySetupState.initial()) {
    on<LoadGeneralUserBuoySetup>(_onLoadGeneralUserBuoySetup);
    on<UpdateGeneralUserBuoySetupField>(_onUpdateGeneralUserBuoySetupField);
    on<SaveGeneralUserBuoySetup>(_onSaveGeneralUserBuoySetup);
  }

  Future<void> _onLoadGeneralUserBuoySetup(
    LoadGeneralUserBuoySetup event,
    Emitter<GeneralUserBuoySetupState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserBuoySetup event triggered');
    emit(state.copyWith(status: GeneralUserBuoySetupStatus.loading));
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final fromRoute = event.initialStationId?.trim();
    final hasStationId = fromRoute != null && fromRoute.isNotEmpty;
    emit(
      state.copyWith(
        status: GeneralUserBuoySetupStatus.loaded,
        stationId: hasStationId ? fromRoute : 'DB - 04',
        stationName: 'Alpha 01',
        transmissionInterval: '00:15:00',
        transmissionStartTime: '00:15:00',
        message: '',
        isSuccessMessage: false,
      ),
    );
  }

  void _onUpdateGeneralUserBuoySetupField(
    UpdateGeneralUserBuoySetupField event,
    Emitter<GeneralUserBuoySetupState> emit,
  ) {
    switch (event.field) {
      case BuoySetupField.stationId:
        emit(state.copyWith(stationId: event.value));
      case BuoySetupField.stationName:
        emit(state.copyWith(stationName: event.value));
      case BuoySetupField.transmissionInterval:
        emit(state.copyWith(transmissionInterval: event.value));
      case BuoySetupField.transmissionStartTime:
        emit(state.copyWith(transmissionStartTime: event.value));
    }
  }

  Future<void> _onSaveGeneralUserBuoySetup(
    SaveGeneralUserBuoySetup event,
    Emitter<GeneralUserBuoySetupState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GeneralUserBuoySetupStatus.saving,
        message: '',
        isSuccessMessage: false,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    emit(
      state.copyWith(
        status: GeneralUserBuoySetupStatus.loaded,
        message: 'Set up saved successfully.',
        isSuccessMessage: true,
      ),
    );
  }
}
