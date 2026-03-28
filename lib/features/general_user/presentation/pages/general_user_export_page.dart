import 'package:drifter_buoy/core/constants/app_routes.dart';
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
        child: BlocListener<GeneralUserExportBloc, GeneralUserExportState>(
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
                            const LoadGeneralUserExport(),
                          );
                        },
                      );
                    }

                    final isExporting =
                        state.status == GeneralUserExportStatus.exporting;

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Column(
                              children: [
                                _DateRangeCard(
                                  selected: state.dateRange,
                                  onChanged: isExporting
                                      ? null
                                      : (range) {
                                          context
                                              .read<GeneralUserExportBloc>()
                                              .add(
                                                ChangeGeneralUserExportDateRange(
                                                  range,
                                                ),
                                              );
                                        },
                                ),
                                const SizedBox(height: 18),
                                _ExportFormatCardSection(
                                  selectedFormat: state.format,
                                  selectedRange: state.dateRange,
                                  enabled: !isExporting,
                                  onFormatChanged: (format) {
                                    context.read<GeneralUserExportBloc>().add(
                                      ChangeGeneralUserExportFormat(format),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: AppElevatedButton(
                              loading: isExporting,
                              onPressed: isExporting
                                  ? null
                                  : () {
                                      context
                                          .read<GeneralUserExportBloc>()
                                          .add(
                                            const SubmitGeneralUserExport(),
                                          );
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
}

class _DateRangeCard extends StatelessWidget {
  final ExportDateRange selected;
  final ValueChanged<ExportDateRange>? onChanged;

  const _DateRangeCard({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
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
                value: selected,
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
                items: ExportDateRange.values
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
                        if (value == null) {
                          return;
                        }
                        onChanged?.call(value);
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
  final ExportFormat selectedFormat;
  final ExportDateRange selectedRange;
  final bool enabled;
  final ValueChanged<ExportFormat> onFormatChanged;

  const _ExportFormatCardSection({
    required this.selectedFormat,
    required this.selectedRange,
    required this.enabled,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    final csvSize = _csvSizeByRange(selectedRange);
    final pdfSize = _pdfSizeByRange(selectedRange);

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

  String _csvSizeByRange(ExportDateRange range) {
    switch (range) {
      case ExportDateRange.last24Hours:
        return '2.4 MB';
      case ExportDateRange.last7Days:
        return '7.8 MB';
      case ExportDateRange.last30Days:
        return '18.3 MB';
      case ExportDateRange.custom:
        return '5.9 MB';
    }
  }

  String _pdfSizeByRange(ExportDateRange range) {
    switch (range) {
      case ExportDateRange.last24Hours:
        return '6.4 MB';
      case ExportDateRange.last7Days:
        return '12.9 MB';
      case ExportDateRange.last30Days:
        return '29.1 MB';
      case ExportDateRange.custom:
        return '9.5 MB';
    }
  }
}
