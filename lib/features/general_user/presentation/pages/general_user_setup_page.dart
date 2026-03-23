import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_general_user_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GeneralUserSetupPage extends StatelessWidget {
  const GeneralUserSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    const ids = ['DB - 01', 'DB - 02', 'DB - 03', 'DB - 04', 'DB - 05'];

    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.waves_rounded, size: 34, color: Color(0xFF1179BF)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.push(AppRoutes.alertsPath),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                  IconButton(
                    onPressed: () => context.push(AppRoutes.profilePath),
                    icon: const Icon(Icons.menu_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Set Up',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF242A2F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 14),
                    Icon(Icons.search_rounded, color: Color(0xFF8A9095)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search with Buoy ID',
                        style: TextStyle(
                          color: Color(0xFF9A9FA4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                itemCount: ids.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final id = ids[index];
                  return Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                id,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Last Update : 09:20 AM',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: const Color(0xFF70757A)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.wifi, color: Color(0xFF22BE61), size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Active',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF22BE61),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.setupDetailPath),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF206BBE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Add New'),
                ),
              ),
            ),
            AppGeneralUserBottomNav(
              selectedTab: GeneralUserBottomNavTab.setup,
              showSetup: true,
              onTap: (tab) {
                switch (tab) {
                  case GeneralUserBottomNavTab.buoys:
                    context.go(AppRoutes.buoysPath);
                  case GeneralUserBottomNavTab.map:
                    context.go(AppRoutes.mapPath);
                  case GeneralUserBottomNavTab.export:
                    context.go(AppRoutes.exportSelectionPath);
                  case GeneralUserBottomNavTab.setup:
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
