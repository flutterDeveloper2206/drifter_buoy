import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_event.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserMetricsStatus { initial, loading, loaded, error }

class GeneralUserMetricsState extends Equatable {
  final GeneralUserMetricsStatus status;
  final String buoyId;
  final GeneralUserMetricsDateRange dateRange;
  final DateTime? customStart;
  final DateTime? customEnd;
  final String batteryVoltage;
  final List<double> batteryPoints;
  final List<String> xAxisLabels;
  final String message;

  const GeneralUserMetricsState({
    required this.status,
    required this.buoyId,
    required this.dateRange,
    required this.customStart,
    required this.customEnd,
    required this.batteryVoltage,
    required this.batteryPoints,
    required this.xAxisLabels,
    required this.message,
  });

  const GeneralUserMetricsState.initial()
    : status = GeneralUserMetricsStatus.initial,
      buoyId = 'DB-01',
      dateRange = GeneralUserMetricsDateRange.last24Hours,
      customStart = null,
      customEnd = null,
      batteryVoltage = '',
      batteryPoints = const [],
      xAxisLabels = const [],
      message = '';

  GeneralUserMetricsState copyWith({
    GeneralUserMetricsStatus? status,
    String? buoyId,
    GeneralUserMetricsDateRange? dateRange,
    DateTime? customStart,
    DateTime? customEnd,
    bool clearCustomRange = false,
    String? batteryVoltage,
    List<double>? batteryPoints,
    List<String>? xAxisLabels,
    String? message,
  }) {
    return GeneralUserMetricsState(
      status: status ?? this.status,
      buoyId: buoyId ?? this.buoyId,
      dateRange: dateRange ?? this.dateRange,
      customStart: clearCustomRange ? null : (customStart ?? this.customStart),
      customEnd: clearCustomRange ? null : (customEnd ?? this.customEnd),
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      batteryPoints: batteryPoints ?? this.batteryPoints,
      xAxisLabels: xAxisLabels ?? this.xAxisLabels,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    buoyId,
    dateRange,
    customStart,
    customEnd,
    batteryVoltage,
    batteryPoints,
    xAxisLabels,
    message,
  ];
}
