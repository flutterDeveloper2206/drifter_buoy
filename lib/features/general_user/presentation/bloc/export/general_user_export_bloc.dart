import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserExportBloc
    extends Bloc<GeneralUserExportEvent, GeneralUserExportState> {
  GeneralUserExportBloc() : super(const GeneralUserExportState.initial()) {
    on<LoadGeneralUserExport>(_onLoadGeneralUserExport);
    on<ChangeGeneralUserExportDateRange>(_onChangeGeneralUserExportDateRange);
    on<ChangeGeneralUserExportFormat>(_onChangeGeneralUserExportFormat);
    on<SubmitGeneralUserExport>(_onSubmitGeneralUserExport);
    on<ClearGeneralUserExportMessage>(_onClearGeneralUserExportMessage);
  }

  Future<void> _onLoadGeneralUserExport(
    LoadGeneralUserExport event,
    Emitter<GeneralUserExportState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserExport event triggered');
    emit(
      state.copyWith(
        status: GeneralUserExportStatus.loading,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      emit(
        state.copyWith(
          status: GeneralUserExportStatus.loaded,
          message: '',
          isSuccessMessage: false,
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

  void _onChangeGeneralUserExportDateRange(
    ChangeGeneralUserExportDateRange event,
    Emitter<GeneralUserExportState> emit,
  ) {
    emit(
      state.copyWith(
        dateRange: event.dateRange,
        message: '',
        isSuccessMessage: false,
      ),
    );
  }

  void _onChangeGeneralUserExportFormat(
    ChangeGeneralUserExportFormat event,
    Emitter<GeneralUserExportState> emit,
  ) {
    emit(
      state.copyWith(
        format: event.format,
        message: '',
        isSuccessMessage: false,
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

    AppLogger.i(
      'SubmitGeneralUserExport started: range=${state.dateRange}, '
      'format=${state.format}',
    );
    emit(
      state.copyWith(
        status: GeneralUserExportStatus.exporting,
        message: '',
        isSuccessMessage: false,
      ),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 950));
      final formattedRange = _dateRangeLabel(state.dateRange);
      final formattedFormat = state.format == ExportFormat.csv ? 'CSV' : 'PDF';
      emit(
        state.copyWith(
          status: GeneralUserExportStatus.loaded,
          message: '$formattedFormat export for $formattedRange is ready.',
          isSuccessMessage: true,
        ),
      );
      AppLogger.i('SubmitGeneralUserExport success');
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

  void _onClearGeneralUserExportMessage(
    ClearGeneralUserExportMessage event,
    Emitter<GeneralUserExportState> emit,
  ) {
    emit(state.copyWith(message: '', isSuccessMessage: false));
  }

  String _dateRangeLabel(ExportDateRange range) {
    switch (range) {
      case ExportDateRange.last24Hours:
        return 'Last 24 Hrs';
      case ExportDateRange.last7Days:
        return 'Last 7 Days';
      case ExportDateRange.last30Days:
        return 'Last 30 Days';
      case ExportDateRange.custom:
        return 'Custom Range';
    }
  }
}
