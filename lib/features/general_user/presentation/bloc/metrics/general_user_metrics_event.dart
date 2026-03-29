import 'package:equatable/equatable.dart';

enum GeneralUserMetricsDateRange { last24Hours, last7Days, last30Days, custom }

abstract class GeneralUserMetricsEvent extends Equatable {
  const GeneralUserMetricsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserMetrics extends GeneralUserMetricsEvent {
  final String buoyId;

  const LoadGeneralUserMetrics({this.buoyId = 'DB-01'});

  @override
  List<Object> get props => [buoyId];
}

class ChangeGeneralUserMetricsDateRange extends GeneralUserMetricsEvent {
  final GeneralUserMetricsDateRange dateRange;

  const ChangeGeneralUserMetricsDateRange(this.dateRange);

  @override
  List<Object> get props => [dateRange];
}

class ApplyGeneralUserMetricsCustomRange extends GeneralUserMetricsEvent {
  const ApplyGeneralUserMetricsCustomRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  @override
  List<Object> get props => [start, end];
}
