import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_event.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserExportStatus { initial, loading, loaded, error, exporting }

class GeneralUserExportState extends Equatable {
  final GeneralUserExportStatus status;
  final int selectedBuoyCount;
  final ExportDateRange dateRange;
  final ExportFormat format;
  final String message;
  final bool isSuccessMessage;

  const GeneralUserExportState({
    required this.status,
    required this.selectedBuoyCount,
    required this.dateRange,
    required this.format,
    required this.message,
    required this.isSuccessMessage,
  });

  const GeneralUserExportState.initial()
    : status = GeneralUserExportStatus.initial,
      selectedBuoyCount = 0,
      dateRange = ExportDateRange.last24Hours,
      format = ExportFormat.csv,
      message = '',
      isSuccessMessage = false;

  GeneralUserExportState copyWith({
    GeneralUserExportStatus? status,
    int? selectedBuoyCount,
    ExportDateRange? dateRange,
    ExportFormat? format,
    String? message,
    bool? isSuccessMessage,
  }) {
    return GeneralUserExportState(
      status: status ?? this.status,
      selectedBuoyCount: selectedBuoyCount ?? this.selectedBuoyCount,
      dateRange: dateRange ?? this.dateRange,
      format: format ?? this.format,
      message: message ?? this.message,
      isSuccessMessage: isSuccessMessage ?? this.isSuccessMessage,
    );
  }

  @override
  List<Object> get props => [
    status,
    selectedBuoyCount,
    dateRange,
    format,
    message,
    isSuccessMessage,
  ];
}
