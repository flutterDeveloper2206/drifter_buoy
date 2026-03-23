import 'dart:math' as math;

import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserMetricsPage extends StatelessWidget {
  const GeneralUserMetricsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child:
                  BlocBuilder<GeneralUserMetricsBloc, GeneralUserMetricsState>(
                    builder: (context, state) {
                      if (state.status == GeneralUserMetricsStatus.loading ||
                          state.status == GeneralUserMetricsStatus.initial) {
                        return const AppLoader();
                      }

                      if (state.status == GeneralUserMetricsStatus.error) {
                        return AppErrorView(
                          message: state.message,
                          onRetry: () {
                            context.read<GeneralUserMetricsBloc>().add(
                              LoadGeneralUserMetrics(buoyId: state.buoyId),
                            );
                          },
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                        child: Column(
                          children: [
                            _DateRangeCard(
                              selected: state.dateRange,
                              onChanged: (range) {
                                context.read<GeneralUserMetricsBloc>().add(
                                  ChangeGeneralUserMetricsDateRange(range),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            _BatteryChartCard(
                              batteryValue: state.batteryVoltage,
                              points: state.batteryPoints,
                              xAxisLabels: state.xAxisLabels,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          AppIconCircleButton(
            onTap: () {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.buoyOverviewPath);
              }
            },
            icon: Icons.arrow_back,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Metrics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF272C31),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _DateRangeCard extends StatelessWidget {
  final GeneralUserMetricsDateRange selected;
  final ValueChanged<GeneralUserMetricsDateRange> onChanged;

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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF30353A),
              fontWeight: FontWeight.w700,
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
              child: DropdownButton<GeneralUserMetricsDateRange>(
                value: selected,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF272C31),
                  size: 30,
                ),
                borderRadius: BorderRadius.circular(10),
                dropdownColor: Colors.white,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF353A3F),
                  fontWeight: FontWeight.w600,
                ),
                items: GeneralUserMetricsDateRange.values
                    .map(
                      (range) => DropdownMenuItem<GeneralUserMetricsDateRange>(
                        value: range,
                        child: Text(_dateRangeLabel(range)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  onChanged(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dateRangeLabel(GeneralUserMetricsDateRange range) {
    switch (range) {
      case GeneralUserMetricsDateRange.last24Hours:
        return 'Last 24 Hrs';
      case GeneralUserMetricsDateRange.last7Days:
        return 'Last 7 Days';
      case GeneralUserMetricsDateRange.last30Days:
        return 'Last 30 Days';
      case GeneralUserMetricsDateRange.custom:
        return 'Custom Range';
    }
  }
}

class _BatteryChartCard extends StatelessWidget {
  final String batteryValue;
  final List<double> points;
  final List<String> xAxisLabels;

  const _BatteryChartCard({
    required this.batteryValue,
    required this.points,
    required this.xAxisLabels,
  });

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
          Row(
            children: [
              const Icon(
                Icons.battery_5_bar_rounded,
                size: 19,
                color: Color(0xFF4A4A4A),
              ),
              const SizedBox(width: 4),
              Text(
                'Battery',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF34393E),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            batteryValue,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF2C3136),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 310,
            child: points.isEmpty
                ? Center(
                    child: Text(
                      'No battery data available.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF70757A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : _BatteryChart(points: points, labels: xAxisLabels),
          ),
        ],
      ),
    );
  }
}

class _BatteryChart extends StatelessWidget {
  final List<double> points;
  final List<String> labels;

  const _BatteryChart({required this.points, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _VerticalDashedGridPainter(
                      verticalCount: math.max(labels.length, 2),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(painter: _BatteryLineChartPainter(points)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map(
                  (label) => Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF5B6166),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 2),
      ],
    );
  }
}

class _VerticalDashedGridPainter extends CustomPainter {
  final int verticalCount;

  const _VerticalDashedGridPainter({required this.verticalCount});

  @override
  void paint(Canvas canvas, Size size) {
    if (verticalCount <= 1 || size.width <= 0 || size.height <= 0) {
      return;
    }

    final paint = Paint()
      ..color = const Color(0xFFD6D7D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final dash = 6.0;
    final gap = 5.0;
    final step = size.width / (verticalCount - 1);

    for (var i = 0; i < verticalCount; i++) {
      final x = i * step;
      var y = 0.0;
      while (y < size.height) {
        final y2 = math.min(y + dash, size.height);
        canvas.drawLine(Offset(x, y), Offset(x, y2), paint);
        y += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalDashedGridPainter oldDelegate) {
    return oldDelegate.verticalCount != verticalCount;
  }
}

class _BatteryLineChartPainter extends CustomPainter {
  final List<double> points;

  const _BatteryLineChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2 || size.width <= 0 || size.height <= 0) {
      return;
    }

    final minV = points.reduce(math.min);
    final maxV = points.reduce(math.max);
    final safeRange = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);

    final topPad = 8.0;
    final bottomPad = 12.0;
    final usableHeight = math.max(1.0, size.height - topPad - bottomPad);
    final stepX = size.width / (points.length - 1);

    final linePath = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i * stepX;
      final t = (points[i] - minV) / safeRange;
      final y = topPad + (1 - t) * usableHeight;
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevT = (points[i - 1] - minV) / safeRange;
        final prevY = topPad + (1 - prevT) * usableHeight;
        final cpX = (prevX + x) / 2;
        linePath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    final fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x66F9A01E), Color(0x00F9A01E)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = const Color(0xFFF69207)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _BatteryLineChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
