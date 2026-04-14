import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/general_user_loading_shimmers.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/navigation/general_user_export_route_extra.dart';
import 'package:drifter_buoy/features/general_user/presentation/navigation/general_user_metrics_route_extra.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/google_trajectory_map_preview.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class GeneralUserBuoyOverviewPage extends StatelessWidget {
  const GeneralUserBuoyOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child:
            BlocListener<
              GeneralUserBuoyOverviewBloc,
              GeneralUserBuoyOverviewState
            >(
              listenWhen: (previous, current) {
                final prevMsg = switch (previous) {
                  GeneralUserBuoyOverviewLoaded(:final message) => message,
                  _ => '',
                };
                final curr = switch (current) {
                  GeneralUserBuoyOverviewLoaded(:final message) => message,
                  _ => null,
                };
                if (curr == null || curr.isEmpty) {
                  return false;
                }
                return prevMsg != curr;
              },
              listener: (context, state) {
                if (state is! GeneralUserBuoyOverviewLoaded) {
                  return;
                }
                if (state.message.isEmpty) {
                  return;
                }

                if (state.isSuccessMessage) {
                  AppFlushbar.success(state.message, context: context);
                } else {
                  AppFlushbar.info(state.message, context: context);
                }

                context.read<GeneralUserBuoyOverviewBloc>().add(
                  const ClearGeneralUserBuoyOverviewMessage(),
                );
              },
              child:
                  BlocBuilder<
                    GeneralUserBuoyOverviewBloc,
                    GeneralUserBuoyOverviewState
                  >(
                    builder: (context, state) {
                      return switch (state) {
                        GeneralUserBuoyOverviewInitial() ||
                        GeneralUserBuoyOverviewLoading() =>
                          const GeneralUserBuoyOverviewShimmer(),
                        GeneralUserBuoyOverviewError(
                          :final message,
                          :final buoyId,
                        ) =>
                          AppErrorView(
                            message: message,
                            onRetry: buoyId.isEmpty
                                ? null
                                : () {
                                    context
                                        .read<GeneralUserBuoyOverviewBloc>()
                                        .add(
                                          LoadGeneralUserBuoyOverview(
                                            buoyId: buoyId,
                                          ),
                                        );
                                  },
                          ),
                        GeneralUserBuoyOverviewLoaded() => _LoadedOverviewBody(
                          state: state,
                        ),
                      };
                    },
                  ),
            ),
      ),
    );
  }
}

class _LoadedOverviewBody extends StatelessWidget {
  const _LoadedOverviewBody({required this.state});

  final GeneralUserBuoyOverviewLoaded state;

