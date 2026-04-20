import 'package:equatable/equatable.dart';

enum ExportDateRange { last24Hours, yesterday,  custom }

enum ExportFormat { csv, pdf }
enum ExportReportType { buoyData, buoyDistance }

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

class ChangeGeneralUserExportReportType extends GeneralUserExportEvent {
  const ChangeGeneralUserExportReportType(this.reportType);

  final ExportReportType reportType;

  @override
  List<Object?> get props => [reportType];
}

class ExportMultiBuoyDataSaveToDevice extends GeneralUserExportEvent {
  const ExportMultiBuoyDataSaveToDevice();
}

class ExportMultiBuoyDataShare extends GeneralUserExportEvent {
  const ExportMultiBuoyDataShare();
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
