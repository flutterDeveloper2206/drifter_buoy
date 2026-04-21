import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/report_export_date_format.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_trajectory_view.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_filters/general_user_trajectory_filters_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_filters/general_user_trajectory_filters_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_view/general_user_trajectory_view_mapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserTrajectoryFiltersBloc
    extends
        Bloc<
          GeneralUserTrajectoryFiltersEvent,
          GeneralUserTrajectoryFiltersState
        > {
  GeneralUserTrajectoryFiltersBloc({
    required GeneralUserGetBuoyTrajectoryView getBuoyTrajectoryView,
  }) : _getBuoyTrajectoryView = getBuoyTrajectoryView,
       super(const GeneralUserTrajectoryFiltersState.initial()) {
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

  final GeneralUserGetBuoyTrajectoryView _getBuoyTrajectoryView;

  Future<void> _onLoadGeneralUserTrajectoryFilters(
    LoadGeneralUserTrajectoryFilters event,
    Emitter<GeneralUserTrajectoryFiltersState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserTrajectoryFilters event triggered');
    emit(
      state.copyWith(
        status: GeneralUserTrajectoryFiltersStatus.loading,
        buoyId: event.buoyId,
        message: '',
      ),
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = event.fromDate ?? today;
    final to = event.toDate ?? today;
    final interval = event.intervalMinutes ?? 10;
    final fromDate = formatReportApiDate(from);
    final toDate = formatReportApiDate(to);
    final result = await _getBuoyTrajectoryView(
      buoyId: event.buoyId,
      fromDate: fromDate,
      toDate: toDate,
      intervalMinutes: interval,
    );

    result.fold(
      (failure) {
        AppLogger.w(
          'LoadGeneralUserTrajectoryFilters failed: ${failure.message}',
        );
        emit(
          state.copyWith(
            status: GeneralUserTrajectoryFiltersStatus.error,
            trajectoryPoints: const [],
            message: failure.message,
          ),
        );
      },
      (response) {
        final points = mapTrajectoryRowsToPoints(response.result);
        emit(
          state.copyWith(
            status: GeneralUserTrajectoryFiltersStatus.loaded,
            trajectoryPoints: points,
            message: '',
          ),
        );
        AppLogger.i(
          'LoadGeneralUserTrajectoryFilters success: ${points.length} points',
        );
      },
    );
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
}
