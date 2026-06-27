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
    required this.reportType,
    required this.distanceStartPointType,
    required this.startLatitude,
    required this.startLongitude,
    required this.startTime,
    required this.distanceStartPointSubmitted,
    required this.format,
    required this.message,
    required this.isSuccessMessage,
    required this.reportColumns,
    required this.reportRows,
    required this.reportDataSourceKey,
    required this.isReportLoading,
    required this.isStartPointSearching,
    required this.deliverable,
    required this.buoyScreenNotice,
  });

  final GeneralUserExportStatus status;
  final GeneralUserExportMode mode;
  final Object? routeExtraSnapshot;
  final int selectedBuoyCount;
  final List<String> selectedBuoyIds;
  final String? buoyId;
  final ExportDateRange? dateRange;
  final DateTime? customStart;
  final DateTime? customEnd;
  final ExportReportType? reportType;
  final ExportDistanceStartPointType? distanceStartPointType;
  final String startLatitude;
  final String startLongitude;
  final String startTime;
  final bool distanceStartPointSubmitted;
  final ExportFormat? format;
  final String message;
  final bool isSuccessMessage;
  final List<String> reportColumns;
  final List<Map<String, String>> reportRows;
  /// Present when [reportRows] were loaded for this exact API request key.
  /// Used to skip a duplicate network call on export when the preview data
  /// is still valid.
  final String? reportDataSourceKey;
  final bool isReportLoading;
  final bool isStartPointSearching;
  final GeneralUserExportDeliverable? deliverable;

  /// Inline text for buoy-distance flow (e.g. empty report or API error). Not used for flushbars.
  final String buoyScreenNotice;

  static const multiBuoyDistanceReportError =
      'Select one buoy for Distance Report.';

  /// Multi-buoy export allows only one buoy for distance reports.
  bool get isMultiBuoyDistanceReportBlocked {
    return mode == GeneralUserExportMode.multiSelection &&
        reportType == ExportReportType.buoyDistance &&
        selectedBuoyIds.length != 1;
  }

  /// True when Buoy Distance Report has a required start point configured.
  bool get isDistanceStartPointComplete {
    if (reportType != ExportReportType.buoyDistance) {
      return false;
    }
    final type = distanceStartPointType;
    if (type == null) {
      return false;
    }
    switch (type) {
      case ExportDistanceStartPointType.latLng:
        return startLatitude.trim().isNotEmpty &&
            startLongitude.trim().isNotEmpty;
      case ExportDistanceStartPointType.time:
        return startTime.trim().isNotEmpty;
    }
  }

  /// Buoy Data Report needs no start point; distance report needs Submit.
  bool get isDistanceStartPointReadyForExport {
    if (reportType == ExportReportType.buoyData) {
      return true;
    }
    if (reportType != ExportReportType.buoyDistance) {
      return false;
    }
    if (isMultiBuoyDistanceReportBlocked) {
      return false;
    }
    return distanceStartPointSubmitted;
  }

  const GeneralUserExportState.initial()
    : status = GeneralUserExportStatus.initial,
      mode = GeneralUserExportMode.multiSelection,
      routeExtraSnapshot = null,
      selectedBuoyCount = 0,
      selectedBuoyIds = const [],
      buoyId = null,
      dateRange = null,
      customStart = null,
      customEnd = null,
      reportType = null,
      distanceStartPointType = null,
      startLatitude = '',
      startLongitude = '',
      startTime = '',
      distanceStartPointSubmitted = false,
      format = null,
      message = '',
      isSuccessMessage = false,
      reportColumns = const [],
      reportRows = const [],
      reportDataSourceKey = null,
      isReportLoading = false,
      isStartPointSearching = false,
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
    bool assignDateRange = false,
    DateTime? customStart,
    DateTime? customEnd,
    bool clearCustomRange = false,
    ExportReportType? reportType,
    bool assignReportType = false,
    ExportDistanceStartPointType? distanceStartPointType,
    bool assignDistanceStartPointType = false,
    bool clearDistanceStartPoint = false,
    String? startLatitude,
    String? startLongitude,
    String? startTime,
    bool? distanceStartPointSubmitted,
    ExportFormat? format,
    bool assignFormat = false,
    String? message,
    bool? isSuccessMessage,
    List<String>? reportColumns,
    List<Map<String, String>>? reportRows,
    String? reportDataSourceKey,
    bool assignReportDataSourceKey = false,
    bool clearReportDataSourceKey = false,
    bool? isReportLoading,
    bool? isStartPointSearching,
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
      dateRange: assignDateRange ? dateRange : this.dateRange,
      customStart: clearCustomRange ? null : (customStart ?? this.customStart),
      customEnd: clearCustomRange ? null : (customEnd ?? this.customEnd),
      reportType: assignReportType ? reportType : this.reportType,
      distanceStartPointType: clearDistanceStartPoint
          ? null
          : (assignDistanceStartPointType
                ? distanceStartPointType
                : this.distanceStartPointType),
      startLatitude: clearDistanceStartPoint
          ? ''
          : (startLatitude ?? this.startLatitude),
      startLongitude: clearDistanceStartPoint
          ? ''
          : (startLongitude ?? this.startLongitude),
      startTime: clearDistanceStartPoint ? '' : (startTime ?? this.startTime),
      distanceStartPointSubmitted: clearDistanceStartPoint
          ? false
          : (distanceStartPointSubmitted ?? this.distanceStartPointSubmitted),
      format: assignFormat ? format : this.format,
      message: message ?? this.message,
      isSuccessMessage: isSuccessMessage ?? this.isSuccessMessage,
      reportColumns: reportColumns ?? this.reportColumns,
      reportRows: reportRows ?? this.reportRows,
      reportDataSourceKey: clearReportDataSourceKey
          ? null
          : (assignReportDataSourceKey
                ? reportDataSourceKey
                : this.reportDataSourceKey),
      isReportLoading: isReportLoading ?? this.isReportLoading,
      isStartPointSearching:
          isStartPointSearching ?? this.isStartPointSearching,
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
        reportType,
        distanceStartPointType,
        startLatitude,
        startLongitude,
        startTime,
        distanceStartPointSubmitted,
        format,
        message,
        isSuccessMessage,
        reportColumns,
        reportRows,
        reportDataSourceKey,
        isReportLoading,
        isStartPointSearching,
        deliverable,
        buoyScreenNotice,
      ];
}
