import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserMapFiltersBloc
    extends Bloc<GeneralUserMapFiltersEvent, GeneralUserMapFiltersState> {
  GeneralUserMapFiltersBloc()
    : super(const GeneralUserMapFiltersState.initial()) {
    on<LoadGeneralUserMapFilters>(_onLoadGeneralUserMapFilters);
    on<ToggleTrajectory>(_onToggleTrajectory);
    on<ToggleGpsPoints>(_onToggleGpsPoints);
    on<ToggleBatteryStatus>(_onToggleBatteryStatus);
    on<ToggleGprsSignal>(_onToggleGprsSignal);
    on<ToggleStatusFilter>(_onToggleStatusFilter);
    on<ToggleSignalStrengthFilter>(_onToggleSignalStrengthFilter);
    on<ToggleLocationZoneFilter>(_onToggleLocationZoneFilter);
    on<ChangeMapDisplayType>(_onChangeMapDisplayType);
  }

  Future<void> _onLoadGeneralUserMapFilters(
    LoadGeneralUserMapFilters event,
    Emitter<GeneralUserMapFiltersState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserMapFilters event triggered');
    emit(
      state.copyWith(status: GeneralUserMapFiltersStatus.loading, message: ''),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      emit(state.copyWith(status: GeneralUserMapFiltersStatus.loaded));
      AppLogger.i('LoadGeneralUserMapFilters success');
    } catch (error, stackTrace) {
      AppLogger.e(
        'LoadGeneralUserMapFilters failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: GeneralUserMapFiltersStatus.error,
          message: 'Failed to load settings. Please try again.',
        ),
      );
    }
  }

  void _onToggleTrajectory(
    ToggleTrajectory event,
    Emitter<GeneralUserMapFiltersState> emit,
  ) {
    emit(state.copyWith(trajectoryEnabled: !state.trajectoryEnabled));
  }

  void _onToggleGpsPoints(
    ToggleGpsPoints event,
    Emitter<GeneralUserMapFiltersState> emit,
  ) {
    emit(state.copyWith(gpsPointsEnabled: !state.gpsPointsEnabled));
  }

  void _onToggleBatteryStatus(
    ToggleBatteryStatus event,
    Emitter<GeneralUserMapFiltersState> emit,
  ) {
    emit(state.copyWith(batteryStatusEnabled: !state.batteryStatusEnabled));
  }

  void _onToggleGprsSignal(
    ToggleGprsSignal event,
    Emitter<GeneralUserMapFiltersState> emit,
  ) {
    emit(state.copyWith(gprsSignalEnabled: !state.gprsSignalEnabled));
  }

  void _onToggleStatusFilter(
    ToggleStatusFilter event,
    Emitter<GeneralUserMapFiltersState> emit,
  ) {
    emit(state.copyWith(statusFilterEnabled: !state.statusFilterEnabled));
  }

  void _onToggleSignalStrengthFilter(
    ToggleSignalStrengthFilter event,
    Emitter<GeneralUserMapFiltersState> emit,
  ) {
    emit(state.copyWith(signalStrengthEnabled: !state.signalStrengthEnabled));
  }

  void _onToggleLocationZoneFilter(
    ToggleLocationZoneFilter event,
    Emitter<GeneralUserMapFiltersState> emit,
  ) {
    emit(
      state.copyWith(locationZoneFilterEnabled: !state.locationZoneFilterEnabled),
    );
  }

  void _onChangeMapDisplayType(
    ChangeMapDisplayType event,
    Emitter<GeneralUserMapFiltersState> emit,
  ) {
    emit(state.copyWith(mapType: event.mapType));
  }
}
