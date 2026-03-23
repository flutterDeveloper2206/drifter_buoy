import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_buoy_details/general_user_map_buoy_details_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_buoy_details/general_user_map_buoy_details_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserMapBuoyDetailsBloc
    extends
        Bloc<GeneralUserMapBuoyDetailsEvent, GeneralUserMapBuoyDetailsState> {
  GeneralUserMapBuoyDetailsBloc()
    : super(const GeneralUserMapBuoyDetailsState.initial()) {
    on<LoadGeneralUserMapBuoyDetails>(_onLoadGeneralUserMapBuoyDetails);
    on<SelectGeneralUserMapBuoy>(_onSelectGeneralUserMapBuoy);
    on<ZoomInGeneralUserMapBuoy>(_onZoomInGeneralUserMapBuoy);
    on<ZoomOutGeneralUserMapBuoy>(_onZoomOutGeneralUserMapBuoy);
  }

  Future<void> _onLoadGeneralUserMapBuoyDetails(
    LoadGeneralUserMapBuoyDetails event,
    Emitter<GeneralUserMapBuoyDetailsState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserMapBuoyDetails event triggered');
    emit(state.copyWith(status: GeneralUserMapBuoyDetailsStatus.loading));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 220));

      final dummyDetails = _buildDummyBuoyDetails();
      emit(
        state.copyWith(
          status: GeneralUserMapBuoyDetailsStatus.loaded,
          buoyDetails: dummyDetails,
          selectedIndex: 0,
          message: '',
        ),
      );
      AppLogger.i('LoadGeneralUserMapBuoyDetails success');
    } catch (error, stackTrace) {
      AppLogger.e(
        'LoadGeneralUserMapBuoyDetails failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: GeneralUserMapBuoyDetailsStatus.error,
          message: 'Unable to load buoy details. Please try again.',
        ),
      );
    }
  }

  void _onSelectGeneralUserMapBuoy(
    SelectGeneralUserMapBuoy event,
    Emitter<GeneralUserMapBuoyDetailsState> emit,
  ) {
    final index = state.buoys.indexWhere((buoy) => buoy == event.buoy);
    if (index == -1) {
      return;
    }

    emit(state.copyWith(selectedIndex: index));
  }

  void _onZoomInGeneralUserMapBuoy(
    ZoomInGeneralUserMapBuoy event,
    Emitter<GeneralUserMapBuoyDetailsState> emit,
  ) {
    if (!state.canZoomIn) {
      return;
    }

    emit(state.copyWith(zoom: (state.zoom + 0.7).clamp(3, 17).toDouble()));
  }

  void _onZoomOutGeneralUserMapBuoy(
    ZoomOutGeneralUserMapBuoy event,
    Emitter<GeneralUserMapBuoyDetailsState> emit,
  ) {
    if (!state.canZoomOut) {
      return;
    }

    emit(state.copyWith(zoom: (state.zoom - 0.7).clamp(3, 17).toDouble()));
  }

  List<GeneralUserBuoyDetail> _buildDummyBuoyDetails() {
    final base = DummyBuoyMapView.defaultBuoys;
    const lastUpdates = [
      '09:20 AM',
      '09:18 AM',
      '09:15 AM',
      '09:12 AM',
      '09:10 AM',
      '09:07 AM',
      '09:04 AM',
      '09:01 AM',
    ];
    const batteryValues = [
      '11.8 v',
      '12.1 v',
      '11.9 v',
      '11.2 v',
      '10.9 v',
      '12.0 v',
      '11.7 v',
      '11.6 v',
    ];
    const gpsValues = [
      '15°40\'51.0"N',
      '15°40\'45.2"N',
      '15°40\'39.8"N',
      '15°40\'29.9"N',
      '15°40\'23.0"N',
      '15°40\'12.4"N',
      '15°40\'05.7"N',
      '15°39\'59.3"N',
    ];
    const signalValues = [
      '79%',
      '83%',
      '75%',
      '68%',
      '61%',
      '80%',
      '77%',
      '74%',
    ];

    return List<GeneralUserBuoyDetail>.generate(base.length, (index) {
      final buoy = base[index];
      final statusLabel = switch (buoy.status) {
        BuoyStatus.active => 'Active',
        BuoyStatus.offline => 'Offline',
        BuoyStatus.batteryLow => 'Battery Low',
      };

      return GeneralUserBuoyDetail(
        buoy: buoy,
        lastUpdate: lastUpdates[index % lastUpdates.length],
        batteryVoltage: batteryValues[index % batteryValues.length],
        gpsValue: gpsValues[index % gpsValues.length],
        signalValue: signalValues[index % signalValues.length],
        statusLabel: statusLabel,
      );
    });
  }
}
