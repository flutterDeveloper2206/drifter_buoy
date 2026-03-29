import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/report_export_date_format.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_buoy_metrics_response.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_metrics.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserMetricsBloc
    extends Bloc<GeneralUserMetricsEvent, GeneralUserMetricsState> {
  GeneralUserMetricsBloc({required GeneralUserGetBuoyMetrics getBuoyMetrics})
      : _getBuoyMetrics = getBuoyMetrics,
        super(const GeneralUserMetricsState.initial()) {
    on<LoadGeneralUserMetrics>(_onLoadGeneralUserMetrics);
    on<ChangeGeneralUserMetricsDateRange>(_onChangeGeneralUserMetricsDateRange);
    on<ApplyGeneralUserMetricsCustomRange>(_onApplyGeneralUserMetricsCustomRange);
  }

  final GeneralUserGetBuoyMetrics _getBuoyMetrics;

  Future<void> _onLoadGeneralUserMetrics(
    LoadGeneralUserMetrics event,
    Emitter<GeneralUserMetricsState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserMetrics buoyId=${event.buoyId}');
    emit(
      state.copyWith(
        status: GeneralUserMetricsStatus.loading,
        buoyId: _normalizeDisplayBuoyId(event.buoyId),
        message: '',
      ),
    );
    await _fetchAndEmit(emit);
  }

  Future<void> _onChangeGeneralUserMetricsDateRange(
    ChangeGeneralUserMetricsDateRange event,
    Emitter<GeneralUserMetricsState> emit,
  ) async {
    AppLogger.i('ChangeGeneralUserMetricsDateRange ${event.dateRange}');
    final clearCustom = event.dateRange != GeneralUserMetricsDateRange.custom;
    emit(
      state.copyWith(
        status: GeneralUserMetricsStatus.loading,
        dateRange: event.dateRange,
        message: '',
        clearCustomRange: clearCustom,
      ),
    );
    await _fetchAndEmit(emit);
  }

  Future<void> _onApplyGeneralUserMetricsCustomRange(
    ApplyGeneralUserMetricsCustomRange event,
    Emitter<GeneralUserMetricsState> emit,
  ) async {
    final a = startOfDay(
      event.start.isBefore(event.end) ? event.start : event.end,
    );
    final b = startOfDay(
      event.start.isBefore(event.end) ? event.end : event.start,
    );
    emit(
      state.copyWith(
        status: GeneralUserMetricsStatus.loading,
        dateRange: GeneralUserMetricsDateRange.custom,
        customStart: a,
        customEnd: b,
        message: '',
      ),
    );
    await _fetchAndEmit(emit);
  }

  Future<void> _fetchAndEmit(Emitter<GeneralUserMetricsState> emit) async {
    final (fromDate, toDate) = _apiDateStrings(state);

    final result = await _getBuoyMetrics(
      buoyId: state.buoyId.trim(),
      fromDate: fromDate,
      toDate: toDate,
    );

    result.fold(
      (failure) {
        AppLogger.w('GetBuoyMetrics failed: ${failure.message}');
        emit(
          state.copyWith(
            status: GeneralUserMetricsStatus.error,
            message: failure.message,
            batteryVoltage: '',
            batteryPoints: const [],
            xAxisLabels: const [],
          ),
        );
      },
      (response) {
        final chart = _chartFromSamples(response.result);
        emit(
          state.copyWith(
            status: GeneralUserMetricsStatus.loaded,
            batteryVoltage: chart.displayVoltage,
            batteryPoints: chart.points,
            xAxisLabels: chart.labels,
            message: '',
          ),
        );
        AppLogger.i(
          'GetBuoyMetrics success: ${chart.points.length} points',
        );
      },
    );
  }
}

class _ChartFromMetrics {
  const _ChartFromMetrics({
    required this.displayVoltage,
    required this.points,
    required this.labels,
  });

  final String displayVoltage;
  final List<double> points;
  final List<String> labels;
}

