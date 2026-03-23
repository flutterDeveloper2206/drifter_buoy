import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserMetricsBloc
    extends Bloc<GeneralUserMetricsEvent, GeneralUserMetricsState> {
  GeneralUserMetricsBloc() : super(const GeneralUserMetricsState.initial()) {
    on<LoadGeneralUserMetrics>(_onLoadGeneralUserMetrics);
    on<ChangeGeneralUserMetricsDateRange>(_onChangeGeneralUserMetricsDateRange);
  }

  Future<void> _onLoadGeneralUserMetrics(
    LoadGeneralUserMetrics event,
    Emitter<GeneralUserMetricsState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserMetrics event triggered');
    emit(
      state.copyWith(
        status: GeneralUserMetricsStatus.loading,
        buoyId: _normalizeBuoyId(event.buoyId),
        message: '',
      ),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      final chartData = _chartDataForRange(state.dateRange);
      emit(
        state.copyWith(
          status: GeneralUserMetricsStatus.loaded,
          batteryVoltage: chartData.$1,
          batteryPoints: chartData.$2,
          xAxisLabels: chartData.$3,
        ),
      );
      AppLogger.i('LoadGeneralUserMetrics success');
    } catch (error, stackTrace) {
      AppLogger.e(
        'LoadGeneralUserMetrics failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: GeneralUserMetricsStatus.error,
          message: 'Unable to load metrics data. Please try again.',
        ),
      );
    }
  }

  void _onChangeGeneralUserMetricsDateRange(
    ChangeGeneralUserMetricsDateRange event,
    Emitter<GeneralUserMetricsState> emit,
  ) {
    final chartData = _chartDataForRange(event.dateRange);
    emit(
      state.copyWith(
        dateRange: event.dateRange,
        batteryVoltage: chartData.$1,
        batteryPoints: chartData.$2,
        xAxisLabels: chartData.$3,
        message: '',
      ),
    );
  }

  (String, List<double>, List<String>) _chartDataForRange(
    GeneralUserMetricsDateRange range,
  ) {
    switch (range) {
      case GeneralUserMetricsDateRange.last24Hours:
        return (
          '11.8 v',
          const [
            11.02,
            11.03,
            11.01,
            11.04,
            11.00,
            11.03,
            11.08,
            11.14,
            11.12,
            11.19,
            11.31,
            11.39,
            11.28,
            11.22,
            11.35,
            11.36,
            11.63,
            11.88,
            11.72,
            11.66,
            11.58,
            11.53,
            11.45,
            11.40,
            11.35,
            11.20,
            11.24,
            11.08,
            11.02,
            11.30,
            11.18,
            11.16,
            11.17,
            11.13,
          ],
          const ['11:00', '12:00', '13:00', '14:00', '15:00', '16:00'],
        );
      case GeneralUserMetricsDateRange.last7Days:
        return (
          '11.6 v',
          const [11.7, 11.5, 11.6, 11.8, 11.7, 11.4, 11.6],
          const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        );
      case GeneralUserMetricsDateRange.last30Days:
        return (
          '11.5 v',
          const [11.4, 11.6, 11.5, 11.3, 11.4, 11.7, 11.5, 11.6, 11.5, 11.4],
          const ['W1', 'W2', 'W3', 'W4', 'W5'],
        );
      case GeneralUserMetricsDateRange.custom:
        return (
          '11.7 v',
          const [11.3, 11.6, 11.4, 11.8, 11.7, 11.5, 11.7, 11.6],
          const ['S1', 'S2', 'S3', 'S4', 'S5'],
        );
    }
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
