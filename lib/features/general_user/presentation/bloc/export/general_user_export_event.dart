import 'package:equatable/equatable.dart';

enum ExportDateRange { last24Hours, last7Days, last30Days, custom }
enum ExportFormat { csv, pdf }

abstract class GeneralUserExportEvent extends Equatable {
  const GeneralUserExportEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserExport extends GeneralUserExportEvent {
  final int selectedBuoyCount;

  const LoadGeneralUserExport({this.selectedBuoyCount = 0});

  @override
  List<Object> get props => [selectedBuoyCount];
}

class ChangeGeneralUserExportDateRange extends GeneralUserExportEvent {
  final ExportDateRange dateRange;

  const ChangeGeneralUserExportDateRange(this.dateRange);

  @override
  List<Object> get props => [dateRange];
}

class ChangeGeneralUserExportFormat extends GeneralUserExportEvent {
  final ExportFormat format;

  const ChangeGeneralUserExportFormat(this.format);

  @override
  List<Object> get props => [format];
}

class SubmitGeneralUserExport extends GeneralUserExportEvent {
  const SubmitGeneralUserExport();
}

class ClearGeneralUserExportMessage extends GeneralUserExportEvent {
  const ClearGeneralUserExportMessage();
}