_ChartFromMetrics _chartFromSamples(List<BuoyMetricSampleModel> raw) {
  if (raw.isEmpty) {
    return const _ChartFromMetrics(
      displayVoltage: '--',
      points: [],
      labels: [],
    );
  }

  final sorted = List<BuoyMetricSampleModel>.from(raw)
    ..sort((a, b) {
      final ta = _parseMetricsDateTime(a.datetime);
      final tb = _parseMetricsDateTime(b.datetime);
      if (ta == null && tb == null) return 0;
      if (ta == null) return -1;
      if (tb == null) return 1;
      return ta.compareTo(tb);
    });

  final times = <DateTime>[];
  final points = <double>[];
  double? lastGoodVoltage;

  for (final row in sorted) {
    final t = _parseMetricsDateTime(row.datetime);
    if (t == null) continue;
    final v = double.tryParse(row.batteryVoltage.trim());
    times.add(t);
    if (v != null && v >= 0) {
      lastGoodVoltage = v;
      points.add(v);
    } else if (lastGoodVoltage != null) {
      points.add(lastGoodVoltage);
    } else {
      points.add(0);
    }
  }

  if (points.isEmpty || times.isEmpty) {
    return const _ChartFromMetrics(
      displayVoltage: '--',
      points: [],
      labels: [],
    );
  }

  final displayVoltage = '${points.last.toStringAsFixed(1)} v';

  return _ChartFromMetrics(
    displayVoltage: displayVoltage,
    points: points,
    labels: _xAxisLabelsForTimes(times),
  );
}

const _monthShort = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

List<String> _xAxisLabelsForTimes(List<DateTime> times) {
  if (times.isEmpty) return [];

  final n = times.length;
  const target = 6;
  final first = times.first;
  final sameDay = times.every(
    (t) =>
        t.year == first.year && t.month == first.month && t.day == first.day,
  );

  String format(DateTime t) {
    if (sameDay) {
      final h = t.hour.toString().padLeft(2, '0');
      final m = t.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    return '${t.day.toString().padLeft(2, '0')}-${_monthShort[t.month - 1]}';
  }

  if (n <= target) {
    return times.map(format).toList(growable: false);
  }

  return List<String>.generate(target, (j) {
    final i = (j * (n - 1) / (target - 1)).round().clamp(0, n - 1);
    return format(times[i]);
  }, growable: false);
}

DateTime? _parseMetricsDateTime(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final space = s.indexOf(' ');
  if (space <= 0 || space >= s.length - 1) {
    return DateTime.tryParse(s.replaceFirst(' ', 'T'));
  }
  final datePart = s.substring(0, space);
  final timePart = s.substring(space + 1);
  final d = datePart.split('-');
  final t = timePart.split(':');
  if (d.length != 3 || t.length < 2) return null;
  final year = int.tryParse(d[0]);
  final month = int.tryParse(d[1]);
  final day = int.tryParse(d[2]);
  final hour = int.tryParse(t[0]);
  final minute = int.tryParse(t[1]);
  final second = t.length > 2 ? int.tryParse(t[2]) ?? 0 : 0;
  if (year == null ||
      month == null ||
      day == null ||
      hour == null ||
      minute == null) {
    return null;
  }
  return DateTime(year, month, day, hour, minute, second);
}

(String from, String to) _apiDateStrings(GeneralUserMetricsState s) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (s.dateRange == GeneralUserMetricsDateRange.custom &&
      s.customStart != null &&
      s.customEnd != null) {
    final start = s.customStart!.isBefore(s.customEnd!)
        ? s.customStart!
        : s.customEnd!;
    final end = s.customStart!.isBefore(s.customEnd!)
        ? s.customEnd!
        : s.customStart!;
    return (_formatApiDate(start), _formatApiDate(end));
  }
  final start = switch (s.dateRange) {
    GeneralUserMetricsDateRange.last24Hours =>
      today.subtract(const Duration(days: 1)),
    GeneralUserMetricsDateRange.last7Days =>
      today.subtract(const Duration(days: 6)),
    GeneralUserMetricsDateRange.last30Days =>
      today.subtract(const Duration(days: 29)),
    GeneralUserMetricsDateRange.custom =>
      today.subtract(const Duration(days: 29)),
  };
  return (_formatApiDate(start), _formatApiDate(today));
}

String _formatApiDate(DateTime d) {
  return '${d.day.toString().padLeft(2, '0')}-${_monthShort[d.month - 1]}-${d.year}';
}

String _normalizeDisplayBuoyId(String raw) {
  final compact = raw.trim().toUpperCase().replaceAll(' ', '');
  if (compact.isEmpty) {
    return 'DB-01';
  }

  if (compact.contains('-')) {
    return raw.trim();
  }

  if (compact.startsWith('DB') && compact.length > 2) {
    return 'DB-${compact.substring(2)}';
  }

  return raw.trim();
}
