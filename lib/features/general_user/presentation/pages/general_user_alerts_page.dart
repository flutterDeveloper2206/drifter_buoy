import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/general_user_loading_shimmers.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/alerts/general_user_alerts_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/alerts/general_user_alerts_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/alerts/general_user_alerts_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserAlertsPage extends StatelessWidget {
  const GeneralUserAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: BlocBuilder<GeneralUserAlertsBloc, GeneralUserAlertsState>(
                builder: (context, state) {
                  final showFullScreenLoader =
                      state.status == GeneralUserAlertsStatus.initial ||
                      (state.status == GeneralUserAlertsStatus.loading &&
                          !state.isRefreshing);

                  if (showFullScreenLoader) {
                    return const GeneralUserAlertsListShimmer();
                  }

                  if (state.status == GeneralUserAlertsStatus.error) {
                    return AppErrorView(
                      message: state.message,
                      onRetry: () {
                        context.read<GeneralUserAlertsBloc>().add(
                              const LoadGeneralUserAlerts(),
                            );
                      },
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.unreadCount.toString().padLeft(2, '0')} Alerts & Notifications',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xFF2A2F34),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: RefreshIndicator(
                            color: const Color(0xFF1F88D1),
                            onRefresh: () async {
                              final bloc =
                                  context.read<GeneralUserAlertsBloc>();
                              bloc.add(
                                const LoadGeneralUserAlerts(
                                  isPullToRefresh: true,
                                ),
                              );
                              await bloc.stream.firstWhere(
                                (s) => !s.isRefreshing,
                              );
                            },
                            child: state.alerts.isEmpty
                                ? ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: const [
                                      SizedBox(height: 120),
                                      Center(
                                        child: Text(
                                          'No notifications yet.',
                                          style: TextStyle(
                                            color: Color(0xFF545B61),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.separated(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: state.alerts.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final alert = state.alerts[index];
                                      return _AlertCard(alert: alert);
                                    },
                                  ),
                          ),
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
                context.go(AppRoutes.dashboardPath);
              }
            },
            icon: Icons.arrow_back,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Alerts & Notifications',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF262C31),
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

class _AlertCard extends StatelessWidget {
  final GeneralUserAlertItem alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final metaParts = <String>[
      if (alert.notificationType.trim().isNotEmpty)
        alert.notificationType.trim(),
      if (alert.priorityLevel.trim().isNotEmpty)
        alert.priorityLevel.trim(),
    ];
    final metaLine = metaParts.join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (metaLine.isNotEmpty) ...[
            Text(
              metaLine,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF7B8288),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  alert.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF2A2F34),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            alert.message,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF545B61),
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            alert.timeLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF7B8288),
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (alert.createdBy.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'By ${alert.createdBy.trim()}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF9AA0A6),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
