import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_create_new_drifter_buoy.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserBuoySetupBloc
    extends Bloc<GeneralUserBuoySetupEvent, GeneralUserBuoySetupState> {
  GeneralUserBuoySetupBloc({
    required GeneralUserCreateNewDrifterBuoy createNewDrifterBuoy,
  }) : _createNewDrifterBuoy = createNewDrifterBuoy,
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
    final stationId = state.stationId.trim();
    final stationName = state.stationName.trim();
    final transmissionInterval = state.transmissionInterval.trim();
    final transmissionStartTime = state.transmissionStartTime.trim();

    // 1. Station ID Validations
    if (stationId.isEmpty) {
      emit(
        state.copyWith(
          status: GeneralUserBuoySetupStatus.loaded,
          message: 'Buoy ID is required.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (stationId.contains(',')) {
      emit(
        state.copyWith(
          status: GeneralUserBuoySetupStatus.loaded,
          message: 'Buoy ID cannot contain a comma.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (stationId.length > 8) {
      emit(
        state.copyWith(
          status: GeneralUserBuoySetupStatus.loaded,
          message: 'Buoy ID must be at most 8 characters.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    // 2. Station Name Validations
    if (stationName.isEmpty) {
      emit(
        state.copyWith(
          status: GeneralUserBuoySetupStatus.loaded,
          message: 'Station Name is required.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (stationName.contains(',')) {
      emit(
        state.copyWith(
          status: GeneralUserBuoySetupStatus.loaded,
          message: 'Station Name cannot contain a comma.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (stationName.length > 16) {
      emit(
        state.copyWith(
          status: GeneralUserBuoySetupStatus.loaded,
          message: 'Station Name must be at most 16 characters.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    // 3. Transmission Interval Validations
    if (transmissionInterval.isEmpty) {
      emit(
        state.copyWith(
          status: GeneralUserBuoySetupStatus.loaded,
          message: 'Transmission Interval is required.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (!_isValidInterval(transmissionInterval)) {
      emit(
        state.copyWith(
          status: GeneralUserBuoySetupStatus.loaded,
          message: 'Transmission Interval must be in HH:MM:SS format or a valid integer.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    // 4. Transmission Start Time Validations
    if (transmissionStartTime.isEmpty) {
      emit(
        state.copyWith(
          status: GeneralUserBuoySetupStatus.loaded,
          message: 'Transmission Start Time is required.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (!_isValidHhMmSs(transmissionStartTime)) {
      emit(
        state.copyWith(
          status: GeneralUserBuoySetupStatus.loaded,
          message: 'Transmission Start Time must be in HH:MM:SS format (valid 24-hour time).',
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

    final intervalInSeconds = _getTransmissionIntervalInSeconds(transmissionInterval);

    final result = await _createNewDrifterBuoy.call(
      stationId: stationId,
      stationName: stationName,
      transmissionInterval: intervalInSeconds,
      transmissionStartTime: transmissionStartTime,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: GeneralUserBuoySetupStatus.loaded,
            message: failure.message,
            isSuccessMessage: false,
          ),
        );
      },
      (response) {
        emit(
          state.copyWith(
            status: GeneralUserBuoySetupStatus.loaded,
            message: response.message.trim().isNotEmpty
                ? response.message
                : 'Set up saved successfully.',
            isSuccessMessage: true,
          ),
        );
      },
    );
  }

  bool _isValidHhMmSs(String value) {
    final m = RegExp(r'^(\d{2}):(\d{2}):(\d{2})$').firstMatch(value.trim());
    if (m == null) return false;
    final hh = int.tryParse(m.group(1)!) ?? 99;
    final mm = int.tryParse(m.group(2)!) ?? 99;
    final ss = int.tryParse(m.group(3)!) ?? 99;
    return hh <= 23 && mm <= 59 && ss <= 59;
  }

  bool _isValidInterval(String value) {
    if (_isValidHhMmSs(value)) return true;
    return RegExp(r'^\d+$').hasMatch(value.trim());
  }

  String _getTransmissionIntervalInSeconds(String raw) {
    final trimmed = raw.trim();
    final m = RegExp(r'^(\d{2}):(\d{2}):(\d{2})$').firstMatch(trimmed);
    if (m != null) {
      final hh = int.tryParse(m.group(1)!) ?? 0;
      final mm = int.tryParse(m.group(2)!) ?? 0;
      final ss = int.tryParse(m.group(3)!) ?? 0;
      final total = hh * 3600 + mm * 60 + ss;
      return total.toString();
    }
    return trimmed;
  }
}
