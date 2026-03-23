import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class GeneralUserBuoyOverviewBloc
    extends Bloc<GeneralUserBuoyOverviewEvent, GeneralUserBuoyOverviewState> {
  GeneralUserBuoyOverviewBloc()
    : super(const GeneralUserBuoyOverviewState.initial()) {
    on<LoadGeneralUserBuoyOverview>(_onLoadGeneralUserBuoyOverview);
    on<ChangeGeneralUserBuoyOverviewTab>(_onChangeGeneralUserBuoyOverviewTab);
    on<ExportGeneralUserBuoyData>(_onExportGeneralUserBuoyData);
    on<ClearGeneralUserBuoyOverviewMessage>(
      _onClearGeneralUserBuoyOverviewMessage,
    );
  }

  Future<void> _onLoadGeneralUserBuoyOverview(
    LoadGeneralUserBuoyOverview event,
    Emitter<GeneralUserBuoyOverviewState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserBuoyOverview event triggered');
    emit(
      state.copyWith(
        status: GeneralUserBuoyOverviewStatus.loading,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      emit(
        state.copyWith(
          status: GeneralUserBuoyOverviewStatus.loaded,
          data: _dummyOverviewData(event.buoyId),
        ),
      );
      AppLogger.i('LoadGeneralUserBuoyOverview success');
    } catch (error, stackTrace) {
      AppLogger.e(
        'LoadGeneralUserBuoyOverview failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: GeneralUserBuoyOverviewStatus.error,
          message: 'Unable to load buoy overview.',
          isSuccessMessage: false,
        ),
      );
    }
  }

  void _onChangeGeneralUserBuoyOverviewTab(
    ChangeGeneralUserBuoyOverviewTab event,
    Emitter<GeneralUserBuoyOverviewState> emit,
  ) {
    emit(state.copyWith(selectedTab: event.tab));
  }

  void _onExportGeneralUserBuoyData(
    ExportGeneralUserBuoyData event,
    Emitter<GeneralUserBuoyOverviewState> emit,
  ) {
    final data = state.data;
    if (data == null) {
      return;
    }

    emit(
      state.copyWith(
        message: 'Dummy export completed for ${data.id}.',
        isSuccessMessage: true,
      ),
    );
  }

  void _onClearGeneralUserBuoyOverviewMessage(
    ClearGeneralUserBuoyOverviewMessage event,
    Emitter<GeneralUserBuoyOverviewState> emit,
  ) {
    emit(state.copyWith(message: '', isSuccessMessage: false));
  }

  GeneralUserBuoyOverviewData _dummyOverviewData(String buoyId) {
    final normalizedId = _normalizeBuoyId(buoyId);

    return GeneralUserBuoyOverviewData(
      id: normalizedId,
      isActive: true,
      lastUpdate: '10:20 AM',
      batteryVoltage: '11.8 v',
      gpsLatitude: '15°40\'51.0"N',
      gpsLongitude: '82°31\'11.0"E',
      signalStrength: '10%',
      trajectoryPoints: const [
        LatLng(37.7852, -122.4472),
        LatLng(37.7878, -122.4391),
        LatLng(37.7836, -122.4318),
        LatLng(37.7889, -122.4242),
        LatLng(37.7840, -122.4158),
        LatLng(37.7896, -122.4079),
        LatLng(37.7872, -122.3998),
        LatLng(37.7925, -122.3917),
      ],
    );
  }

  String _normalizeBuoyId(String raw) {
    final compact = raw.trim().toUpperCase().replaceAll(' ', '');
    if (compact.isEmpty) {
      return 'DB-01';
    }

    if (compact.contains('-')) {
      return compact;
    }

    if (compact.startsWith('DB') && compact.length > 2) {
      return 'DB-${compact.substring(2)}';
    }

    return compact;
  }
}