  @override
  Widget build(BuildContext context) {
    final data = state.data;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIconCircleButton(
                onTap: () {
                  if (GoRouter.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.mapBuoyDetailsPath);
                  }
                },
                icon: Icons.arrow_back,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    data.id,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2A2F34),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 18),
          _OverviewTabBar(
            selectedTab: state.selectedTab,
            onTabChanged: (tab) {
              if (tab == GeneralUserBuoyOverviewTab.trajectory) {
                context.push(AppRoutes.trajectoryViewPath, extra: data.id);
                return;
              }

              context.read<GeneralUserBuoyOverviewBloc>().add(
                ChangeGeneralUserBuoyOverviewTab(tab),
              );
            },
          ),
          const SizedBox(height: 18),
          _BuoyHeaderCard(data: data),
          const SizedBox(height: 16),
          _MetricsCard(
            data: data,
            onTap: () => context.push(
              AppRoutes.metricsPath,
              extra: GeneralUserMetricsRouteExtra(
                buoyId: data.id.replaceAll(' ', ''),
                focusBatterySection: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _TrajectoryCard(
            onArrowTap: () =>
                context.push(AppRoutes.trajectoryViewPath, extra: data.id),
          ),
          const SizedBox(height: 16),
          _DeviceActionsCard(
            onExportTap: () => context.push(
              AppRoutes.exportPath,
              extra: GeneralUserExportBuoyDistanceExtra(buoyId: data.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTabBar extends StatelessWidget {
  final GeneralUserBuoyOverviewTab selectedTab;
  final ValueChanged<GeneralUserBuoyOverviewTab> onTabChanged;

  const _OverviewTabBar({
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOverview = selectedTab == GeneralUserBuoyOverviewTab.overview;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Over View',
            selected: isOverview,
            onTap: () => onTabChanged(GeneralUserBuoyOverviewTab.overview),
          ),
          _TabItem(
            label: 'Trajectory View',
            selected: !isOverview,
            onTap: () => onTabChanged(GeneralUserBuoyOverviewTab.trajectory),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1A66B8) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: selected ? Colors.white : const Color(0xFF6B6B6B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _BuoyHeaderCard extends StatelessWidget {
  final GeneralUserBuoyOverviewData data;

  const _BuoyHeaderCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _overviewCardDisplayId(data.id),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF2A2F34),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.wifi,
                color: data.isActive
                    ? const Color(0xFF22BE61)
                    : const Color(0xFFE74C3C),
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                data.isActive ? 'Active' : 'Offline',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: data.isActive
                      ? const Color(0xFF22BE61)
                      : const Color(0xFFE74C3C),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.sync, color: Color(0xFF2184D2), size: 20),
              const SizedBox(width: 6),
              Text(
                'Last Update : ${data.lastUpdate}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF2184D2),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  final GeneralUserBuoyOverviewData data;
  final VoidCallback onTap;

  const _MetricsCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Metrics',
                style: textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF2E3238),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricColumn(
                      icon: Icons.battery_5_bar_rounded,
                      title: 'Battery',
                      value: data.batteryVoltage,
                    ),
                  ),
                  Expanded(
                    child: _MetricColumn(
                      icon: Icons.map_outlined,
                      title: 'GPS',
                      value: data.gpsDisplayLines,
                    ),
                  ),
                  Expanded(
                    child: _MetricColumn(
                      icon: Icons.settings_input_antenna_rounded,
                      title: 'signal Strength',
                      value: data.signalStrength,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MetricColumn({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF505050)),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: const Color(0xFF5C5C5C),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _TrajectoryCard extends StatelessWidget {
  final VoidCallback onArrowTap;

  const _TrajectoryCard({required this.onArrowTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onArrowTap ,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Trajectory View',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF2E3238),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: onArrowTap,
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 28,
                      color: Color(0xFF2D3238),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BlocSelector<
              GeneralUserBuoyOverviewBloc,
              GeneralUserBuoyOverviewState,
              _TrajectoryPreviewVm?
            >(
              selector: (s) {
                if (s is! GeneralUserBuoyOverviewLoaded) {
                  return null;
                }
                final d = s.data;
                return _TrajectoryPreviewVm(
                  buoyId: d.id,
                  points: d.trajectoryPoints,
                  status: _buoyMapStatusForOverview(d),
                );
              },
              builder: (context, vm) {
                if (vm == null) {
                  return const SizedBox(height: 170);
                }
                return SizedBox(
                  height: 190,
                  child: RepaintBoundary(
                    child: GoogleTrajectoryMapPreview(
                      trajectoryPoints: vm.points,
                      buoy: DummyBuoy(
                        id: vm.buoyId,
                        position: vm.anchor,
                        status: vm.status,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceActionsCard extends StatelessWidget {
  final VoidCallback onExportTap;

  const _DeviceActionsCard({required this.onExportTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF2E3238),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onExportTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.file_download_outlined,
                    color: Color(0xFF2568B8),
                    size: 24,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Export Data',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2568B8),
                      fontWeight: FontWeight.w700,
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

String _overviewCardDisplayId(String id) {
  return id.contains('-') ? id.replaceAll('-', ' - ') : id;
}

BuoyStatus _buoyMapStatusForOverview(GeneralUserBuoyOverviewData data) {
  if (!data.isActive) {
    return BuoyStatus.offline;
  }
  if (data.isBatteryLow) {
    return BuoyStatus.batteryLow;
  }
  return BuoyStatus.active;
}

final class _TrajectoryPreviewVm extends Equatable {
  const _TrajectoryPreviewVm({
    required this.buoyId,
    required this.points,
    required this.status,
  });

  final String buoyId;
  final List<LatLng> points;
  final BuoyStatus status;

  LatLng get anchor =>
      points.isNotEmpty ? points.first : const LatLng(37.7749, -122.4194);

  @override
  List<Object?> get props => [
    buoyId,
    status,
    points.map((p) => '${p.latitude},${p.longitude}').join('|'),
  ];
}
