import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_general_user_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _SetupDeviceItem {
  const _SetupDeviceItem({
    required this.id,
    required this.lastUpdate,
    required this.battery,
    required this.gps,
    required this.signal,
  });

  final String id;
  final String lastUpdate;
  final String battery;
  final String gps;
  final String signal;
}

class GeneralUserSetupPage extends StatefulWidget {
  const GeneralUserSetupPage({super.key});

  @override
  State<GeneralUserSetupPage> createState() => _GeneralUserSetupPageState();
}

class _GeneralUserSetupPageState extends State<GeneralUserSetupPage> {
  final TextEditingController _searchController = TextEditingController();

  static const List<_SetupDeviceItem> _allDevices = [
    _SetupDeviceItem(
      id: 'DB - 01',
      lastUpdate: 'Last Update : 09:20 AM',
      battery: '11.8 v',
      gps: '15°40\'51.0"N',
      signal: '79%',
    ),
    _SetupDeviceItem(
      id: 'DB - 02',
      lastUpdate: 'Last Update : 08:45 AM',
      battery: '12.1 v',
      gps: '15°41\'02.1"N',
      signal: '82%',
    ),
    _SetupDeviceItem(
      id: 'DB - 03',
      lastUpdate: 'Last Update : 07:12 AM',
      battery: '10.9 v',
      gps: '15°39\'48.5"N',
      signal: '71%',
    ),
    _SetupDeviceItem(
      id: 'DB - 04',
      lastUpdate: 'Last Update : 06:30 AM',
      battery: '11.2 v',
      gps: '15°40\'15.0"N',
      signal: '65%',
    ),
    _SetupDeviceItem(
      id: 'DB - 05',
      lastUpdate: 'Last Update : Yesterday',
      battery: '9.8 v',
      gps: '15°38\'22.0"N',
      signal: '54%',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_SetupDeviceItem> get _visibleDevices {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      return _allDevices;
    }
    return _allDevices
        .where(
          (d) => d.id
              .toLowerCase()
              .replaceAll(' ', '')
              .contains(q.replaceAll(' ', '')),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
              child: Row(
                children: [
                  Text(
                    'Set Up',
                    style: textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF242A2F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => context.push(AppRoutes.setupDetailPath),
                    icon: const Icon(
                      Icons.add,
                      size: 22,
                      color: Color(0xFF206BBE),
                    ),
                    label: Text(
                      'Add New',
                      style: textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF206BBE),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: _SetupSearchBar(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                onSearchTap: () {
                  setState(() {});
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                itemCount: _visibleDevices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _visibleDevices[index];
                  return _SetupDeviceCard(
                    item: item,
                    onTap: () => context.push(AppRoutes.setupDetailPath),
                  );
                },
              ),
            ),
            AppGeneralUserBottomNav(
              selectedTab: GeneralUserBottomNavTab.setup,
              onTap: (tab) {
                switch (tab) {
                  case GeneralUserBottomNavTab.home:
                    context.go(AppRoutes.dashboardPath);
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

class _SetupSearchBar extends StatelessWidget {
  const _SetupSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSearchTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.fromLTRB(16, 0, 5, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF31363A),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search with Buoy ID',
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF9A9FA4),
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSearchTap,
              customBorder: const CircleBorder(),
              child: Ink(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF206BBE),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupDeviceCard extends StatelessWidget {
  const _SetupDeviceCard({required this.item, required this.onTap});

  final _SetupDeviceItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.id,
                        style: textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF1D2329),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.wifi_rounded,
                      color: Color(0xFF22BE61),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Active',
                      style: textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF22BE61),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.lastUpdate,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF70757A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MetricBlock(
                        icon: Icons.battery_std_rounded,
                        value: item.battery,
                        label: 'Battery',
                      ),
                    ),
                    Expanded(
                      child: _MetricBlock(
                        icon: Icons.map_outlined,
                        value: item.gps,
                        label: 'GPS',
                      ),
                    ),
                    Expanded(
                      child: _MetricBlock(
                        icon: Icons.signal_cellular_alt_rounded,
                        value: item.signal,
                        label: 'Signal',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF5C6368)),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleSmall?.copyWith(
            color: const Color(0xFF1D2329),
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: const Color(0xFF8A9095),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
