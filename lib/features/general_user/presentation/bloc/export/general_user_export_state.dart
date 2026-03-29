import 'dart:typed_data';

import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_event.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserExportMode { multiSelection, buoyDistance }

enum GeneralUserExportStatus { initial, loading, loaded, error, exporting }

/// Set when UI should save to disk (false) or open share sheet (true).
class GeneralUserExportDeliverable {
  GeneralUserExportDeliverable({
    required this.bytes,
    required this.fileName,
    required this.forShare,
  });

  final Uint8List bytes;
  final String fileName;
  final bool forShare;
}

class GeneralUserExportState extends Equatable {
  const GeneralUserExportState({
    required this.status,
    required this.mode,
    required this.routeExtraSnapshot,
    required this.selectedBuoyCount,
    required this.selectedBuoyIds,
    required this.buoyId,
    required this.dateRange,
    required this.customStart,
    required this.customEnd,
    required this.format,
    required this.message,
    required this.isSuccessMessage,
    required this.reportColumns,
    required this.reportRows,
    required this.isReportLoading,
    required this.deliverable,
    required this.buoyScreenNotice,
  });

  final GeneralUserExportStatus status;
  final GeneralUserExportMode mode;
  final Object? routeExtraSnapshot;
  final int selectedBuoyCount;
  final List<String> selectedBuoyIds;
  final String? buoyId;
  final ExportDateRange dateRange;
  final DateTime? customStart;
  final DateTime? customEnd;
  final ExportFormat format;
  final String message;
  final bool isSuccessMessage;
  final List<String> reportColumns;
  final List<Map<String, String>> reportRows;
  final bool isReportLoading;
  final GeneralUserExportDeliverable? deliverable;

  /// Inline text for buoy-distance flow (e.g. empty report or API error). Not used for flushbars.
  final String buoyScreenNotice;

  const GeneralUserExportState.initial()
    : status = GeneralUserExportStatus.initial,
      mode = GeneralUserExportMode.multiSelection,
      routeExtraSnapshot = null,
      selectedBuoyCount = 0,
      selectedBuoyIds = const [],
      buoyId = null,
      dateRange = ExportDateRange.last24Hours,
      customStart = null,
      customEnd = null,
      format = ExportFormat.csv,
      message = '',
      isSuccessMessage = false,
      reportColumns = const [],
      reportRows = const [],
      isReportLoading = false,
      deliverable = null,
      buoyScreenNotice = '';

  GeneralUserExportState copyWith({
    GeneralUserExportStatus? status,
    GeneralUserExportMode? mode,
    Object? routeExtraSnapshot,
    bool assignRouteExtraSnapshot = false,
    int? selectedBuoyCount,
    List<String>? selectedBuoyIds,
    String? buoyId,
    bool clearBuoyId = false,
    ExportDateRange? dateRange,
    DateTime? customStart,
    DateTime? customEnd,
    bool clearCustomRange = false,
    ExportFormat? format,
    String? message,
    bool? isSuccessMessage,
    List<String>? reportColumns,
    List<Map<String, String>>? reportRows,
    bool? isReportLoading,
    GeneralUserExportDeliverable? deliverable,
    bool clearDeliverable = false,
    String? buoyScreenNotice,
    bool assignBuoyScreenNotice = false,
  }) {
    return GeneralUserExportState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      routeExtraSnapshot: assignRouteExtraSnapshot
          ? routeExtraSnapshot
          : this.routeExtraSnapshot,
      selectedBuoyCount: selectedBuoyCount ?? this.selectedBuoyCount,
      selectedBuoyIds: selectedBuoyIds ?? this.selectedBuoyIds,
      buoyId: clearBuoyId ? null : (buoyId ?? this.buoyId),
      dateRange: dateRange ?? this.dateRange,
      customStart: clearCustomRange ? null : (customStart ?? this.customStart),
      customEnd: clearCustomRange ? null : (customEnd ?? this.customEnd),
      format: format ?? this.format,
      message: message ?? this.message,
      isSuccessMessage: isSuccessMessage ?? this.isSuccessMessage,
      reportColumns: reportColumns ?? this.reportColumns,
      reportRows: reportRows ?? this.reportRows,
      isReportLoading: isReportLoading ?? this.isReportLoading,
      deliverable: clearDeliverable ? null : (deliverable ?? this.deliverable),
      buoyScreenNotice: assignBuoyScreenNotice
          ? (buoyScreenNotice ?? '')
          : this.buoyScreenNotice,
    );
  }

  @override
  List<Object?> get props => [
        status,
        mode,
        routeExtraSnapshot,
        selectedBuoyCount,
        selectedBuoyIds,
        buoyId,
        dateRange,
        customStart,
        customEnd,
        format,
        message,
        isSuccessMessage,
        reportColumns,
        reportRows,
        isReportLoading,
        deliverable,
        buoyScreenNotice,
      ];
}
