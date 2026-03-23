import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map/general_user_map_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map/general_user_map_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserMapBloc
    extends Bloc<GeneralUserMapEvent, GeneralUserMapState> {
  GeneralUserMapBloc() : super(const GeneralUserMapState.initial()) {
    on<LoadGeneralUserMap>(_onLoadGeneralUserMap);
    on<ToggleGeneralUserMapPanel>(_onToggleGeneralUserMapPanel);
    on<ToggleBuoyStatusFilter>(_onToggleBuoyStatusFilter);
    on<ResetBuoyFilters>(_onResetBuoyFilters);
    on<ZoomInMap>(_onZoomInMap);
    on<ZoomOutMap>(_onZoomOutMap);
  }

  Future<void> _onLoadGeneralUserMap(
    LoadGeneralUserMap event,
    Emitter<GeneralUserMapState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserMap event triggered');
    emit(state.copyWith(status: GeneralUserMapStatus.loading, message: ''));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      emit(
        state.copyWith(
          status: GeneralUserMapStatus.loaded,
          buoys: DummyBuoyMapView.defaultBuoys,
        ),
      );
      AppLogger.i(
        'LoadGeneralUserMap success: ${DummyBuoyMapView.defaultBuoys.length} buoys',
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'LoadGeneralUserMap failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: GeneralUserMapStatus.error,
          message: 'Unable to load map right now. Please try again.',
        ),
      );
    }
  }

  void _onToggleGeneralUserMapPanel(
    ToggleGeneralUserMapPanel event,
    Emitter<GeneralUserMapState> emit,
  ) {
    emit(state.copyWith(isFilterPanelExpanded: !state.isFilterPanelExpanded));
  }

  void _onToggleBuoyStatusFilter(
    ToggleBuoyStatusFilter event,
    Emitter<GeneralUserMapState> emit,
  ) {
    switch (event.status) {
      case BuoyStatus.active:
        emit(state.copyWith(showActive: !state.showActive));
        return;
      case BuoyStatus.offline:
        emit(state.copyWith(showOffline: !state.showOffline));
        return;
      case BuoyStatus.batteryLow:
        emit(state.copyWith(showBatteryLow: !state.showBatteryLow));
        return;
    }
  }

  void _onResetBuoyFilters(
    ResetBuoyFilters event,
    Emitter<GeneralUserMapState> emit,
  ) {
    emit(
      state.copyWith(showActive: true, showOffline: true, showBatteryLow: true),
    );
  }

  void _onZoomInMap(ZoomInMap event, Emitter<GeneralUserMapState> emit) {
    if (!state.canZoomIn) {
      return;
    }

    emit(state.copyWith(zoom: (state.zoom + 0.7).clamp(3, 17).toDouble()));
  }

  void _onZoomOutMap(ZoomOutMap event, Emitter<GeneralUserMapState> emit) {
    if (!state.canZoomOut) {
      return;
    }

    emit(state.copyWith(zoom: (state.zoom - 0.7).clamp(3, 17).toDouble()));
  }
}
