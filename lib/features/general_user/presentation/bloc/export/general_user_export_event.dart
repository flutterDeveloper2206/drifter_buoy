import 'package:equatable/equatable.dart';

enum ExportDateRange { last24Hours, yesterday, last7Days, last30Days, custom }

enum ExportFormat { csv, pdf }

abstract class GeneralUserExportEvent extends Equatable {
  const GeneralUserExportEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserExport extends GeneralUserExportEvent {
  const LoadGeneralUserExport({this.routeExtra});

  final Object? routeExtra;

  @override
  List<Object?> get props => [routeExtra];
}

class ChangeGeneralUserExportDateRange extends GeneralUserExportEvent {
  const ChangeGeneralUserExportDateRange(this.dateRange);

  final ExportDateRange dateRange;

  @override
  List<Object?> get props => [dateRange];
}

class ApplyGeneralUserExportCustomRange extends GeneralUserExportEvent {
  const ApplyGeneralUserExportCustomRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => [start, end];
}

class ChangeGeneralUserExportFormat extends GeneralUserExportEvent {
  const ChangeGeneralUserExportFormat(this.format);

  final ExportFormat format;

  @override
  List<Object?> get props => [format];
}

/// Placeholder export for multi-buoy selection flow (no API).
class SubmitGeneralUserExport extends GeneralUserExportEvent {
  const SubmitGeneralUserExport();
}

class ExportBuoyDistanceSaveToDevice extends GeneralUserExportEvent {
  const ExportBuoyDistanceSaveToDevice();
}

class ExportBuoyDistanceShare extends GeneralUserExportEvent {
  const ExportBuoyDistanceShare();
}

class ClearGeneralUserExportDeliverable extends GeneralUserExportEvent {
  const ClearGeneralUserExportDeliverable();
}

class ClearGeneralUserExportMessage extends GeneralUserExportEvent {
  const ClearGeneralUserExportMessage();
}
