import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_trajectory_view.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_view/general_user_trajectory_view_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_view/general_user_trajectory_view_mapper.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_view/general_user_trajectory_view_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserTrajectoryViewBloc
    extends
        Bloc<GeneralUserTrajectoryViewEvent, GeneralUserTrajectoryViewState> {
  GeneralUserTrajectoryViewBloc({
    required GeneralUserGetBuoyTrajectoryView getBuoyTrajectoryView,
  }) : _getBuoyTrajectoryView = getBuoyTrajectoryView,
       super(const GeneralUserTrajectoryViewState.initial()) {
    on<LoadGeneralUserTrajectoryView>(_onLoadGeneralUserTrajectoryView);
    on<ZoomInGeneralUserTrajectoryView>(_onZoomInGeneralUserTrajectoryView);
    on<ZoomOutGeneralUserTrajectoryView>(_onZoomOutGeneralUserTrajectoryView);
  }

  final GeneralUserGetBuoyTrajectoryView _getBuoyTrajectoryView;

  Future<void> _onLoadGeneralUserTrajectoryView(
    LoadGeneralUserTrajectoryView event,
    Emitter<GeneralUserTrajectoryViewState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserTrajectoryView event triggered');
    emit(
      state.copyWith(
        status: GeneralUserTrajectoryViewStatus.loading,
        buoyId: event.buoyId,
        message: '',
      ),
    );

    final (fromDate, toDate) = defaultTrajectoryApiDateRange();
    final result = await _getBuoyTrajectoryView(
      buoyId: event.buoyId,
      fromDate: fromDate,
      toDate: toDate,
    );

    result.fold(
      (failure) {
        AppLogger.w('LoadGeneralUserTrajectoryView failed: ${failure.message}');
        emit(
          state.copyWith(
            status: GeneralUserTrajectoryViewStatus.error,
            trajectoryPoints: const [],
            message: failure.message,
          ),
        );
      },
      (response) {
        final points = mapTrajectoryRowsToPoints(response.result);
        emit(
          state.copyWith(
            status: GeneralUserTrajectoryViewStatus.loaded,
            trajectoryPoints: points,
            message: '',
          ),
        );
        AppLogger.i(
          'LoadGeneralUserTrajectoryView success: ${points.length} points',
        );
      },
    );
  }

  void _onZoomInGeneralUserTrajectoryView(
    ZoomInGeneralUserTrajectoryView event,
    Emitter<GeneralUserTrajectoryViewState> emit,
  ) {
    if (!state.canZoomIn) {
      return;
    }

    emit(state.copyWith(zoom: (state.zoom + 0.7).clamp(3, 21).toDouble()));
  }

  void _onZoomOutGeneralUserTrajectoryView(
    ZoomOutGeneralUserTrajectoryView event,
    Emitter<GeneralUserTrajectoryViewState> emit,
  ) {
    if (!state.canZoomOut) {
      return;
    }

    emit(state.copyWith(zoom: (state.zoom - 0.7).clamp(3, 21).toDouble()));
  }
}
