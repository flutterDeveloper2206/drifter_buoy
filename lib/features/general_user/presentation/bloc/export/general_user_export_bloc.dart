import 'dart:typed_data';

import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/export_report_dynamic_codec.dart';
import 'package:drifter_buoy/core/utils/report_export_date_format.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_data_report_for_export.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_distance_report_for_export.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/navigation/general_user_export_route_extra.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserExportBloc
    extends Bloc<GeneralUserExportEvent, GeneralUserExportState> {
  GeneralUserExportBloc({
    required GeneralUserGetBuoyDistanceReportForExport getBuoyDistanceReport,
    required GeneralUserGetBuoyDataReportForExport getBuoyDataReport,
  })  : _getBuoyDistanceReport = getBuoyDistanceReport,
        _getBuoyDataReport = getBuoyDataReport,
        super(const GeneralUserExportState.initial()) {
    on<LoadGeneralUserExport>(_onLoadGeneralUserExport);
    on<ChangeGeneralUserExportDateRange>(_onChangeDateRange);
    on<ApplyGeneralUserExportCustomRange>(_onApplyCustomRange);
    on<ChangeGeneralUserExportFormat>(_onChangeFormat);
    on<ExportMultiBuoyDataSaveToDevice>(_onExportMultiDataSave);
    on<ExportMultiBuoyDataShare>(_onExportMultiDataShare);
    on<ExportBuoyDistanceSaveToDevice>(_onExportSave);
    on<ExportBuoyDistanceShare>(_onExportShare);
    on<ClearGeneralUserExportDeliverable>(_onClearDeliverable);
    on<ClearGeneralUserExportMessage>(_onClearMessage);
  }

  final GeneralUserGetBuoyDistanceReportForExport _getBuoyDistanceReport;
  final GeneralUserGetBuoyDataReportForExport _getBuoyDataReport;

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
      final multiReady = parsed.mode == GeneralUserExportMode.multiSelection &&
          parsed.selectedBuoyIds.isNotEmpty;

      emit(
        GeneralUserExportState(
          status: GeneralUserExportStatus.loaded,
          mode: parsed.mode,
          routeExtraSnapshot: event.routeExtra,
          selectedBuoyCount: parsed.selectedBuoyCount,
          selectedBuoyIds: parsed.selectedBuoyIds,
          buoyId: parsed.buoyId,
          dateRange: (buoyReady || multiReady)
              ? ExportDateRange.yesterday
              : ExportDateRange.last24Hours,
          customStart: null,
          customEnd: null,
          format: ExportFormat.csv,
          message: '',
          isSuccessMessage: false,
          reportColumns: const [],
          reportRows: const [],
          isReportLoading: buoyReady || multiReady,
          deliverable: null,
          buoyScreenNotice: '',
        ),
      );

      if (buoyReady) {
        await _fetchBuoyReport(emit);
      } else if (multiReady) {
        await _fetchMultiBuoyDataReport(emit);
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
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
        assignBuoyScreenNotice: true,
        buoyScreenNotice: '',
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
        customStart: a,
        customEnd: b,
        message: '',
        isSuccessMessage: false,
        clearDeliverable: true,
        assignBuoyScreenNotice: true,
        buoyScreenNotice: '',
      ),
    );
    await _refetchReportIfNeeded(emit);
  }

  Future<void> _refetchReportIfNeeded(
    Emitter<GeneralUserExportState> emit,
  ) async {
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

    final idsCsv = state.selectedBuoyIds.join(',');
    final outcome = await _getBuoyDataReport(
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
              title:
                  'Buoy data — ${state.selectedBuoyIds.length} buoys (${dates.$1} → ${dates.$2})',
            );
          }
          final name = exportMultiBuoyDataReportFileName(
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
            'Multi export file build failed',
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

  Future<void> _fetchMultiBuoyDataReport(Emitter<GeneralUserExportState> emit) async {
    if (state.mode != GeneralUserExportMode.multiSelection ||
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

    final idsCsv = state.selectedBuoyIds.join(',');
    final outcome = await _getBuoyDataReport(
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
