import 'dart:typed_data';

import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/export_report_dynamic_codec.dart';
import 'package:drifter_buoy/core/utils/report_export_date_format.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_distance_report_for_export.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/navigation/general_user_export_route_extra.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserExportBloc
    extends Bloc<GeneralUserExportEvent, GeneralUserExportState> {
  GeneralUserExportBloc({
    required GeneralUserGetBuoyDistanceReportForExport getBuoyDistanceReport,
  })  : _getBuoyDistanceReport = getBuoyDistanceReport,
        super(const GeneralUserExportState.initial()) {
    on<LoadGeneralUserExport>(_onLoadGeneralUserExport);
    on<ChangeGeneralUserExportDateRange>(_onChangeDateRange);
    on<ApplyGeneralUserExportCustomRange>(_onApplyCustomRange);
    on<ChangeGeneralUserExportFormat>(_onChangeFormat);
    on<SubmitGeneralUserExport>(_onSubmitGeneralUserExport);
    on<ExportBuoyDistanceSaveToDevice>(_onExportSave);
    on<ExportBuoyDistanceShare>(_onExportShare);
    on<ClearGeneralUserExportDeliverable>(_onClearDeliverable);
    on<ClearGeneralUserExportMessage>(_onClearMessage);
  }

  final GeneralUserGetBuoyDistanceReportForExport _getBuoyDistanceReport;

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
      final buoyReady = parsed.mode == GeneralUserExportMode.buoyDistance &&
          parsed.buoyId != null &&
          parsed.buoyId!.isNotEmpty;

      emit(
        GeneralUserExportState(
          status: GeneralUserExportStatus.loaded,
          mode: parsed.mode,
          routeExtraSnapshot: event.routeExtra,
          selectedBuoyCount: parsed.selectedBuoyCount,
          buoyId: parsed.buoyId,
          dateRange: buoyReady
              ? ExportDateRange.yesterday
              : ExportDateRange.last24Hours,
          customStart: null,
          customEnd: null,
          format: ExportFormat.csv,
          message: '',
          isSuccessMessage: false,
          reportColumns: const [],
          reportRows: const [],
          isReportLoading: buoyReady,
          deliverable: null,
          buoyScreenNotice: '',
        ),
      );

      if (buoyReady) {
        await _fetchBuoyReport(emit);
      }

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

  _ParsedRouteExtra _parseRouteExtra(Object? extra) {
    if (extra is GeneralUserExportBuoyDistanceExtra) {
      final id = extra.buoyId.trim();
      return _ParsedRouteExtra(
        mode: GeneralUserExportMode.buoyDistance,
        buoyId: id.isEmpty ? null : id,
        selectedBuoyCount: 0,
      );
    }
    if (extra is GeneralUserExportSelectionCountExtra) {
      return _ParsedRouteExtra(
        mode: GeneralUserExportMode.multiSelection,
        buoyId: null,
        selectedBuoyCount: extra.selectedBuoyCount,
      );
    }
    if (extra is int && extra > 0) {
      return _ParsedRouteExtra(
        mode: GeneralUserExportMode.multiSelection,
        buoyId: null,
        selectedBuoyCount: extra,
      );
    }
    return const _ParsedRouteExtra(
      mode: GeneralUserExportMode.multiSelection,
      buoyId: null,
      selectedBuoyCount: 0,
    );
  }

  void _onChangeDateRange(
    ChangeGeneralUserExportDateRange event,
    Emitter<GeneralUserExportState> emit,
  ) {
    emit(
      state.copyWith(
        dateRange: event.dateRange,
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
        assignBuoyScreenNotice: true,
        buoyScreenNotice: '',
      ),
    );
  }

  void _onApplyCustomRange(
    ApplyGeneralUserExportCustomRange event,
    Emitter<GeneralUserExportState> emit,
  ) {
    final a = startOfDay(
      event.start.isBefore(event.end) ? event.start : event.end,
    );
    final b = startOfDay(
      event.start.isBefore(event.end) ? event.end : event.start,
    );
    emit(
      state.copyWith(
        dateRange: ExportDateRange.custom,
        customStart: a,
        customEnd: b,
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
        assignBuoyScreenNotice: true,
        buoyScreenNotice: '',
      ),
    );
  }

  void _onChangeFormat(
    ChangeGeneralUserExportFormat event,
    Emitter<GeneralUserExportState> emit,
  ) {
    emit(
      state.copyWith(
        format: event.format,
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
      ),
    );
  }

  Future<void> _onSubmitGeneralUserExport(
    SubmitGeneralUserExport event,
    Emitter<GeneralUserExportState> emit,
  ) async {
    if (state.status == GeneralUserExportStatus.exporting) {
      return;
    }
    if (state.mode != GeneralUserExportMode.multiSelection) {
      return;
    }

    AppLogger.i('SubmitGeneralUserExport (multi placeholder)');
    emit(
      state.copyWith(
        status: GeneralUserExportStatus.exporting,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      final label = _dateRangeLabel(state.dateRange);
      final fmt = state.format == ExportFormat.csv ? 'CSV' : 'PDF';
      emit(
        state.copyWith(
          status: GeneralUserExportStatus.loaded,
          message: '$fmt export for $label is ready (preview).',
          isSuccessMessage: true,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'SubmitGeneralUserExport failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: GeneralUserExportStatus.error,
          message: 'Export failed. Please try again.',
          isSuccessMessage: false,
        ),
      );
    }
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

    final outcome = await _getBuoyDistanceReport(
      buoyId: bid,
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
        try {
          final cols = deriveReportColumnOrder(response.rows);
          final Uint8List bytes;
          if (state.format == ExportFormat.csv) {
            final csv = buildDynamicCsv(
              columnOrder: cols,
              rows: response.rows,
            );
            bytes = encodeCsvToUtf8Bytes(csv);
          } else {
            bytes = await buildDynamicPdf(
              columnOrder: cols,
              rows: response.rows,
              title: 'Buoy distance — $bid (${dates.$1} → ${dates.$2})',
            );
          }
          final name = exportReportFileName(
            buoyId: bid,
            fromDate: dates.$1,
            toDate: dates.$2,
            csv: state.format == ExportFormat.csv,
          );
          emit(
            state.copyWith(
              status: GeneralUserExportStatus.loaded,
              reportColumns: cols,
              reportRows: response.rows,
              deliverable: GeneralUserExportDeliverable(
                bytes: bytes,
                fileName: name,
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
              message: 'Could not build export file.',
              isSuccessMessage: false,
            ),
          );
        }
      },
    );
  }

  Future<void> _fetchBuoyReport(Emitter<GeneralUserExportState> emit) async {
    final bid = state.buoyId;
    if (state.mode != GeneralUserExportMode.buoyDistance ||
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

    final outcome = await _getBuoyDistanceReport(
      buoyId: bid,
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
      case ExportDateRange.last24Hours:
        return (formatReportApiDate(today), formatReportApiDate(today));
      case ExportDateRange.yesterday:
        final y = today.subtract(const Duration(days: 1));
        return (formatReportApiDate(y), formatReportApiDate(y));
      case ExportDateRange.last7Days:
        final start = today.subtract(const Duration(days: 6));
        return (formatReportApiDate(start), formatReportApiDate(today));
      case ExportDateRange.last30Days:
        final start = today.subtract(const Duration(days: 29));
        return (formatReportApiDate(start), formatReportApiDate(today));
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

  String _dateRangeLabel(ExportDateRange range) {
    switch (range) {
      case ExportDateRange.last24Hours:
        return 'Last 24 Hrs';
      case ExportDateRange.yesterday:
        return 'Yesterday';
      case ExportDateRange.last7Days:
        return 'Last 7 Days';
      case ExportDateRange.last30Days:
        return 'Last 30 Days';
      case ExportDateRange.custom:
        return 'Custom Range';
    }
  }
}

class _ParsedRouteExtra {
  const _ParsedRouteExtra({
    required this.mode,
    required this.buoyId,
    required this.selectedBuoyCount,
  });

  final GeneralUserExportMode mode;
  final String? buoyId;
  final int selectedBuoyCount;
}
