import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/export_deliverable_actions.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_export_format_card.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_elevated_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserExportPage extends StatelessWidget {
  const GeneralUserExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
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
                    final saved = await ExportDeliverableActions.saveToDevice(
                      bytes: d.bytes,
                      fileName: d.fileName,
                    );
                    if (context.mounted && saved) {
                      AppFlushbar.success('File saved.', context: context);
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
                    final hideBuoyExportControls =
                        state.mode == GeneralUserExportMode.buoyDistance &&
                        (state.isReportLoading || state.reportRows.isEmpty);

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Column(
                              children: [
                                _DateRangeCard(
                                  mode: state.mode,
                                  selected: state.dateRange,
                                  onChanged: isExporting
                                      ? null
                                      : (range) async {
                                          if (range == null) {
                                            return;
                                          }
                                          if (range == ExportDateRange.custom) {
                                            final picked =
                                                await showDateRangePicker(
                                                  context: context,
                                                  firstDate: DateTime(2020),
                                                  lastDate: DateTime.now().add(
                                                    const Duration(days: 365),
                                                  ),
                                                  initialDateRange:
                                                      state.customStart !=
                                                              null &&
                                                          state.customEnd !=
                                                              null
                                                      ? DateTimeRange(
                                                          start: state
                                                              .customStart!,
                                                          end: state.customEnd!,
                                                        )
                                                      : DateTimeRange(
                                                          start: DateTime.now()
                                                              .subtract(
                                                                const Duration(
                                                                  days: 7,
                                                                ),
                                                              ),
                                                          end: DateTime.now(),
                                                        ),
                                                );
                                            if (!context.mounted ||
                                                picked == null) {
                                              return;
                                            }
                                            context
                                                .read<GeneralUserExportBloc>()
                                                .add(
                                                  ApplyGeneralUserExportCustomRange(
                                                    start: picked.start,
                                                    end: picked.end,
                                                  ),
                                                );
                                            return;
                                          }
                                          if (!context.mounted) {
                                            return;
                                          }
                                          context
                                              .read<GeneralUserExportBloc>()
                                              .add(
                                                ChangeGeneralUserExportDateRange(
                                                  range,
                                                ),
                                              );
                                        },
                                ),
                                if (state.mode ==
                                        GeneralUserExportMode.buoyDistance &&
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
                                if (state.mode ==
                                        GeneralUserExportMode.buoyDistance &&
                                    state.buoyScreenNotice.isNotEmpty) ...[
                                  const SizedBox(height: 20),
                                  Text(
                                    state.buoyScreenNotice,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: const Color(0xFF5C5C5C),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                                if (!hideBuoyExportControls) ...[
                                  const SizedBox(height: 18),
                                  _ExportFormatCardSection(
                                    mode: state.mode,
                                    selectedFormat: state.format,
                                    selectedRange: state.dateRange,
                                    rowCount: state.reportRows.length,
                                    enabled: !isExporting,
                                    onFormatChanged: (format) {
                                      context.read<GeneralUserExportBloc>().add(
                                        ChangeGeneralUserExportFormat(format),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (!hideBuoyExportControls)
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
                                        if (state.mode ==
                                            GeneralUserExportMode
                                                .buoyDistance) {
                                          _showBuoyExportConfirmDialog(context);
                                        } else {
                                          context
                                              .read<GeneralUserExportBloc>()
                                              .add(
                                                const SubmitGeneralUserExport(),
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

  bool _exportButtonDisabled(GeneralUserExportState state) {
    if (state.mode != GeneralUserExportMode.buoyDistance) {
      return false;
    }
    if (state.buoyId == null || state.buoyId!.isEmpty) {
      return true;
    }
    if (state.dateRange == ExportDateRange.custom &&
        (state.customStart == null || state.customEnd == null)) {
      return true;
    }
    return false;
  }

  Future<void> _showBuoyExportConfirmDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Export report'),
          content: const Text(
            'Are you sure you want to export this report? Choose how to send the file.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<GeneralUserExportBloc>().add(
                  const ExportBuoyDistanceShare(),
                );
              },
              child: const Text('Share'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<GeneralUserExportBloc>().add(
                  const ExportBuoyDistanceSaveToDevice(),
                );
              },
              child: const Text('Download'),
            ),
          ],
        );
      },
    );
  }
}

class _DateRangeCard extends StatelessWidget {
  final GeneralUserExportMode mode;
  final ExportDateRange selected;
  final Future<void> Function(ExportDateRange?)? onChanged;

  const _DateRangeCard({
    required this.mode,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = mode == GeneralUserExportMode.buoyDistance
        ? const [
            ExportDateRange.yesterday,
            ExportDateRange.last24Hours,
            ExportDateRange.custom,
          ]
        : const [
            ExportDateRange.last24Hours,
            ExportDateRange.last7Days,
            ExportDateRange.last30Days,
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
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2A86CE), width: 1.4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ExportDateRange>(
                value: items.contains(selected) ? selected : items.first,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF272C31),
                  size: 30,
                ),
                borderRadius: BorderRadius.circular(10),
                dropdownColor: Colors.white,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF353A3F),
                  fontWeight: FontWeight.w600,
                ),
                items: items
                    .map(
                      (range) => DropdownMenuItem<ExportDateRange>(
                        value: range,
                        child: Text(_dateRangeLabel(range)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: onChanged == null
                    ? null
                    : (value) {
                        onChanged!(value);
                      },
              ),
            ),
          ),
        ],
      ),
    );
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

class _ExportFormatCardSection extends StatelessWidget {
  final GeneralUserExportMode mode;
  final ExportFormat selectedFormat;
  final ExportDateRange selectedRange;
  final int rowCount;
  final bool enabled;
  final ValueChanged<ExportFormat> onFormatChanged;

  const _ExportFormatCardSection({
    required this.mode,
    required this.selectedFormat,
    required this.selectedRange,
    required this.rowCount,
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
    if (mode == GeneralUserExportMode.multiSelection) {
      return _legacySizePlaceholder(isCsv: isCsv);
    }
    if (rowCount <= 0) {
      return isCsv ? '~2 KB' : '~8 KB';
    }
    final perRow = isCsv ? 80 : 220;
    final bytes = rowCount * perRow + 500;
    if (bytes < 1024) {
      return '$bytes B';
    }
    final kb = bytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  String _legacySizePlaceholder({required bool isCsv}) {
    switch (selectedRange) {
      case ExportDateRange.last24Hours:
        return isCsv ? '2.4 MB' : '6.4 MB';
      case ExportDateRange.yesterday:
        return isCsv ? '2.2 MB' : '6.0 MB';
      case ExportDateRange.last7Days:
        return isCsv ? '7.8 MB' : '12.9 MB';
      case ExportDateRange.last30Days:
        return isCsv ? '18.3 MB' : '29.1 MB';
      case ExportDateRange.custom:
        return isCsv ? '5.9 MB' : '9.5 MB';
    }
  }
}
