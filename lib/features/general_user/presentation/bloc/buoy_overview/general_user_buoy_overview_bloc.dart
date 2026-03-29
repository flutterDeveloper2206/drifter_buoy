import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/format_buoy_last_update_time.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_buoy_data_overview_response.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_data_overview.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class GeneralUserBuoyOverviewBloc
    extends Bloc<GeneralUserBuoyOverviewEvent, GeneralUserBuoyOverviewState> {
  GeneralUserBuoyOverviewBloc({required GeneralUserGetBuoyDataOverview getBuoyDataOverview})
    : _getBuoyDataOverview = getBuoyDataOverview,
      super(const GeneralUserBuoyOverviewInitial()) {
    on<LoadGeneralUserBuoyOverview>(_onLoadGeneralUserBuoyOverview);
    on<ChangeGeneralUserBuoyOverviewTab>(_onChangeGeneralUserBuoyOverviewTab);
    on<ExportGeneralUserBuoyData>(_onExportGeneralUserBuoyData);
    on<ClearGeneralUserBuoyOverviewMessage>(
      _onClearGeneralUserBuoyOverviewMessage,
    );
  }

  final GeneralUserGetBuoyDataOverview _getBuoyDataOverview;

  Future<void> _onLoadGeneralUserBuoyOverview(
    LoadGeneralUserBuoyOverview event,
    Emitter<GeneralUserBuoyOverviewState> emit,
  ) async {
    final buoyId = event.buoyId.trim();
    if (buoyId.isEmpty) {
      emit(
        const GeneralUserBuoyOverviewError(
          message: 'Missing buoy id.',
          buoyId: '',
        ),
      );
      return;
    }

    AppLogger.i('LoadGeneralUserBuoyOverview buoyId=$buoyId');
    emit(GeneralUserBuoyOverviewLoading(buoyId: buoyId));

    final outcome = await _getBuoyDataOverview(buoyId);
    outcome.fold(
      (failure) {
        AppLogger.w('LoadGeneralUserBuoyOverview failed: ${failure.message}');
        emit(
          GeneralUserBuoyOverviewError(
            message: failure.message,
            buoyId: buoyId,
          ),
        );
      },
      (response) {
        try {
          final data = _mapResponseToUi(response, buoyId);
          emit(
            GeneralUserBuoyOverviewLoaded(
              data: data,
              selectedTab: GeneralUserBuoyOverviewTab.overview,
            ),
          );
          AppLogger.i('LoadGeneralUserBuoyOverview success');
        } catch (error, stackTrace) {
          AppLogger.e(
            'LoadGeneralUserBuoyOverview parse/map failed',
            error: error,
            stackTrace: stackTrace,
          );
          emit(
            GeneralUserBuoyOverviewError(
              message: 'Unable to read buoy overview data.',
              buoyId: buoyId,
            ),
          );
        }
      },
    );
  }

  void _onChangeGeneralUserBuoyOverviewTab(
    ChangeGeneralUserBuoyOverviewTab event,
    Emitter<GeneralUserBuoyOverviewState> emit,
  ) {
    final current = state;
    if (current is! GeneralUserBuoyOverviewLoaded) {
      return;
    }
    emit(current.copyWith(selectedTab: event.tab));
  }

  void _onExportGeneralUserBuoyData(
    ExportGeneralUserBuoyData event,
    Emitter<GeneralUserBuoyOverviewState> emit,
  ) {
    final current = state;
    if (current is! GeneralUserBuoyOverviewLoaded) {
      return;
    }

    emit(
      current.copyWith(
        message: 'Dummy export completed for ${current.data.id}.',
        isSuccessMessage: true,
      ),
    );
  }

  void _onClearGeneralUserBuoyOverviewMessage(
    ClearGeneralUserBuoyOverviewMessage event,
    Emitter<GeneralUserBuoyOverviewState> emit,
  ) {
    final current = state;
    if (current is! GeneralUserBuoyOverviewLoaded) {
      return;
    }
    emit(current.copyWith(message: '', isSuccessMessage: false));
  }

  GeneralUserBuoyOverviewData _mapResponseToUi(
    UserViewBuoyDashboardGetBuoyDataOverviewResponse response,
    String requestedBuoyId,
  ) {
    final result = response.result;
    if (result == null) {
      throw StateError('Empty result');
    }

    final overview = result.buoyOverview.isNotEmpty
        ? result.buoyOverview.first
        : null;
    final metrics = result.metrics.isNotEmpty ? result.metrics.first : null;
    final traj = result.trajectory.isNotEmpty ? result.trajectory.first : null;

    final apiOverviewId = (overview?.buoyId ?? '').trim();
    final req = requestedBuoyId.trim();
    // Prefer the id used to open this screen so JSON numeric ids (1) do not
    // replace zero-padded ids (01) for downstream API calls.
    final id = req.isNotEmpty ? req : apiOverviewId;

    final statusLower = (overview?.buoyStatus ?? '').toLowerCase().trim();
    final isActive = statusLower == 'online' || statusLower == 'active';

    final lastUpdateRaw = (overview?.lastUpdate ?? '').trim();
    final lastUpdate = lastUpdateRaw.isNotEmpty
        ? formatBuoyLastUpdateTime(lastUpdateRaw)
        : '—';

    final batteryVoltage = metrics != null
        ? '${metrics.batteryVoltage} V'
        : '—';

    double? displayLat;
    double? displayLon;
    if (metrics != null) {
      displayLat = metrics.latitude;
      displayLon = metrics.longitude;
    }
    if (traj != null &&
        (displayLat == null ||
            displayLon == null ||
            (displayLat == 0 && displayLon == 0))) {
      displayLat = traj.firstLatitude;
      displayLon = traj.firstLongitude;
    }

    final gpsLatitude =
        displayLat != null ? displayLat.toStringAsFixed(5) : '—';
    final gpsLongitude =
        displayLon != null ? displayLon.toStringAsFixed(5) : '—';

    final signalStrength = (metrics?.signalStrength ?? '').trim().isNotEmpty
        ? metrics!.signalStrength.trim()
        : '—';

    final batteryLowRaw = (metrics?.isBatteryLow ?? '').toLowerCase().trim();
    final isBatteryLow =
        batteryLowRaw == 'yes' || batteryLowRaw == 'true' || batteryLowRaw == '1';

    final trajectoryPoints = _buildTrajectoryPoints(
      metrics: metrics,
      traj: traj,
    );

    return GeneralUserBuoyOverviewData(
      id: id,
      isActive: isActive,
      lastUpdate: lastUpdate,
      batteryVoltage: batteryVoltage,
      gpsLatitude: gpsLatitude,
      gpsLongitude: gpsLongitude,
      signalStrength: signalStrength,
      isBatteryLow: isBatteryLow,
      trajectoryPoints: trajectoryPoints,
    );
  }

  List<LatLng> _buildTrajectoryPoints({
    BuoyDataOverviewMetricsRow? metrics,
    BuoyDataOverviewTrajectoryRow? traj,
  }) {
    if (traj != null) {
      final a = LatLng(traj.firstLatitude, traj.firstLongitude);
      final b = LatLng(traj.lastLatitude, traj.lastLongitude);
      if (a.latitude == b.latitude && a.longitude == b.longitude) {
        return [a];
      }
      return [a, b];
    }

    if (metrics != null &&
        metrics.latitude != 0 &&
        metrics.longitude != 0) {
      return [LatLng(metrics.latitude, metrics.longitude)];
    }

    return const [];
  }
}
