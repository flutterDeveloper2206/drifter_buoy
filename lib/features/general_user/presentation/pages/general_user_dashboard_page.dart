import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GeneralUserDashboardPage extends StatelessWidget {
  const GeneralUserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
            _DashboardBottomNav(
              onTap: (index) {
                if (index == 0) {
                  context.go(AppRoutes.buoysPath);
                  return;
                }

                if (index == 1) {
                  context.go(AppRoutes.mapPath);
                  return;
                }

                if (index == 2) {
                  context.push(AppRoutes.exportSelectionPath);
                }
              },
            ),
          ],
        ),
      ),
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

class _DashboardBottomNav extends StatelessWidget {
  final ValueChanged<int> onTap;

  const _DashboardBottomNav({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD9DEE2),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      child: Row(
        children: [
          _BottomNavItem(
            icon: Icons.anchor_outlined,
            label: "Buoy's",
            onTap: () => onTap(0),
          ),
          _BottomNavItem(
            icon: Icons.map_outlined,
            label: 'Map',
            onTap: () => onTap(1),
          ),
          _BottomNavItem(
            icon: Icons.file_download_outlined,
            label: 'Export',
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: const Color(0xFF2A2F34)),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF2A2F34),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
