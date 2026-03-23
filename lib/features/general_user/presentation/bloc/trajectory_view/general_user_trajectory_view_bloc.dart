import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_view/general_user_trajectory_view_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_view/general_user_trajectory_view_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_trajectory_live_map_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class GeneralUserTrajectoryViewBloc
    extends
        Bloc<GeneralUserTrajectoryViewEvent, GeneralUserTrajectoryViewState> {
  GeneralUserTrajectoryViewBloc()
    : super(const GeneralUserTrajectoryViewState.initial()) {
    on<LoadGeneralUserTrajectoryView>(_onLoadGeneralUserTrajectoryView);
    on<ZoomInGeneralUserTrajectoryView>(_onZoomInGeneralUserTrajectoryView);
    on<ZoomOutGeneralUserTrajectoryView>(_onZoomOutGeneralUserTrajectoryView);
  }

  Future<void> _onLoadGeneralUserTrajectoryView(
    LoadGeneralUserTrajectoryView event,
    Emitter<GeneralUserTrajectoryViewState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserTrajectoryView event triggered');
    emit(
      state.copyWith(
        status: GeneralUserTrajectoryViewStatus.loading,
        message: '',
      ),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      emit(
        state.copyWith(
          status: GeneralUserTrajectoryViewStatus.loaded,
          buoyId: event.buoyId,
          trajectoryPoints: _dummyTrajectoryPoints(),
        ),
      );
      AppLogger.i('LoadGeneralUserTrajectoryView success');
    } catch (error, stackTrace) {
      AppLogger.e(
        'LoadGeneralUserTrajectoryView failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: GeneralUserTrajectoryViewStatus.error,
          message: 'Unable to load trajectory view.',
        ),
      );
    }
  }

  void _onZoomInGeneralUserTrajectoryView(
    ZoomInGeneralUserTrajectoryView event,
    Emitter<GeneralUserTrajectoryViewState> emit,
  ) {
    if (!state.canZoomIn) {
      return;
    }

    emit(state.copyWith(zoom: (state.zoom + 0.7).clamp(3, 17).toDouble()));
  }

  void _onZoomOutGeneralUserTrajectoryView(
    ZoomOutGeneralUserTrajectoryView event,
    Emitter<GeneralUserTrajectoryViewState> emit,
  ) {
    if (!state.canZoomOut) {
      return;
    }

    emit(state.copyWith(zoom: (state.zoom - 0.7).clamp(3, 17).toDouble()));
  }

  List<TrajectoryBuoyPoint> _dummyTrajectoryPoints() {
    return const [
      TrajectoryBuoyPoint(
        position: LatLng(37.809, -122.429),
        status: BuoyStatus.active,
        label: '10:20 GMT/',
        secondaryLabel: '03:39 IST',
      ),
      TrajectoryBuoyPoint(
        position: LatLng(37.774, -122.415),
        status: BuoyStatus.active,
        label: '10:20 GMT/',
        secondaryLabel: '03:39 IST',
      ),
      TrajectoryBuoyPoint(
        position: LatLng(37.746, -122.401),
        status: BuoyStatus.active,
        label: '10:20 GMT/',
        secondaryLabel: '03:39 IST',
      ),
      TrajectoryBuoyPoint(
        position: LatLng(37.734, -122.372),
        status: BuoyStatus.active,
        label: '10:20 GMT/',
        secondaryLabel: '03:39 IST',
      ),
      TrajectoryBuoyPoint(
        position: LatLng(37.729, -122.347),
        status: BuoyStatus.active,
        label: '10:20 GMT/',
        secondaryLabel: '03:39 IST',
      ),
    ];
  }
}
