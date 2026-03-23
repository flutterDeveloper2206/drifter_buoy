import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_filters/general_user_trajectory_filters_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_filters/general_user_trajectory_filters_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_trajectory_live_map_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class GeneralUserTrajectoryFiltersBloc
    extends
        Bloc<
          GeneralUserTrajectoryFiltersEvent,
          GeneralUserTrajectoryFiltersState
        > {
  GeneralUserTrajectoryFiltersBloc()
    : super(const GeneralUserTrajectoryFiltersState.initial()) {
    on<LoadGeneralUserTrajectoryFilters>(_onLoadGeneralUserTrajectoryFilters);
    on<ToggleGpsCoordinatesFilter>(_onToggleGpsCoordinatesFilter);
    on<ToggleTimestampsFilter>(_onToggleTimestampsFilter);
    on<ToggleBatteryLogsFilter>(_onToggleBatteryLogsFilter);
    on<ZoomInGeneralUserTrajectoryFilters>(
      _onZoomInGeneralUserTrajectoryFilters,
    );
    on<ZoomOutGeneralUserTrajectoryFilters>(
      _onZoomOutGeneralUserTrajectoryFilters,
    );
  }

  Future<void> _onLoadGeneralUserTrajectoryFilters(
    LoadGeneralUserTrajectoryFilters event,
    Emitter<GeneralUserTrajectoryFiltersState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserTrajectoryFilters event triggered');
    emit(
      state.copyWith(
        status: GeneralUserTrajectoryFiltersStatus.loading,
        message: '',
      ),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      emit(
        state.copyWith(
          status: GeneralUserTrajectoryFiltersStatus.loaded,
          buoyId: event.buoyId,
          trajectoryPoints: _dummyTrajectoryPoints(),
        ),
      );
      AppLogger.i('LoadGeneralUserTrajectoryFilters success');
    } catch (error, stackTrace) {
      AppLogger.e(
        'LoadGeneralUserTrajectoryFilters failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: GeneralUserTrajectoryFiltersStatus.error,
          message: 'Unable to load trajectory filters.',
        ),
      );
    }
  }

  void _onToggleGpsCoordinatesFilter(
    ToggleGpsCoordinatesFilter event,
    Emitter<GeneralUserTrajectoryFiltersState> emit,
  ) {
    emit(state.copyWith(gpsCoordinatesEnabled: !state.gpsCoordinatesEnabled));
  }

  void _onToggleTimestampsFilter(
    ToggleTimestampsFilter event,
    Emitter<GeneralUserTrajectoryFiltersState> emit,
  ) {
    emit(state.copyWith(timestampsEnabled: !state.timestampsEnabled));
  }

  void _onToggleBatteryLogsFilter(
    ToggleBatteryLogsFilter event,
    Emitter<GeneralUserTrajectoryFiltersState> emit,
  ) {
    emit(state.copyWith(batteryLogsEnabled: !state.batteryLogsEnabled));
  }

  void _onZoomInGeneralUserTrajectoryFilters(
    ZoomInGeneralUserTrajectoryFilters event,
    Emitter<GeneralUserTrajectoryFiltersState> emit,
  ) {
    if (!state.canZoomIn) {
      return;
    }

    emit(state.copyWith(zoom: (state.zoom + 0.7).clamp(3, 17).toDouble()));
  }

  void _onZoomOutGeneralUserTrajectoryFilters(
    ZoomOutGeneralUserTrajectoryFilters event,
    Emitter<GeneralUserTrajectoryFiltersState> emit,
  ) {
    if (!state.canZoomOut) {
      return;
    }

    emit(state.copyWith(zoom: (state.zoom - 0.7).clamp(3, 17).toDouble()));
  }

  List<TrajectoryBuoyPoint> _dummyTrajectoryPoints() {
    return const [
      TrajectoryBuoyPoint(
        position: LatLng(37.812, -122.430),
        status: BuoyStatus.active,
        label: '10:00 am',
        secondaryLabel: '10:00 GMT',
      ),
      TrajectoryBuoyPoint(
        position: LatLng(37.772, -122.409),
        status: BuoyStatus.active,
        label: '12:00 pm',
        secondaryLabel: '12:00 GMT',
      ),
      TrajectoryBuoyPoint(
        position: LatLng(37.744, -122.396),
        status: BuoyStatus.batteryLow,
        label: '3:00 pm',
        secondaryLabel: '15:00 GMT',
      ),
      TrajectoryBuoyPoint(
        position: LatLng(37.734, -122.368),
        status: BuoyStatus.active,
        label: '05:00 pm',
        secondaryLabel: '17:00 GMT',
      ),
      TrajectoryBuoyPoint(
        position: LatLng(37.728, -122.344),
        status: BuoyStatus.active,
        label: '09:30 pm',
        secondaryLabel: '21:30 GMT',
      ),
    ];
  }
}
