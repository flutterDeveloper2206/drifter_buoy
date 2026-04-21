import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/report_export_date_format.dart';
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
       super(GeneralUserTrajectoryViewState.initial()) {
    on<LoadGeneralUserTrajectoryView>(_onLoadGeneralUserTrajectoryView);
    on<SyncGeneralUserTrajectoryMapZoom>(_onSyncGeneralUserTrajectoryMapZoom);
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

    final from = event.fromDate ?? state.fromDate;
    final to = event.toDate ?? state.toDate;
    final interval = event.intervalMinutes ?? state.intervalMinutes;
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
            fromDate: from,
            toDate: to,
            intervalMinutes: interval,
            message: '',
          ),
        );
        AppLogger.i(
          'LoadGeneralUserTrajectoryView success: ${points.length} points',
        );
      },
    );
  }

  void _onSyncGeneralUserTrajectoryMapZoom(
    SyncGeneralUserTrajectoryMapZoom event,
    Emitter<GeneralUserTrajectoryViewState> emit,
  ) {
    emit(state.copyWith(zoom: event.zoom.clamp(3, 21)));
  }
}
