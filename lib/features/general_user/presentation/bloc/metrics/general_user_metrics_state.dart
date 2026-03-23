import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_event.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserMetricsStatus { initial, loading, loaded, error }

class GeneralUserMetricsState extends Equatable {
  final GeneralUserMetricsStatus status;
  final String buoyId;
  final GeneralUserMetricsDateRange dateRange;
  final String batteryVoltage;
  final List<double> batteryPoints;
  final List<String> xAxisLabels;
  final String message;

  const GeneralUserMetricsState({
    required this.status,
    required this.buoyId,
    required this.dateRange,
    required this.batteryVoltage,
    required this.batteryPoints,
    required this.xAxisLabels,
    required this.message,
  });

  const GeneralUserMetricsState.initial()
    : status = GeneralUserMetricsStatus.initial,
      buoyId = 'DB-01',
      dateRange = GeneralUserMetricsDateRange.last24Hours,
      batteryVoltage = '',
      batteryPoints = const [],
      xAxisLabels = const [
        '11:00',
        '12:00',
        '13:00',
        '14:00',
        '15:00',
        '16:00',
      ],
      message = '';

  GeneralUserMetricsState copyWith({
    GeneralUserMetricsStatus? status,
    String? buoyId,
    GeneralUserMetricsDateRange? dateRange,
    String? batteryVoltage,
    List<double>? batteryPoints,
    List<String>? xAxisLabels,
    String? message,
  }) {
    return GeneralUserMetricsState(
      status: status ?? this.status,
      buoyId: buoyId ?? this.buoyId,
      dateRange: dateRange ?? this.dateRange,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      batteryPoints: batteryPoints ?? this.batteryPoints,
      xAxisLabels: xAxisLabels ?? this.xAxisLabels,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [
    status,
    buoyId,
    dateRange,
    batteryVoltage,
    batteryPoints,
    xAxisLabels,
    message,
  ];
}
