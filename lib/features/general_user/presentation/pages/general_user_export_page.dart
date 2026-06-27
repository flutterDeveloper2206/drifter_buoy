import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/export_deliverable_actions.dart';
import 'package:drifter_buoy/core/utils/export_report_dynamic_codec.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_common_dropdown.dart';
import 'package:drifter_buoy/core/utils/widgets/app_export_format_card.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_elevated_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

String _formatExportDisplayDate(DateTime d) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final day = d.day.toString().padLeft(2, '0');
  return '$day ${months[d.month - 1]} ${d.year}';
}

Future<DateTimeRange?> showExportThemedDateRangePicker({
  required BuildContext context,
  DateTimeRange? initialDateRange,
  String description = 'Choose start and end dates for this export.',
}) {
  const primary = Color(0xFF206BBE);
  const accent = Color(0xFF2A86CE);
  const surface = Color(0xFFF2F2F2);
  const onSurface = Color(0xFF30353A);
  const headerBg = Color(0xFFE8EBED);
  const headerFg = Color(0xFF262C31);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final minDate = DateTime(2020);
  final maxDate = today.add(const Duration(days: 365));

  final PickerDateRange initialRange = initialDateRange != null
      ? PickerDateRange(
          DateTime(
            initialDateRange.start.year,
            initialDateRange.start.month,
            initialDateRange.start.day,
          ),
          DateTime(
            initialDateRange.end.year,
            initialDateRange.end.month,
            initialDateRange.end.day,
          ),
        )
      : PickerDateRange(today.subtract(const Duration(days: 7)), today);

  final displayDate =
      initialDateRange?.start ?? initialRange.startDate ?? today;

  return showDialog<DateTimeRange>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (dialogContext) {
      const radius = 20.0;
      return Theme(
        data: Theme.of(dialogContext).copyWith(
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primary,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.88,
            ),
            child: Material(
              color: surface,
              elevation: 12,
              shadowColor: Colors.black.withValues(alpha: 0.18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
                side: BorderSide(
                  color: const Color(0xFF2A86CE).withValues(alpha: 0.28),
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 14, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          headerBg,
                          Color.lerp(headerBg, Colors.white, 0.35)!,
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(radius),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFF2A86CE).withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: primary,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select date range',
                                style: Theme.of(dialogContext)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: headerFg,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.35,
                                      height: 1.2,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                description,
                                style: Theme.of(dialogContext)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: onSurface.withValues(alpha: 0.72),
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 392,
                    child: SfDateRangePicker(
                      view: DateRangePickerView.month,
                      selectionMode: DateRangePickerSelectionMode.range,
                      minDate: minDate,
                      maxDate: maxDate,
                      initialSelectedRange: initialRange,
                      initialDisplayDate: displayDate,
                      showNavigationArrow: true,
                      showActionButtons: true,
                      confirmText: 'OK',
                      cancelText: 'Cancel',
                      backgroundColor: Colors.white,
                      headerStyle: DateRangePickerHeaderStyle(
                        backgroundColor: const Color(0xFFFAFAFA),
                        textStyle: const TextStyle(
                          color: headerFg,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      selectionColor: primary,
                      startRangeSelectionColor: primary,
                      endRangeSelectionColor: primary,
                      rangeSelectionColor: primary.withValues(alpha: 0.22),
                      todayHighlightColor: accent,
                      selectionTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      rangeTextStyle: const TextStyle(
                        color: onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      monthViewSettings: const DateRangePickerMonthViewSettings(
                        firstDayOfWeek: 1,
                        viewHeaderHeight: 32,
                        viewHeaderStyle: DateRangePickerViewHeaderStyle(
                          backgroundColor: Color(0xFFF2F2F2),
                          textStyle: TextStyle(
                            color: Color(0xFF5C5C5C),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onSubmit: (Object? value) {
                        if (value is PickerDateRange &&
                            value.startDate != null &&
                            value.endDate != null) {
                          Navigator.of(dialogContext).pop(
                            DateTimeRange(
                              start: value.startDate!,
                              end: value.endDate!,
                            ),
                          );
                          return;
                        }
                        Navigator.of(dialogContext).pop();
                      },
                      onCancel: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class GeneralUserExportPage extends StatefulWidget {
  const GeneralUserExportPage({super.key});

  @override
  State<GeneralUserExportPage> createState() => _GeneralUserExportPageState();
}

class _GeneralUserExportPageState extends State<GeneralUserExportPage> {
  bool _dateRangeSelected = false;
  bool _reportTypeSelected = false;
  bool _formatSelected = false;

  void _resetExportSteps() {
    if (!mounted) {
      return;
    }
    setState(() {
      _dateRangeSelected = false;
      _reportTypeSelected = false;
      _formatSelected = false;
    });
  }

  void _markDateRangeSelected() {
    if (!mounted) {
      return;
    }
    setState(() {
      _dateRangeSelected = true;
      _reportTypeSelected = false;
      _formatSelected = false;
    });
  }

  void _markReportTypeSelected() {
    if (!mounted) {
      return;
    }
    setState(() {
      _reportTypeSelected = true;
      _formatSelected = false;
    });
  }

  void _markFormatSelected() {
    if (!mounted) {
      return;
    }
    setState(() {
      _formatSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<GeneralUserExportBloc, GeneralUserExportState>(
              listenWhen: (previous, current) =>
                  previous.startLatitude != current.startLatitude ||
                  previous.startLongitude != current.startLongitude ||
                  previous.startTime != current.startTime,
              listener: (context, state) {
                if (state.reportType == ExportReportType.buoyDistance &&
                    !state.isDistanceStartPointComplete &&
                    _formatSelected) {
                  setState(() => _formatSelected = false);
                }
              },
            ),
            BlocListener<GeneralUserExportBloc, GeneralUserExportState>(
              listenWhen: (previous, current) =>
                  previous.message != current.message,
              listener: (context, state) {
                if (state.message.isEmpty) {
                  return;
                }
                if (state.isSuccessMessage) {
                  AppFlushbar.success(state.message, context: context);
                } else {
                  AppFlushbar.error(state.message, context: context);
                }
                context.read<GeneralUserExportBloc>().add(
                  const ClearGeneralUserExportMessage(),
                );
              },
            ),
            BlocListener<GeneralUserExportBloc, GeneralUserExportState>(
              listenWhen: (previous, current) =>
                  previous.mode != current.mode ||
                  previous.selectedBuoyIds != current.selectedBuoyIds ||
                  previous.buoyId != current.buoyId,
              listener: (context, state) {
                _resetExportSteps();
              },
            ),
            BlocListener<GeneralUserExportBloc, GeneralUserExportState>(
              listenWhen: (previous, current) =>
                  previous.status != GeneralUserExportStatus.exporting &&
                  current.status == GeneralUserExportStatus.exporting,
              listener: (context, state) {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  useRootNavigator: true,
                  builder: (dialogContext) => const _ExportingDataDialog(),
                );
              },
            ),
            BlocListener<GeneralUserExportBloc, GeneralUserExportState>(
              listenWhen: (previous, current) =>
                  previous.status == GeneralUserExportStatus.exporting &&
                  current.status != GeneralUserExportStatus.exporting,
              listener: (context, state) {
                final nav = Navigator.of(context, rootNavigator: true);
                if (nav.canPop()) {
                  nav.pop();
                }
              },
            ),
            BlocListener<GeneralUserExportBloc, GeneralUserExportState>(
              listenWhen: (previous, current) =>
                  current.deliverable != null &&
                  current.deliverable != previous.deliverable,
              listener: (context, state) async {
                final d = state.deliverable;
                if (d == null) {
                  return;
                }
                final bloc = context.read<GeneralUserExportBloc>();
                try {
                  if (d.forShare) {
                    await ExportDeliverableActions.share(
                      context: context,
                      bytes: d.bytes,
                      fileName: d.fileName,
                    );
                    if (context.mounted) {
                      AppFlushbar.success(
                        'Share sheet opened.',
                        context: context,
                      );
                    }
                  } else {
                    final savedPath =
                        await ExportDeliverableActions.saveToDevice(
                          bytes: d.bytes,
                          fileName: d.fileName,
                        );
                    if (context.mounted && savedPath != null) {
                      final opened = await ExportDeliverableActions.openSavedFile(
                        savedPath,
                      );
                      if (context.mounted) {
                        AppFlushbar.success(
                          opened
                              ? 'File saved and opened.'
                              : 'File saved.',
                          context: context,
                        );
                      }
                    }
                  }
                } on Object catch (e, st) {
                  AppLogger.e(
                    'Export deliverable listener',
                    error: e,
                    stackTrace: st,
                  );
                  if (context.mounted) {
                    AppFlushbar.error(
                      ExportDeliverableActions.userFacingMessage(e),
                      context: context,
                    );
                  }
                } finally {
                  bloc.add(const ClearGeneralUserExportDeliverable());
                }
              },
            ),
          ],
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    AppIconCircleButton(
                      onTap: () {
                        if (GoRouter.of(context).canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.dashboardPath);
                        }
                      },
                      icon: Icons.arrow_back,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Export',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xFF262C31),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<GeneralUserExportBloc, GeneralUserExportState>(
                  builder: (context, state) {
                    if (state.status == GeneralUserExportStatus.loading ||
                        state.status == GeneralUserExportStatus.initial) {
                      return const AppLoader();
                    }

                    if (state.status == GeneralUserExportStatus.error) {
                      return AppErrorView(
                        message: state.message,
                        onRetry: () {
                          context.read<GeneralUserExportBloc>().add(
                            LoadGeneralUserExport(
                              routeExtra: state.routeExtraSnapshot,
                            ),
                          );
                        },
                      );
                    }

                    final isExporting =
                        state.status == GeneralUserExportStatus.exporting;
                    final hideExportControls =
                        (state.mode == GeneralUserExportMode.buoyDistance &&
                            (state.isReportLoading ||
                                state.reportRows.isEmpty)) ||
                        (state.mode == GeneralUserExportMode.multiSelection &&
                            state.selectedBuoyIds.isNotEmpty &&
                            (state.isReportLoading ||
                                state.reportRows.isEmpty));

                    return Column(
                      children: [
                        Expanded(
                          child: _shouldShowExportNotice(state)
                              ? Column(
                                  children: [
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        8,
                                        16,
                                        16,
                                      ),
                                      child: Column(
                                        children: [
                                          ..._buildExportFormCards(
                                            context: context,
                                            state: state,
                                            isExporting: isExporting,
                                            hideExportControls:
                                                hideExportControls,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          24,
                                          8,
                                          24,
                                          24,
                                        ),
                                        child: Center(
                                          child: Text(
                                            state.buoyScreenNotice,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color:
                                                      const Color(0xFF5C5C5C),
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.35,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    16,
                                  ),
                                  child: Column(
                                    children: [
                                      ..._buildExportFormCards(
                                        context: context,
                                        state: state,
                                        isExporting: isExporting,
                                        hideExportControls: hideExportControls,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        if (!hideExportControls &&
                            _dateRangeSelected &&
                            _reportTypeSelected &&
                            _formatSelected &&
                            _shouldShowExportFormatSection(state) &&
                            (state.reportType == ExportReportType.buoyData ||
                                state.isDistanceStartPointReadyForExport))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: AppElevatedButton(
                                loading: isExporting,
                                onPressed:
                                    isExporting || _exportButtonDisabled(state)
                                    ? null
                                    : () {
                                        if (state.format ==
                                                ExportFormat.pdf &&
                                            state.reportRows.length >
                                                kExportPdfLargeRowWarningThreshold) {
                                          AppFlushbar.info(
                                            'Large report: PDF may take a minute. '
                                            'CSV export is faster for the full dataset.',
                                            title: 'Export',
                                            context: context,
                                          );
                                        }
                                        if (state.mode ==
                                            GeneralUserExportMode
                                                .buoyDistance) {
                                          context.read<GeneralUserExportBloc>().add(
                                            const ExportBuoyDistanceSaveToDevice(),
                                          );
                                        } else {
                                          context.read<GeneralUserExportBloc>().add(
                                            const ExportMultiBuoyDataSaveToDevice(),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF206BBE),
                                  disabledBackgroundColor: const Color(
                                    0xFF206BBE,
                                  ).withValues(alpha: 0.65),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Export Data',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExportFormCards({
    required BuildContext context,
    required GeneralUserExportState state,
    required bool isExporting,
    required bool hideExportControls,
  }) {
    return [
      _DateRangeCard(
        mode: state.mode,
        selected: state.dateRange,
        customStart: state.customStart,
        customEnd: state.customEnd,
        onChanged: isExporting
            ? null
            : (range) async {
                if (range == null) {
                  return;
                }
                if (range == ExportDateRange.custom) {
                  final picked = await showExportThemedDateRangePicker(
                    context: context,
                    initialDateRange: state.customStart != null &&
                            state.customEnd != null
                        ? DateTimeRange(
                            start: state.customStart!,
                            end: state.customEnd!,
                          )
                        : DateTimeRange(
                            start: DateTime.now().subtract(
                              const Duration(days: 7),
                            ),
                            end: DateTime.now(),
                          ),
                  );
                  if (!context.mounted || picked == null) {
                    return;
                  }
                  context.read<GeneralUserExportBloc>().add(
                        ApplyGeneralUserExportCustomRange(
                          start: picked.start,
                          end: picked.end,
                        ),
                      );
                  _markDateRangeSelected();
                  return;
                }
                if (!context.mounted) {
                  return;
                }
                context.read<GeneralUserExportBloc>().add(
                      ChangeGeneralUserExportDateRange(range),
                    );
                _markDateRangeSelected();
              },
      ),
      if (_dateRangeSelected) ...[
        const SizedBox(height: 10),
        _ReportTypeCard(
          selected: state.reportType,
          onChanged: isExporting
              ? null
              : (type) {
                  context.read<GeneralUserExportBloc>().add(
                        ChangeGeneralUserExportReportType(type),
                      );
                  _markReportTypeSelected();
                },
        ),
      ],
      if (_reportTypeSelected &&
          state.reportType == ExportReportType.buoyDistance &&
          !state.isMultiBuoyDistanceReportBlocked) ...[
        const SizedBox(height: 10),
        _DistanceStartPointCard(
          enabled: !isExporting,
          isLoading: state.isReportLoading,
          isSearching: state.isStartPointSearching,
          startPointType: state.distanceStartPointType,
          startLatitude: state.startLatitude,
          startLongitude: state.startLongitude,
          startTime: state.startTime,
        ),
      ],
      if ((state.mode == GeneralUserExportMode.buoyDistance ||
              (state.mode == GeneralUserExportMode.multiSelection &&
                  state.selectedBuoyIds.isNotEmpty)) &&
          state.isReportLoading) ...[
        const SizedBox(height: 24),
        const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
            ),
          ),
        ),
      ],
      if (!hideExportControls &&
          _dateRangeSelected &&
          _reportTypeSelected &&
          _shouldShowExportFormatSection(state)) ...[
        const SizedBox(height: 18),
        _ExportFormatCardSection(
          selectedFormat: state.format,
          reportColumns: state.reportColumns,
          reportRows: state.reportRows,
          enabled: !isExporting,
          onFormatChanged: (format) {
            context.read<GeneralUserExportBloc>().add(
                  ChangeGeneralUserExportFormat(format),
                );
            _markFormatSelected();
          },
        ),
      ],
    ];
  }

  bool _shouldShowExportFormatSection(GeneralUserExportState state) {
    if (state.reportType == ExportReportType.buoyData) {
      return true;
    }
    if (state.reportType != ExportReportType.buoyDistance) {
      return false;
    }
    if (state.isMultiBuoyDistanceReportBlocked) {
      return false;
    }
    return state.isDistanceStartPointComplete;
  }

  bool _shouldShowExportNotice(GeneralUserExportState state) {
    if (state.buoyScreenNotice.isEmpty) {
      return false;
    }

    return state.mode == GeneralUserExportMode.buoyDistance ||
        (state.mode == GeneralUserExportMode.multiSelection &&
            (state.selectedBuoyIds.isNotEmpty ||
                state.isMultiBuoyDistanceReportBlocked));
  }

  bool _exportButtonDisabled(GeneralUserExportState state) {
    if (state.mode == GeneralUserExportMode.buoyDistance) {
      if (state.buoyId == null || state.buoyId!.isEmpty) {
        return true;
      }
    } else if (state.mode == GeneralUserExportMode.multiSelection) {
      if (state.selectedBuoyIds.isEmpty) {
        return true;
      }
    }
    if (state.dateRange == ExportDateRange.custom &&
        (state.customStart == null || state.customEnd == null)) {
      return true;
    }
    if (state.dateRange == null || state.reportType == null || state.format == null) {
      return true;
    }
    if (state.reportType == ExportReportType.buoyDistance &&
        !state.isDistanceStartPointReadyForExport) {
      return true;
    }
    return false;
  }
}

class _DateRangeCard extends StatelessWidget {
  final GeneralUserExportMode mode;
  final ExportDateRange? selected;
  final DateTime? customStart;
  final DateTime? customEnd;
  final Future<void> Function(ExportDateRange?)? onChanged;

  const _DateRangeCard({
    required this.mode,
    required this.selected,
    required this.onChanged,
    this.customStart,
    this.customEnd,
  });

  @override
  Widget build(BuildContext context) {
    final items = const [
      ExportDateRange.currentDay,
      ExportDateRange.yesterday,
      ExportDateRange.custom,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date Range',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF30353A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          AppCommonDropdown<ExportDateRange>(
            value: items.contains(selected) ? selected : null,
            items: items,
            itemLabelBuilder: _dateRangeLabel,
            placeholder: 'Select Date Range',
            onChanged: onChanged == null
                ? null
                : (value) {
                    onChanged!(value);
                  },
          ),
          if (selected == ExportDateRange.custom &&
              customStart != null &&
              customEnd != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF2A86CE).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.date_range_rounded,
                    size: 20,
                    color: Color(0xFF206BBE),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_formatExportDisplayDate(customStart!)}  –  ${_formatExportDisplayDate(customEnd!)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF30353A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _dateRangeLabel(ExportDateRange range) {
    switch (range) {
      case ExportDateRange.currentDay:
        return 'Current day';
      case ExportDateRange.yesterday:
        return 'Yesterday';
      case ExportDateRange.custom:
        return 'Custom Range';
    }
  }
}

class _ExportFormatCardSection extends StatelessWidget {
  final ExportFormat? selectedFormat;
  final List<String> reportColumns;
  final List<Map<String, String>> reportRows;
  final bool enabled;
  final ValueChanged<ExportFormat> onFormatChanged;

  const _ExportFormatCardSection({
    required this.selectedFormat,
    required this.reportColumns,
    required this.reportRows,
    required this.enabled,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    final csvSize = _estimateSize(isCsv: true);
    final pdfSize = _estimateSize(isCsv: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Select Export Format',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF30353A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          IgnorePointer(
            ignoring: !enabled,
            child: Opacity(
              opacity: enabled ? 1 : 0.7,
              child: Row(
                children: [
                  AppExportFormatCard(
                    title: 'CSV',
                    subtitle: 'Comma Separated Values',
                    fileSize: csvSize,
                    icon: Icons.description_rounded,
                    iconColor: const Color(0xFF24A55B),
                    selected: selectedFormat == ExportFormat.csv,
                    onTap: () => onFormatChanged(ExportFormat.csv),
                  ),
                  const SizedBox(width: 8),
                  AppExportFormatCard(
                    title: 'PDF',
                    subtitle: 'Portable Document\nFormat',
                    fileSize: pdfSize,
                    icon: Icons.picture_as_pdf_rounded,
                    iconColor: const Color(0xFFE53935),
                    selected: selectedFormat == ExportFormat.pdf,
                    onTap: () => onFormatChanged(ExportFormat.pdf),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _estimateSize({required bool isCsv}) {
    if (reportRows.isEmpty) {
      return isCsv ? '~2 KB' : '~8 KB';
    }
    final order = _columnOrderForEstimate();
    if (order.isEmpty) {
      return isCsv ? '~2 KB' : '~8 KB';
    }
    final csvBytes = _estimateCsvUtf8Bytes(
      columnOrder: order,
      rows: reportRows,
    );
    final bytes = isCsv
        ? csvBytes
        : _estimatePdfBytesFromTable(
            csvUtf8Bytes: csvBytes,
            rowCount: reportRows.length,
            columnCount: order.length,
          );
    return _formatApproxFileSize(bytes);
  }

  List<String> _columnOrderForEstimate() {
    if (reportColumns.isNotEmpty) {
      return reportColumns;
    }
    if (reportRows.isEmpty) {
      return const [];
    }
    return reportRows.first.keys.toList(growable: false);
  }
}

class _DistanceStartPointCard extends StatefulWidget {
  const _DistanceStartPointCard({
    required this.enabled,
    required this.isLoading,
    required this.isSearching,
    required this.startPointType,
    required this.startLatitude,
    required this.startLongitude,
    required this.startTime,
  });

  final bool enabled;
  final bool isLoading;
  final bool isSearching;
  final ExportDistanceStartPointType? startPointType;
  final String startLatitude;
  final String startLongitude;
  final String startTime;

  @override
  State<_DistanceStartPointCard> createState() =>
      _DistanceStartPointCardState();
}

class _DistanceStartPointCardState extends State<_DistanceStartPointCard> {
  late final TextEditingController _searchController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  String _selectedTime = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _latController = TextEditingController(text: widget.startLatitude);
    _lngController = TextEditingController(text: widget.startLongitude);
    _selectedTime = widget.startTime;
  }

  @override
  void didUpdateWidget(covariant _DistanceStartPointCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startPointType != widget.startPointType) {
      _searchController.clear();
      _latController.text = '';
      _lngController.text = '';
      _selectedTime = '';
    } else {
      var synced = false;
      if (_latController.text != widget.startLatitude) {
        _latController.text = widget.startLatitude;
        synced = true;
      }
      if (_lngController.text != widget.startLongitude) {
        _lngController.text = widget.startLongitude;
        synced = true;
      }
      if (synced) {
        setState(() {});
      }
      if (widget.startTime.isNotEmpty && _selectedTime != widget.startTime) {
        _selectedTime = widget.startTime;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  bool get _isBusy => widget.isLoading || widget.isSearching;

  bool get _canSubmit {
    final type = widget.startPointType;
    if (type == null || !widget.enabled || _isBusy) {
      return false;
    }
    switch (type) {
      case ExportDistanceStartPointType.latLng:
        return _latController.text.trim().isNotEmpty &&
            _lngController.text.trim().isNotEmpty;
      case ExportDistanceStartPointType.time:
        return _selectedTime.trim().isNotEmpty;
    }
  }

  bool get _canSearch {
    if (!widget.enabled || _isBusy) {
      return false;
    }
    if (widget.startPointType != ExportDistanceStartPointType.latLng) {
      return false;
    }
    return _searchController.text.trim().isNotEmpty;
  }

  void _onSearchFieldChanged(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {});
      return;
    }

    _latController.clear();
    _lngController.clear();
    context.read<GeneralUserExportBloc>().add(
          const ClearGeneralUserExportStartPointLatLng(),
        );
    setState(() {});
  }

  void _search() {
    FocusScope.of(context).unfocus();

    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _onSearchFieldChanged('');
      return;
    }

    context.read<GeneralUserExportBloc>().add(
          SearchGeneralUserExportByLatLon(latLng: query),
        );
  }

  void _submit() {
    final type = widget.startPointType;
    if (type == null) {
      return;
    }

    FocusScope.of(context).unfocus();

    switch (type) {
      case ExportDistanceStartPointType.latLng:
        final lat = _latController.text.trim();
        final lng = _lngController.text.trim();
        if (lat.isEmpty || lng.isEmpty) {
          AppFlushbar.error(
            'Please enter Latitude and Longitude.',
            context: context,
          );
          return;
        }
        context.read<GeneralUserExportBloc>().add(
              SubmitGeneralUserExportDistanceStartPoint(
                startLatitude: lat,
                startLongitude: lng,
                startTime: '',
              ),
            );
      case ExportDistanceStartPointType.time:
        final time = _selectedTime.trim();
        if (time.isEmpty) {
          AppFlushbar.error('Please select Start Time.', context: context);
          return;
        }
        context.read<GeneralUserExportBloc>().add(
              SubmitGeneralUserExportDistanceStartPoint(
                startLatitude: '',
                startLongitude: '',
                startTime: time,
              ),
            );
    }
  }

  Future<void> _pickStartTime() async {
    if (!widget.enabled || _isBusy) {
      return;
    }
    TimeOfDay initial = TimeOfDay.now();
    if (_selectedTime.trim().isNotEmpty) {
      final parts = _selectedTime.trim().split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          initial = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _selectedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final type = widget.startPointType;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start Point',
            style: textTheme.titleMedium?.copyWith(
              color: const Color(0xFF30353A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Required for Buoy Distance Report',
            style: textTheme.bodySmall?.copyWith(
              color: const Color(0xFF616870),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          RadioListTile<ExportDistanceStartPointType>(
            value: ExportDistanceStartPointType.latLng,
            groupValue: type,
            onChanged: widget.enabled
                ? (value) {
                    if (value == null) {
                      return;
                    }
                    context.read<GeneralUserExportBloc>().add(
                          ChangeGeneralUserExportDistanceStartPointType(value),
                        );
                  }
                : null,
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              'Latitude & Longitude',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2A2F34),
              ),
            ),
          ),
          if (type == ExportDistanceStartPointType.latLng) ...[
            const SizedBox(height: 4),
            Text(
              'Search',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3F4750),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    enabled: widget.enabled && !_isBusy,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [
                      _DecimalDigitInputFormatter(),
                    ],
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) {
                      if (_canSearch) {
                        _search();
                      }
                    },
                    onChanged: _onSearchFieldChanged,
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF23282D),
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter latitude or longitude',
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8A9095),
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFC2C7CC)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3A86D1),
                          width: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 52,
                  height: 48,
                  child: AppElevatedButton(
                    loading: widget.isSearching,
                    onPressed: _canSearch ? _search : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF256BBB),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF256BBB).withValues(alpha: 0.45),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: widget.isSearching
                        ? const SizedBox.shrink()
                        : const Icon(Icons.search_rounded, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DistanceCoordinateField(
              label: 'Latitude',
              controller: _latController,
              enabled: widget.enabled && !_isBusy,
              readOnly: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            _DistanceCoordinateField(
              label: 'Longitude',
              controller: _lngController,
              enabled: widget.enabled && !_isBusy,
              readOnly: true,
              onChanged: (_) => setState(() {}),
            ),
            if (_canSubmit) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: AppElevatedButton(
                  loading: widget.isLoading,
                  onPressed: widget.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF256BBB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ],
          RadioListTile<ExportDistanceStartPointType>(
            value: ExportDistanceStartPointType.time,
            groupValue: type,
            onChanged: widget.enabled
                ? (value) {
                    if (value == null) {
                      return;
                    }
                    context.read<GeneralUserExportBloc>().add(
                          ChangeGeneralUserExportDistanceStartPointType(value),
                        );
                  }
                : null,
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              'Start Time',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2A2F34),
              ),
            ),
          ),
          if (type == ExportDistanceStartPointType.time) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: widget.enabled ? _pickStartTime : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC2C7CC)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFF356EA7),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedTime.trim().isNotEmpty
                            ? _selectedTime.trim()
                            : 'Select start time (HH:mm)',
                        style: textTheme.bodyMedium?.copyWith(
                          color: _selectedTime.trim().isNotEmpty
                              ? const Color(0xFF2A2F34)
                              : const Color(0xFF8A9095),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF8A9095),
                    ),
                  ],
                ),
              ),
            ),
            if (_canSubmit) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: AppElevatedButton(
                  loading: widget.isLoading,
                  onPressed: widget.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF256BBB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _DistanceCoordinateField extends StatelessWidget {
  const _DistanceCoordinateField({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.onChanged,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3F4750),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          enabled: enabled,
          readOnly: readOnly,
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          onChanged: onChanged,
          style: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF23282D),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC2C7CC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF3A86D1),
                width: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportTypeCard extends StatelessWidget {
  const _ReportTypeCard({required this.selected, required this.onChanged});

  final ExportReportType? selected;
  final ValueChanged<ExportReportType>? onChanged;

  @override
  Widget build(BuildContext context) {
    final options = const [
      ExportReportType.buoyData,
      ExportReportType.buoyDistance,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Report Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF30353A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          AppCommonDropdown<ExportReportType>(
            value: selected,
            items: options,
            itemLabelBuilder: (type) => type == ExportReportType.buoyData
                ? 'Buoy Data Report'
                : 'Buoy Distance Report',
            placeholder: 'Select Report Type',
            onChanged: onChanged == null
                ? null
                : (value) {
                    if (value != null) {
                      onChanged!(value);
                    }
                  },
          ),
        ],
      ),
    );
  }
}

/// Rough UTF-8 byte count for CSV shaped like [buildDynamicCsv] (slack for quoting).
int _estimateCsvUtf8Bytes({
  required List<String> columnOrder,
  required List<Map<String, String>> rows,
}) {
  var n = 0;
  for (final h in columnOrder) {
    n += h.length + 1;
  }
  n += 1;
  for (final row in rows) {
    for (final k in columnOrder) {
      final v = row[k] ?? '';
      n += v.length + 1;
    }
    n += 1;
  }
  return (n * 1.12).ceil();
}

/// Heuristic PDF output size from tabular data (fonts, layout, binary overhead).
int _estimatePdfBytesFromTable({
  required int csvUtf8Bytes,
  required int rowCount,
  required int columnCount,
}) {
  final base = 4500 + columnCount * 120;
  final rowTerm = rowCount * (180 + columnCount * 35);
  final fromCsv = (csvUtf8Bytes * 2.4).round();
  return base + rowTerm > fromCsv ? base + rowTerm : fromCsv;
}

String _formatApproxFileSize(int bytes) {
  if (bytes < 1024) {
    return '~$bytes B';
  }
  final kb = bytes / 1024;
  if (kb < 1024) {
    return '~${kb.toStringAsFixed(1)} KB';
  }
  return '~${(kb / 1024).toStringAsFixed(1)} MB';
}

class _DecimalDigitInputFormatter extends TextInputFormatter {
  const _DecimalDigitInputFormatter();

  static final RegExp _allowedPattern = RegExp(r'^\d*\.?\d*');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    if (_allowedPattern.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

class _ExportingDataDialog extends StatelessWidget {
  const _ExportingDataDialog();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 22),
            Text(
              'Exporting your data .....',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF30353A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please wait',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF5C5C5C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
