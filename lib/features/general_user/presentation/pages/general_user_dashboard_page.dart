import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_general_user_bottom_nav.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserDashboardPage extends StatelessWidget {
  const GeneralUserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<GeneralUserDashboardBloc, GeneralUserDashboardState>(
      builder: (context, state) {
        if (state.status == GeneralUserDashboardStatus.loading ||
            state.status == GeneralUserDashboardStatus.initial) {
          return const Scaffold(
            backgroundColor: Color(0xFFD9DEE2),
            body: AppLoader(),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFD9DEE2),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1D86CB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.waves_rounded,
                            size: 19,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.notifications_none),
                          onPressed: () {
                            context.push(AppRoutes.alertsPath);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            context.push(AppRoutes.profilePath);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dashboard',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF23282D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last Update : 10:20 AM',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F88D1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              icon: Icons.wifi,
                              iconColor: Color(0xFF4AAF5D),
                              title: 'Active Buoys',
                              value: '8',
                              total: '/10',
                            ),
                          ),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.wifi_off,
                              iconColor: Color(0xFFE85A54),
                              title: 'Offline Buoys',
                              value: '1',
                              total: '/10',
                            ),
                          ),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.battery_1_bar,
                              iconColor: Color(0xFF4F95DA),
                              title: 'Battery Low',
                              value: '0',
                              total: '/10',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Buoy's Map View",
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2E343A),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    context.go(AppRoutes.mapPath);
                                  },
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          const _MapPreviewCard(),
                        ],
                      ),
                    ),
                  ],
                ),
                  ),
                ),
                AppGeneralUserBottomNav(
                  selectedTab: GeneralUserBottomNavTab.home,
                  onTap: (tab) {
                    switch (tab) {
                      case GeneralUserBottomNavTab.home:
                        context.go(AppRoutes.dashboardPath);
                      case GeneralUserBottomNavTab.buoys:
                        context.go(AppRoutes.buoysPath);
                      case GeneralUserBottomNavTab.map:
                        context.go(AppRoutes.mapPath);
                      case GeneralUserBottomNavTab.export:
                        context.push(AppRoutes.exportSelectionPath);
                      case GeneralUserBottomNavTab.setup:
                        context.push(AppRoutes.setupPath);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String total;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3D4349),
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF20262B),
              ),
            ),
            Text(
              total,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF646B71),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: const SizedBox(
        width: double.infinity,
        height: 360,
        child: DummyBuoyMapView(
          interactive: false,
          showLabels: false,
          initialZoom: 10.3,
        ),
      ),
    );
  }
}

