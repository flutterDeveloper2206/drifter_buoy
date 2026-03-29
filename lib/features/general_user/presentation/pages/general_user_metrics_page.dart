import 'dart:math' as math;

import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_export_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserMetricsPage extends StatelessWidget {
  const GeneralUserMetricsPage({
    super.key,
    this.focusBatterySection = false,
  });

  /// When true, scroll to the battery voltage section after data loads.
  final bool focusBatterySection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: BlocBuilder<GeneralUserMetricsBloc, GeneralUserMetricsState>(
          builder: (context, state) {
            return switch (state.status) {
              GeneralUserMetricsStatus.initial ||
              GeneralUserMetricsStatus.loading =>
                const AppLoader(),
              GeneralUserMetricsStatus.error => AppErrorView(
                message: state.message,
                onRetry: () {
                  context.read<GeneralUserMetricsBloc>().add(
                    LoadGeneralUserMetrics(buoyId: state.buoyId),
                  );
                },
              ),
              GeneralUserMetricsStatus.loaded => _MetricsLoadedBody(
                state: state,
                focusBatterySection: focusBatterySection,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _MetricsLoadedBody extends StatefulWidget {
  const _MetricsLoadedBody({
    required this.state,
    this.focusBatterySection = false,
  });

  final GeneralUserMetricsState state;
  final bool focusBatterySection;

  @override
  State<_MetricsLoadedBody> createState() => _MetricsLoadedBodyState();
}

class _MetricsLoadedBodyState extends State<_MetricsLoadedBody> {
  final GlobalKey _batterySectionKey = GlobalKey();
  bool _didScrollToBattery = false;
  int _batteryScrollAttempts = 0;

  @override
  void initState() {
    super.initState();
    if (widget.focusBatterySection) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollBatteryIntoView());
    }
  }

  @override
  void didUpdateWidget(covariant _MetricsLoadedBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusBatterySection &&
        !oldWidget.focusBatterySection &&
        !_didScrollToBattery) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollBatteryIntoView());
    }
  }

  void _scrollBatteryIntoView() {
    if (!widget.focusBatterySection || _didScrollToBattery || !mounted) {
      return;
    }
    final ctx = _batterySectionKey.currentContext;
    if (ctx == null) {
      _batteryScrollAttempts++;
      if (_batteryScrollAttempts > 24) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollBatteryIntoView());
      return;
    }
    _didScrollToBattery = true;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.12,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = widget.state;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppIconCircleButton(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
                icon: Icons.arrow_back,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Metrics',
                    style: textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2A2F34),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          _WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Date Range',
                  style: textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF2E3238),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF6BA3E8)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<GeneralUserMetricsDateRange>(
                      value: state.dateRange,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      style: textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF2E3238),
                        fontWeight: FontWeight.w600,
                      ),
                      items: GeneralUserMetricsDateRange.values
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(_dateRangeLabel(r)),
                            ),
                          )
                          .toList(),
                      onChanged: (range) async {
                        if (range == null) return;
                        if (range == GeneralUserMetricsDateRange.custom) {
                          final picked =
                              await showExportThemedDateRangePicker(
                            context: context,
                            description:
                                'Choose start and end dates for metrics.',
                            initialDateRange:
                                state.customStart != null &&
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
                          context.read<GeneralUserMetricsBloc>().add(
                                ApplyGeneralUserMetricsCustomRange(
                                  start: picked.start,
                                  end: picked.end,
                                ),
                              );
                          return;
                        }
                        if (!context.mounted) return;
                        context.read<GeneralUserMetricsBloc>().add(
                              ChangeGeneralUserMetricsDateRange(range),
                            );
                      },
                    ),
                  ),
                ),
                if (state.dateRange == GeneralUserMetricsDateRange.custom &&
                    state.customStart != null &&
                    state.customEnd != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF6BA3E8).withValues(alpha: 0.45),
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
                            '${_formatMetricsDisplayDate(state.customStart!)}  –  ${_formatMetricsDisplayDate(state.customEnd!)}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF2E3238),
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
          ),
          const SizedBox(height: 16),
          KeyedSubtree(
            key: _batterySectionKey,
            child: _WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.battery_std_rounded,
                        size: 22,
                        color: Colors.grey.shade800,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Battery voltage',
                        style: textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF2E3238),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Text(
                  state.batteryVoltage,
                  style: textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF1D2329),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: state.batteryPoints.isEmpty
                      ? Center(
                          child: Text(
                            'No chart data',
                            style: textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF70757A),
                            ),
                          ),
                        )
                      : _BatteryAreaChart(
                          points: state.batteryPoints,
                          xLabels: state.xAxisLabels,
                        ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

String _dateRangeLabel(GeneralUserMetricsDateRange range) {
  return switch (range) {
    GeneralUserMetricsDateRange.last24Hours => 'Last 24 Hrs',
    GeneralUserMetricsDateRange.last7Days => 'Last 7 Days',
    GeneralUserMetricsDateRange.last30Days => 'Last 30 Days',
    GeneralUserMetricsDateRange.custom => 'Custom',
  };
}

String _formatMetricsDisplayDate(DateTime d) {
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

class _BatteryAreaChart extends StatelessWidget {
  const _BatteryAreaChart({
    required this.points,
    required this.xLabels,
  });

  final List<double> points;
  final List<String> xLabels;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i]),
    ];

    final minYVal = points.reduce(math.min);
    final maxYVal = points.reduce(math.max);
    var pad = (maxYVal - minYVal) * 0.12;
    if (pad < 0.08) pad = 0.08;
    final minY = minYVal - pad;
    final maxY = maxYVal + pad;

    final n = points.length;
    final maxX = math.max(0, n - 1).toDouble();
    final labelDenom = math.max(1, xLabels.length - 1);

    const lineOrange = Color(0xFFFF7A1A);
    const fillTop = Color(0xFFFF9A3C);

    return LineChart(
      LineChartData(
        clipData: const FlClipData.all(),
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: false,
          drawVerticalLine: true,
          verticalInterval: 1,
          checkToShowVerticalLine: (value) {
            if (n <= 1 || xLabels.isEmpty) return false;
            final vi = value.round();
            for (var j = 0; j < xLabels.length; j++) {
              final xTarget = (j * (n - 1) / labelDenom).round();
              if (vi == xTarget) return true;
            }
            return false;
          },
          getDrawingVerticalLine: (_) => FlLine(
            color: const Color(0xFFB8BEC4).withValues(alpha: 0.55),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (n <= 1 || xLabels.isEmpty) {
                  return const SizedBox.shrink();
                }
                final vi = value.round();
                for (var j = 0; j < xLabels.length; j++) {
                  final xTarget = (j * (n - 1) / labelDenom).round();
                  if (vi == xTarget) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        xLabels[j],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF5C6368),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.32,
            color: lineOrange,
            barWidth: 2.8,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  fillTop.withValues(alpha: 0.42),
                  fillTop.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}
