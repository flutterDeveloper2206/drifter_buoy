import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/buoy_setup_validation.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_create_new_drifter_buoy.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserBuoySetupBloc
    extends Bloc<GeneralUserBuoySetupEvent, GeneralUserBuoySetupState> {
  GeneralUserBuoySetupBloc({
    required GeneralUserCreateNewDrifterBuoy createNewDrifterBuoy,
  })  : _createNewDrifterBuoy = createNewDrifterBuoy,
        super(const GeneralUserBuoySetupState.initial()) {
    on<LoadGeneralUserBuoySetup>(_onLoadGeneralUserBuoySetup);
    on<UpdateGeneralUserBuoySetupField>(_onUpdateGeneralUserBuoySetupField);
    on<SaveGeneralUserBuoySetup>(_onSaveGeneralUserBuoySetup);
  }

  final GeneralUserCreateNewDrifterBuoy _createNewDrifterBuoy;

  Future<void> _onLoadGeneralUserBuoySetup(
    LoadGeneralUserBuoySetup event,
    Emitter<GeneralUserBuoySetupState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserBuoySetup event triggered');
    emit(state.copyWith(status: GeneralUserBuoySetupStatus.loading));
    final fromRoute = event.initialStationId?.trim();
    emit(
      state.copyWith(
        status: GeneralUserBuoySetupStatus.loaded,
        stationId: fromRoute ?? '',
        stationName: '',
        transmissionInterval: '',
        transmissionStartTime: '',
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
    final validationError = validateBuoySetupForm(
      stationId: state.stationId,
      stationName: state.stationName,
      transmissionInterval: state.transmissionInterval,
      transmissionStartTime: state.transmissionStartTime,
    );
    if (validationError != null) {
      emit(
        state.copyWith(
          message: validationError,
          isSuccessMessage: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: GeneralUserBuoySetupStatus.saving,
        message: '',
        isSuccessMessage: false,
      ),
    );

    final outcome = await _createNewDrifterBuoy(
      stationId: state.stationId,
      stationName: state.stationName,
      transmissionInterval: state.transmissionInterval,
      transmissionStartTime: state.transmissionStartTime,
    );

    await outcome.foldAsync(
      (failure) async {
        emit(
          state.copyWith(
            status: GeneralUserBuoySetupStatus.loaded,
            message: failure.message,
            isSuccessMessage: false,
          ),
        );
      },
      (response) async {
        if (!response.isSuccess) {
          emit(
            state.copyWith(
              status: GeneralUserBuoySetupStatus.loaded,
              message: response.message.isNotEmpty
                  ? response.message
                  : 'Could not save buoy setup.',
              isSuccessMessage: false,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: GeneralUserBuoySetupStatus.loaded,
            message: response.message.isNotEmpty
                ? response.message
                : 'Set up saved successfully.',
            isSuccessMessage: true,
          ),
        );
      },
    );
  }
}
