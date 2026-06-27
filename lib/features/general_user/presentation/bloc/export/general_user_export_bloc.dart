import 'dart:typed_data';

import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/export_report_dynamic_codec.dart';
import 'package:drifter_buoy/core/utils/report_export_date_format.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_report_get_buoy_distance_report_for_export_response.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_data_report_for_export.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_distance_report_for_export.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_search_by_lat_lon.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/navigation/general_user_export_route_extra.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserExportBloc
    extends Bloc<GeneralUserExportEvent, GeneralUserExportState> {
  GeneralUserExportBloc({
    required GeneralUserGetBuoyDistanceReportForExport getBuoyDistanceReport,
    required GeneralUserGetBuoyDataReportForExport getBuoyDataReport,
    required GeneralUserSearchByLatLon searchByLatLon,
  })  : _getBuoyDistanceReport = getBuoyDistanceReport,
        _getBuoyDataReport = getBuoyDataReport,
        _searchByLatLon = searchByLatLon,
        super(const GeneralUserExportState.initial()) {
    on<LoadGeneralUserExport>(_onLoadGeneralUserExport);
    on<ChangeGeneralUserExportDateRange>(_onChangeDateRange);
    on<ApplyGeneralUserExportCustomRange>(_onApplyCustomRange);
    on<ChangeGeneralUserExportReportType>(_onChangeReportType);
    on<ChangeGeneralUserExportDistanceStartPointType>(
      _onChangeDistanceStartPointType,
    );
    on<UpdateGeneralUserExportDistanceFields>(_onUpdateDistanceFields);
    on<SubmitGeneralUserExportDistanceStartPoint>(
      _onSubmitDistanceStartPoint,
    );
    on<SearchGeneralUserExportByLatLon>(_onSearchByLatLon);
    on<ChangeGeneralUserExportFormat>(_onChangeFormat);
    on<ExportMultiBuoyDataSaveToDevice>(_onExportMultiDataSave);
    on<ExportMultiBuoyDataShare>(_onExportMultiDataShare);
    on<ExportBuoyDistanceSaveToDevice>(_onExportSave);
    on<ExportBuoyDistanceShare>(_onExportShare);
    on<ClearGeneralUserExportDeliverable>(_onClearDeliverable);
    on<ClearGeneralUserExportMessage>(_onClearMessage);
    on<ClearGeneralUserExportStartPointLatLng>(_onClearStartPointLatLng);
  }

  final GeneralUserGetBuoyDistanceReportForExport _getBuoyDistanceReport;
  final GeneralUserGetBuoyDataReportForExport _getBuoyDataReport;
  final GeneralUserSearchByLatLon _searchByLatLon;

  static String _pdfReportTitleFor(ExportReportType reportType) {
    return reportType == ExportReportType.buoyDistance
        ? 'Buoy Distance Report'
        : 'Buoy Data Report';
  }

  /// Fingerprint for the report API request currently implied by [state].
  /// Used to reuse preview rows on export without a second network call.
  String? _reportDataSourceKey(GeneralUserExportState s) {
    final dates = _apiDateStrings(s);
    if (dates == null || s.reportType == null) {
      return null;
    }
    final rt = s.reportType!.name;
    switch (s.mode) {
      case GeneralUserExportMode.buoyDistance:
        final bid = s.buoyId;
        if (bid == null || bid.isEmpty) {
          return null;
        }
        return '${s.mode.name}|$rt|${dates.$1}|${dates.$2}|$bid${_distanceKeySuffix(s)}';
      case GeneralUserExportMode.multiSelection:
        if (s.selectedBuoyIds.isEmpty) {
          return null;
        }
        if (s.reportType == ExportReportType.buoyDistance &&
            s.selectedBuoyIds.length != 1) {
          return null;
        }
        final buoyKey = s.reportType == ExportReportType.buoyDistance
            ? s.selectedBuoyIds.first
            : s.selectedBuoyIds.join(',');
        return '${s.mode.name}|$rt|${dates.$1}|${dates.$2}|$buoyKey${_distanceKeySuffix(s)}';
    }
  }

  static String _distanceKeySuffix(GeneralUserExportState s) {
    if (s.reportType != ExportReportType.buoyDistance ||
        !s.isDistanceStartPointComplete) {
      return '';
    }
    switch (s.distanceStartPointType!) {
      case ExportDistanceStartPointType.latLng:
        return '|lat:${s.startLatitude.trim()}|lng:${s.startLongitude.trim()}';
      case ExportDistanceStartPointType.time:
        return '|time:${s.startTime.trim()}';
    }
  }

  ({
    String? startTime,
    String? startLatitude,
    String? startLongitude,
  })? _startPointApiParams(GeneralUserExportState s) {
    if (s.reportType != ExportReportType.buoyDistance ||
        !s.isDistanceStartPointComplete) {
      return null;
    }
    switch (s.distanceStartPointType!) {
      case ExportDistanceStartPointType.latLng:
        return (
          startTime: null,
          startLatitude: s.startLatitude.trim(),
          startLongitude: s.startLongitude.trim(),
        );
      case ExportDistanceStartPointType.time:
        return (
          startTime: s.startTime.trim(),
          startLatitude: null,
          startLongitude: null,
        );
    }
  }

  ResultFuture<UserReportGetBuoyDistanceReportForExportResponse>
      _callDistanceReport({
    required String buoyId,
    required String fromDate,
    required String toDate,
    required GeneralUserExportState s,
  }) {
    final params = _startPointApiParams(s);
    return _getBuoyDistanceReport(
      buoyId: buoyId,
      fromDate: fromDate,
      toDate: toDate,
      startTime: params?.startTime,
      startLatitude: params?.startLatitude,
      startLongitude: params?.startLongitude,
    );
  }

  ResultFuture<UserReportGetBuoyDistanceReportForExportResponse>
      _callDataReport({
    required String buoyIdsCsv,
    required String fromDate,
    required String toDate,
  }) {
    return _getBuoyDataReport(
      buoyIdsCsv: buoyIdsCsv,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  String? _distanceStartPointValidationMessage(GeneralUserExportState s) {
    if (s.reportType != ExportReportType.buoyDistance) {
      return null;
    }
    if (s.distanceStartPointType == null) {
      return 'Please select Latitude & Longitude or Start Time.';
    }
    switch (s.distanceStartPointType!) {
      case ExportDistanceStartPointType.latLng:
        if (s.startLatitude.trim().isEmpty || s.startLongitude.trim().isEmpty) {
          return 'Please enter Latitude and Longitude.';
        }
        return null;
      case ExportDistanceStartPointType.time:
        if (s.startTime.trim().isEmpty) {
          return 'Please select Start Time.';
        }
        return null;
    }
  }

  String? _resolveSearchBuoyId(GeneralUserExportState s) {
    switch (s.mode) {
      case GeneralUserExportMode.buoyDistance:
        final id = s.buoyId?.trim() ?? '';
        return id.isEmpty ? null : id;
      case GeneralUserExportMode.multiSelection:
        if (s.selectedBuoyIds.length != 1) {
          return null;
        }
        final id = s.selectedBuoyIds.first.trim();
        return id.isEmpty ? null : id;
    }
  }

  Future<void> _completeExportFromRows({
    required Emitter<GeneralUserExportState> emit,
    required List<String> columnOrder,
    required List<Map<String, String>> rows,
    required ExportReportType reportType,
    required ExportFormat format,
    required bool forShare,
    required String fileName,
  }) async {
    try {
      final Uint8List bytes;
      if (format == ExportFormat.csv) {
        final csv = buildDynamicCsv(
          columnOrder: columnOrder,
          rows: rows,
        );
        bytes = encodeCsvToUtf8Bytes(csv);
      } else {
        bytes = await buildDynamicPdf(
          columnOrder: columnOrder,
          rows: rows,
          title: GeneralUserExportBloc._pdfReportTitleFor(reportType),
        );
      }
      emit(
        state.copyWith(
          status: GeneralUserExportStatus.loaded,
          reportColumns: columnOrder,
          reportRows: rows,
          deliverable: GeneralUserExportDeliverable(
            bytes: bytes,
            fileName: fileName,
            forShare: forShare,
          ),
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'Export file build failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: GeneralUserExportStatus.loaded,
          message: _buildExportFailureMessage(error, format),
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onLoadGeneralUserExport(
    LoadGeneralUserExport event,
    Emitter<GeneralUserExportState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserExport');
    emit(
      state.copyWith(
        status: GeneralUserExportStatus.loading,
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
        routeExtraSnapshot: event.routeExtra,
        assignRouteExtraSnapshot: true,
      ),
    );

    try {
      final parsed = _parseRouteExtra(event.routeExtra);

      emit(
        GeneralUserExportState(
          status: GeneralUserExportStatus.loaded,
          mode: parsed.mode,
          routeExtraSnapshot: event.routeExtra,
          selectedBuoyCount: parsed.selectedBuoyCount,
          selectedBuoyIds: parsed.selectedBuoyIds,
          buoyId: parsed.buoyId,
          dateRange: null,
          customStart: null,
          customEnd: null,
          reportType: null,
          distanceStartPointType: null,
          startLatitude: '',
          startLongitude: '',
          startTime: '',
          distanceStartPointSubmitted: false,
          format: null,
          message: '',
          isSuccessMessage: false,
          reportColumns: const [],
          reportRows: const [],
          reportDataSourceKey: null,
          isReportLoading: false,
          isStartPointSearching: false,
          deliverable: null,
          buoyScreenNotice: '',
        ),
      );

      AppLogger.i('LoadGeneralUserExport success');
    } catch (error, stackTrace) {
      AppLogger.e(
        'LoadGeneralUserExport failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: GeneralUserExportStatus.error,
          message: 'Unable to load export options. Please try again.',
          isSuccessMessage: false,
        ),
      );
    }
  }

  Future<void> _onChangeReportType(
    ChangeGeneralUserExportReportType event,
    Emitter<GeneralUserExportState> emit,
  ) async {
    emit(
      state.copyWith(
        reportType: event.reportType,
        assignReportType: true,
        clearDistanceStartPoint: true,
        format: null,
        assignFormat: true,
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
        assignBuoyScreenNotice: true,
        buoyScreenNotice: '',
        reportColumns: const [],
        reportRows: const [],
        clearReportDataSourceKey: true,
        distanceStartPointSubmitted: false,
      ),
    );
    if (event.reportType == ExportReportType.buoyDistance &&
        state.mode == GeneralUserExportMode.multiSelection &&
        state.selectedBuoyIds.length != 1) {
      emit(
        state.copyWith(
          assignBuoyScreenNotice: true,
          buoyScreenNotice: GeneralUserExportState.multiBuoyDistanceReportError,
        ),
      );
      return;
    }

    if (event.reportType == ExportReportType.buoyData) {
      await _refetchReportIfNeeded(emit);
    }
  }

  Future<void> _onChangeDistanceStartPointType(
    ChangeGeneralUserExportDistanceStartPointType event,
    Emitter<GeneralUserExportState> emit,
  ) async {
    emit(
      state.copyWith(
        distanceStartPointType: event.startPointType,
        assignDistanceStartPointType: true,
        startLatitude: '',
        startLongitude: '',
        startTime: '',
        distanceStartPointSubmitted: false,
        format: null,
        assignFormat: true,
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
        assignBuoyScreenNotice: true,
        buoyScreenNotice: '',
        reportColumns: const [],
        reportRows: const [],
        clearReportDataSourceKey: true,
      ),
    );
  }

  Future<void> _onUpdateDistanceFields(
    UpdateGeneralUserExportDistanceFields event,
    Emitter<GeneralUserExportState> emit,
  ) async {
    emit(
      state.copyWith(
        startLatitude: event.startLatitude ?? state.startLatitude,
        startLongitude: event.startLongitude ?? state.startLongitude,
        startTime: event.startTime ?? state.startTime,
        distanceStartPointSubmitted: false,
        format: null,
        assignFormat: true,
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
        assignBuoyScreenNotice: true,
        buoyScreenNotice: '',
        reportColumns: const [],
        reportRows: const [],
        clearReportDataSourceKey: true,
      ),
    );
  }

  Future<void> _onSubmitDistanceStartPoint(
    SubmitGeneralUserExportDistanceStartPoint event,
    Emitter<GeneralUserExportState> emit,
  ) async {
    await _applyDistanceStartPointAndFetchReport(
      emit,
      startLatitude: event.startLatitude,
      startLongitude: event.startLongitude,
      startTime: event.startTime,
    );
  }

  Future<void> _onSearchByLatLon(
    SearchGeneralUserExportByLatLon event,
    Emitter<GeneralUserExportState> emit,
  ) async {
    final latLng = event.latLng.trim();

    if (latLng.isEmpty) {
      emit(
        state.copyWith(
          message: 'Please enter a value to search.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final buoyId = _resolveSearchBuoyId(state);
    if (buoyId == null) {
      emit(
        state.copyWith(
          message: 'Select one buoy for Distance Report.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final dates = _apiDateStrings(state);
    if (dates == null) {
      emit(
        state.copyWith(
          message: 'Please select a date range first.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isStartPointSearching: true,
        assignBuoyScreenNotice: true,
        buoyScreenNotice: '',
      ),
    );

    final result = await _searchByLatLon(
      buoyId: buoyId,
      fromDate: dates.$1,
      toDate: dates.$2,
      latLng: latLng,
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            isStartPointSearching: false,
            assignBuoyScreenNotice: true,
            buoyScreenNotice: failure.message,
          ),
        );
      },
      (response) async {
        if (response.hasCoordinates) {
          emit(
            state.copyWith(
              isStartPointSearching: false,
              startLatitude: response.latitude.trim(),
              startLongitude: response.longitude.trim(),
              assignBuoyScreenNotice: true,
              buoyScreenNotice: '',
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            isStartPointSearching: false,
            startLatitude: '',
            startLongitude: '',
            assignBuoyScreenNotice: true,
            buoyScreenNotice: response.message.isNotEmpty
                ? response.message
                : 'No data found for the given values.',
          ),
        );
      },
    );
  }

  Future<void> _applyDistanceStartPointAndFetchReport(
    Emitter<GeneralUserExportState> emit, {
    required String startLatitude,
    required String startLongitude,
    required String startTime,
  }) async {
    emit(
      state.copyWith(
        startLatitude: startLatitude,
        startLongitude: startLongitude,
        startTime: startTime,
        distanceStartPointSubmitted: false,
        format: null,
        assignFormat: true,
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
        assignBuoyScreenNotice: true,
        buoyScreenNotice: '',
        reportColumns: const [],
        reportRows: const [],
        clearReportDataSourceKey: true,
      ),
    );

    if (state.reportType != ExportReportType.buoyDistance) {
      return;
    }

    if (state.isMultiBuoyDistanceReportBlocked) {
      emit(
        state.copyWith(
          assignBuoyScreenNotice: true,
          buoyScreenNotice: GeneralUserExportState.multiBuoyDistanceReportError,
        ),
      );
      return;
    }

    final validation = _distanceStartPointValidationMessage(state);
    if (validation != null) {
      emit(
        state.copyWith(
          message: validation,
          isSuccessMessage: false,
        ),
      );
      return;
    }

    if (state.mode == GeneralUserExportMode.buoyDistance) {
      await _fetchBuoyReport(emit);
    } else if (state.mode == GeneralUserExportMode.multiSelection) {
      await _fetchMultiBuoyDataReport(emit);
    }

    if (state.reportType != null &&
        !state.isReportLoading &&
        state.buoyScreenNotice.isEmpty) {
      emit(
        state.copyWith(
          distanceStartPointSubmitted: true,
        ),
      );
    }
  }

  _ParsedRouteExtra _parseRouteExtra(Object? extra) {
    if (extra is GeneralUserExportBuoyDistanceExtra) {
      final id = extra.buoyId.trim();
      return _ParsedRouteExtra(
        mode: GeneralUserExportMode.buoyDistance,
        buoyId: id.isEmpty ? null : id,
        selectedBuoyCount: 0,
        selectedBuoyIds: const [],
      );
    }
    if (extra is GeneralUserExportSelectionBuoysExtra) {
      final ids = extra.buoyIds
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
      return _ParsedRouteExtra(
        mode: GeneralUserExportMode.multiSelection,
        buoyId: null,
        selectedBuoyCount: ids.length,
        selectedBuoyIds: ids,
      );
    }
    return const _ParsedRouteExtra(
      mode: GeneralUserExportMode.multiSelection,
      buoyId: null,
      selectedBuoyCount: 0,
      selectedBuoyIds: [],
    );
  }

  Future<void> _onChangeDateRange(
    ChangeGeneralUserExportDateRange event,
    Emitter<GeneralUserExportState> emit,
  ) async {
    emit(
      state.copyWith(
        dateRange: event.dateRange,
        assignDateRange: true,
        assignReportType: true,
        reportType: null,
        assignFormat: true,
        format: null,
        clearDistanceStartPoint: true,
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
        assignBuoyScreenNotice: true,
        buoyScreenNotice: '',
        reportColumns: const [],
        reportRows: const [],
        clearReportDataSourceKey: true,
      ),
    );
    await _refetchReportIfNeeded(emit);
  }

  Future<void> _onApplyCustomRange(
    ApplyGeneralUserExportCustomRange event,
    Emitter<GeneralUserExportState> emit,
  ) async {
    final a = startOfDay(
      event.start.isBefore(event.end) ? event.start : event.end,
    );
    final b = startOfDay(
      event.start.isBefore(event.end) ? event.end : event.start,
    );
    emit(
      state.copyWith(
        dateRange: ExportDateRange.custom,
        assignDateRange: true,
        customStart: a,
        customEnd: b,
        assignReportType: true,
        reportType: null,
        assignFormat: true,
        format: null,
        clearDistanceStartPoint: true,
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
        assignBuoyScreenNotice: true,
        buoyScreenNotice: '',
        reportColumns: const [],
        reportRows: const [],
        clearReportDataSourceKey: true,
      ),
    );
    await _refetchReportIfNeeded(emit);
  }

  Future<void> _refetchReportIfNeeded(
    Emitter<GeneralUserExportState> emit,
  ) async {
    if (state.reportType != ExportReportType.buoyData ||
        state.dateRange == null) {
      return;
    }
    if (state.mode == GeneralUserExportMode.buoyDistance &&
        state.buoyId != null &&
        state.buoyId!.isNotEmpty) {
      await _fetchBuoyReport(emit);
      return;
    }
    if (state.mode == GeneralUserExportMode.multiSelection &&
        state.selectedBuoyIds.isNotEmpty) {
      await _fetchMultiBuoyDataReport(emit);
    }
  }

  void _onChangeFormat(
    ChangeGeneralUserExportFormat event,
    Emitter<GeneralUserExportState> emit,
  ) {
    emit(
      state.copyWith(
        format: event.format,
        assignFormat: true,
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
      ),
    );
  }

  Future<void> _onExportMultiDataSave(
    ExportMultiBuoyDataSaveToDevice event,
    Emitter<GeneralUserExportState> emit,
  ) async {
    await _exportMultiBuoyDataFile(emit, forShare: false);
  }

  Future<void> _onExportMultiDataShare(
    ExportMultiBuoyDataShare event,
    Emitter<GeneralUserExportState> emit,
  ) async {
    await _exportMultiBuoyDataFile(emit, forShare: true);
  }

  Future<void> _exportMultiBuoyDataFile(
    Emitter<GeneralUserExportState> emit, {
    required bool forShare,
  }) async {
    if (state.mode != GeneralUserExportMode.multiSelection) {
      return;
    }
    if (state.selectedBuoyIds.isEmpty) {
      emit(
        state.copyWith(
          message: 'No buoys selected.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    final reportType = state.reportType;
    if (reportType == null) {
      emit(
        state.copyWith(
          message: 'Please select report type.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (reportType == ExportReportType.buoyDistance) {
      final distanceValidation = _distanceStartPointValidationMessage(state);
      if (distanceValidation != null ||
          !state.isDistanceStartPointReadyForExport) {
        emit(
          state.copyWith(
            message: distanceValidation ?? 'Please submit start point details.',
            isSuccessMessage: false,
          ),
        );
        return;
      }
    }
    final format = state.format;
    if (format == null) {
      emit(
        state.copyWith(
          message: 'Please select export format.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    final dates = _apiDateStrings(state);
    if (dates == null) {
      emit(
        state.copyWith(
          message: 'Please choose a valid date range.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: GeneralUserExportStatus.exporting,
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
      ),
    );

    if (reportType == ExportReportType.buoyDistance &&
        state.selectedBuoyIds.length != 1) {
      emit(
        state.copyWith(
          status: GeneralUserExportStatus.loaded,
          message: GeneralUserExportState.multiBuoyDistanceReportError,
          isSuccessMessage: false,
        ),
      );
      return;
    }

    final requestKey = _reportDataSourceKey(state);
    final useCachedReport =
        requestKey != null &&
        requestKey == state.reportDataSourceKey &&
        state.reportRows.isNotEmpty;

    if (useCachedReport) {
      final cols = state.reportColumns.isNotEmpty
          ? state.reportColumns
          : deriveReportColumnOrder(state.reportRows);
      final fileBuoyId = state.selectedBuoyIds.length == 1
          ? state.selectedBuoyIds.first
          : 'MultipleBuoys';
      final reportTypeLabel =
          reportType == ExportReportType.buoyDistance
          ? 'Distance Report'
          : 'Data Report';
      final name = exportMultiBuoyDataReportFileName(
        buoyId: fileBuoyId,
        reportType: reportTypeLabel,
        fromDate: dates.$1,
        toDate: dates.$2,
        csv: format == ExportFormat.csv,
      );
      await _completeExportFromRows(
        emit: emit,
        columnOrder: cols,
        rows: state.reportRows,
        reportType: reportType,
        format: format,
        forShare: forShare,
        fileName: name,
      );
      return;
    }

    final idsCsv = state.selectedBuoyIds.join(',');
    final outcome = reportType == ExportReportType.buoyDistance
        ? await _callDistanceReport(
            buoyId: state.selectedBuoyIds.first,
            fromDate: dates.$1,
            toDate: dates.$2,
            s: state,
          )
        : await _callDataReport(
            buoyIdsCsv: idsCsv,
            fromDate: dates.$1,
            toDate: dates.$2,
          );

    await outcome.foldAsync(
      (failure) async {
        emit(
          state.copyWith(
            status: GeneralUserExportStatus.loaded,
            message: failure.message,
            isSuccessMessage: false,
          ),
        );
      },
      (response) async {
        final cols = deriveReportColumnOrder(response.rows);
        final fileBuoyId = state.selectedBuoyIds.length == 1
            ? state.selectedBuoyIds.first
            : 'MultipleBuoys';
        final reportTypeLabel =
            reportType == ExportReportType.buoyDistance
            ? 'Distance Report'
            : 'Data Report';
        final name = exportMultiBuoyDataReportFileName(
          buoyId: fileBuoyId,
          reportType: reportTypeLabel,
          fromDate: dates.$1,
          toDate: dates.$2,
          csv: format == ExportFormat.csv,
        );
        await _completeExportFromRows(
          emit: emit,
          columnOrder: cols,
          rows: response.rows,
          reportType: reportType,
          format: format,
          forShare: forShare,
          fileName: name,
        );
      },
    );
  }

  Future<void> _onExportSave(
    ExportBuoyDistanceSaveToDevice event,
    Emitter<GeneralUserExportState> emit,
  ) async {
    await _exportBuoyFile(emit, forShare: false);
  }

  Future<void> _onExportShare(
    ExportBuoyDistanceShare event,
    Emitter<GeneralUserExportState> emit,
  ) async {
    await _exportBuoyFile(emit, forShare: true);
  }

  Future<void> _exportBuoyFile(
    Emitter<GeneralUserExportState> emit, {
    required bool forShare,
  }) async {
    if (state.mode != GeneralUserExportMode.buoyDistance) {
      return;
    }
    final bid = state.buoyId;
    if (bid == null || bid.isEmpty) {
      emit(
        state.copyWith(
          message: 'Missing buoy id.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    final reportType = state.reportType;
    if (reportType == null) {
      emit(
        state.copyWith(
          message: 'Please select report type.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    if (reportType == ExportReportType.buoyDistance) {
      final distanceValidation = _distanceStartPointValidationMessage(state);
      if (distanceValidation != null ||
          !state.isDistanceStartPointReadyForExport) {
        emit(
          state.copyWith(
            message: distanceValidation ?? 'Please submit start point details.',
            isSuccessMessage: false,
          ),
        );
        return;
      }
    }
    final format = state.format;
    if (format == null) {
      emit(
        state.copyWith(
          message: 'Please select export format.',
          isSuccessMessage: false,
        ),
      );
      return;
    }
    final dates = _apiDateStrings(state);
    if (dates == null) {
      emit(
        state.copyWith(
          message: 'Please choose a valid date range.',
          isSuccessMessage: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: GeneralUserExportStatus.exporting,
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
      ),
    );

    final requestKey = _reportDataSourceKey(state);
    final useCachedReport =
        requestKey != null &&
        requestKey == state.reportDataSourceKey &&
        state.reportRows.isNotEmpty;

    if (useCachedReport) {
      final cols = state.reportColumns.isNotEmpty
          ? state.reportColumns
          : deriveReportColumnOrder(state.reportRows);
      final name = exportReportFileName(
        buoyId: bid,
        reportType: reportType == ExportReportType.buoyDistance
            ? 'Distance Report'
            : 'Data Report',
        fromDate: dates.$1,
        toDate: dates.$2,
        csv: format == ExportFormat.csv,
      );
      await _completeExportFromRows(
        emit: emit,
        columnOrder: cols,
        rows: state.reportRows,
        reportType: reportType,
        format: format,
        forShare: forShare,
        fileName: name,
      );
      return;
    }

    final outcome = reportType == ExportReportType.buoyData
        ? await _callDataReport(
            buoyIdsCsv: bid,
            fromDate: dates.$1,
            toDate: dates.$2,
          )
        : await _callDistanceReport(
            buoyId: bid,
            fromDate: dates.$1,
            toDate: dates.$2,
            s: state,
          );

    await outcome.foldAsync(
      (failure) async {
        emit(
          state.copyWith(
            status: GeneralUserExportStatus.loaded,
            message: failure.message,
            isSuccessMessage: false,
          ),
        );
      },
      (response) async {
        final cols = deriveReportColumnOrder(response.rows);
        final name = exportReportFileName(
          buoyId: bid,
          reportType: reportType == ExportReportType.buoyDistance
              ? 'Distance Report'
              : 'Data Report',
          fromDate: dates.$1,
          toDate: dates.$2,
          csv: format == ExportFormat.csv,
        );
        await _completeExportFromRows(
          emit: emit,
          columnOrder: cols,
          rows: response.rows,
          reportType: reportType,
          format: format,
          forShare: forShare,
          fileName: name,
        );
      },
    );
  }

  /// Best-effort, user-facing message for an export failure. Distinguishes
  /// the common "PDF has too many pages" case so users can switch to CSV or
  /// narrow their date range instead of seeing a generic error.
  static String _buildExportFailureMessage(
    Object error,
    ExportFormat format,
  ) {
    final text = error.toString().toLowerCase();
    final looksLikeTooManyPages =
        text.contains('toomanypages') || text.contains('too many pages');
    if (format == ExportFormat.pdf && looksLikeTooManyPages) {
      return 'This report is too large to export as PDF. '
          'Please choose a smaller date range or export as CSV.';
    }
    return 'Could not build export file. Please try again.';
  }

  Future<void> _fetchBuoyReport(Emitter<GeneralUserExportState> emit) async {
    final bid = state.buoyId;
    if (state.mode != GeneralUserExportMode.buoyDistance ||
        state.dateRange == null ||
        state.reportType == null ||
        bid == null ||
        bid.isEmpty) {
      return;
    }

    final dates = _apiDateStrings(state);
    if (dates == null) {
      emit(
        state.copyWith(
          isReportLoading: false,
          reportColumns: const [],
          reportRows: const [],
          clearReportDataSourceKey: true,
          assignBuoyScreenNotice: true,
          buoyScreenNotice: 'Data not found',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isReportLoading: true,
        message: '',
        assignBuoyScreenNotice: true,
        buoyScreenNotice: '',
      ),
    );

    final outcome = state.reportType == ExportReportType.buoyData
        ? await _callDataReport(
            buoyIdsCsv: bid,
            fromDate: dates.$1,
            toDate: dates.$2,
          )
        : await _callDistanceReport(
            buoyId: bid,
            fromDate: dates.$1,
            toDate: dates.$2,
            s: state,
          );

    await outcome.foldAsync(
      (failure) async {
        emit(
          state.copyWith(
            isReportLoading: false,
            reportColumns: const [],
            reportRows: const [],
            clearReportDataSourceKey: true,
            assignBuoyScreenNotice: true,
            buoyScreenNotice: failure.message,
          ),
        );
      },
      (response) async {
        final cols = deriveReportColumnOrder(response.rows);
        final empty = response.rows.isEmpty;
        emit(
          state.copyWith(
            isReportLoading: false,
            reportColumns: cols,
            reportRows: response.rows,
            assignReportDataSourceKey: true,
            reportDataSourceKey:
                empty ? null : _reportDataSourceKey(state),
            assignBuoyScreenNotice: true,
            buoyScreenNotice: empty ? 'Data not found' : '',
          ),
        );
      },
    );
  }

  Future<void> _fetchMultiBuoyDataReport(Emitter<GeneralUserExportState> emit) async {
    if (state.mode != GeneralUserExportMode.multiSelection ||
        state.dateRange == null ||
        state.reportType == null ||
        state.selectedBuoyIds.isEmpty) {
      return;
    }

    final dates = _apiDateStrings(state);
    if (dates == null) {
      emit(
        state.copyWith(
          isReportLoading: false,
          reportColumns: const [],
          reportRows: const [],
          clearReportDataSourceKey: true,
          assignBuoyScreenNotice: true,
          buoyScreenNotice: 'Data not found',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isReportLoading: true,
        message: '',
        assignBuoyScreenNotice: true,
        buoyScreenNotice: '',
      ),
    );

    if (state.reportType == ExportReportType.buoyDistance &&
        state.selectedBuoyIds.length != 1) {
      emit(
        state.copyWith(
          isReportLoading: false,
          reportColumns: const [],
          reportRows: const [],
          clearReportDataSourceKey: true,
          assignBuoyScreenNotice: true,
          buoyScreenNotice: GeneralUserExportState.multiBuoyDistanceReportError,
        ),
      );
      return;
    }

    final idsCsv = state.selectedBuoyIds.join(',');
    final outcome = state.reportType == ExportReportType.buoyDistance
        ? await _callDistanceReport(
            buoyId: state.selectedBuoyIds.first,
            fromDate: dates.$1,
            toDate: dates.$2,
            s: state,
          )
        : await _callDataReport(
            buoyIdsCsv: idsCsv,
            fromDate: dates.$1,
            toDate: dates.$2,
          );

    await outcome.foldAsync(
      (failure) async {
        emit(
          state.copyWith(
            isReportLoading: false,
            reportColumns: const [],
            reportRows: const [],
            clearReportDataSourceKey: true,
            assignBuoyScreenNotice: true,
            buoyScreenNotice: failure.message,
          ),
        );
      },
      (response) async {
        final cols = deriveReportColumnOrder(response.rows);
        final empty = response.rows.isEmpty;
        emit(
          state.copyWith(
            isReportLoading: false,
            reportColumns: cols,
            reportRows: response.rows,
            assignReportDataSourceKey: true,
            reportDataSourceKey:
                empty ? null : _reportDataSourceKey(state),
            assignBuoyScreenNotice: true,
            buoyScreenNotice: empty ? 'Data not found' : '',
          ),
        );
      },
    );
  }

  (String, String)? _apiDateStrings(GeneralUserExportState s) {
    final today = todayLocal();
    switch (s.dateRange) {
      case null:
        return null;
      case ExportDateRange.currentDay:
        return (formatReportApiDate(today), formatReportApiDate(today));
      case ExportDateRange.yesterday:
        final y = today.subtract(const Duration(days: 1));
        return (formatReportApiDate(y), formatReportApiDate(y));

      case ExportDateRange.custom:
        final a = s.customStart;
        final b = s.customEnd;
        if (a == null || b == null) {
          return null;
        }
        return (formatReportApiDate(a), formatReportApiDate(b));
    }
  }

  void _onClearDeliverable(
    ClearGeneralUserExportDeliverable event,
    Emitter<GeneralUserExportState> emit,
  ) {
    emit(state.copyWith(clearDeliverable: true));
  }

  void _onClearMessage(
    ClearGeneralUserExportMessage event,
    Emitter<GeneralUserExportState> emit,
  ) {
    emit(state.copyWith(message: '', isSuccessMessage: false));
  }

  void _onClearStartPointLatLng(
    ClearGeneralUserExportStartPointLatLng event,
    Emitter<GeneralUserExportState> emit,
  ) {
    emit(
      state.copyWith(
        startLatitude: '',
        startLongitude: '',
        assignBuoyScreenNotice: true,
        buoyScreenNotice: '',
      ),
    );
  }
}

class _ParsedRouteExtra {
  const _ParsedRouteExtra({
    required this.mode,
    required this.buoyId,
    required this.selectedBuoyCount,
    required this.selectedBuoyIds,
  });

  final GeneralUserExportMode mode;
  final String? buoyId;
  final int selectedBuoyCount;
  final List<String> selectedBuoyIds;
}
