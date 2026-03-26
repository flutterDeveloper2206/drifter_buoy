import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_general_user_bottom_nav.dart';
import 'package:drifter_buoy/core/utils/widgets/app_info_metric_item.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/general_user_loading_shimmers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserBuoysPage extends StatefulWidget {
  const GeneralUserBuoysPage({super.key});

  @override
  State<GeneralUserBuoysPage> createState() => _GeneralUserBuoysPageState();
}

class _GeneralUserBuoysPageState extends State<GeneralUserBuoysPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: BlocListener<GeneralUserBuoysBloc, GeneralUserBuoysState>(
          listenWhen: (previous, current) => previous.query != current.query,
          listener: (_, state) {
            if (_searchController.text == state.query) {
              return;
            }

            _searchController.text = state.query;
            _searchController.selection = TextSelection.collapsed(
              offset: _searchController.text.length,
            );
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.waves_rounded,
                      size: 34,
                      color: Color(0xFF1179BF),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        context.push(AppRoutes.alertsPath);
                      },
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF2A2F34),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.push(AppRoutes.profilePath);
                      },
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: Color(0xFF2A2F34),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Buoy's",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF242A2F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<GeneralUserBuoysBloc, GeneralUserBuoysState>(
                  builder: (context, state) {
                    if (state.status == GeneralUserBuoysStatus.loading ||
                        state.status == GeneralUserBuoysStatus.initial) {
                      return const GeneralUserBuoysShimmer();
                    }

                    if (state.status == GeneralUserBuoysStatus.error) {
                      return AppErrorView(
                        message: state.message,
                        onRetry: () {
                          context.read<GeneralUserBuoysBloc>().add(
                            const LoadGeneralUserBuoys(),
                          );
                        },
                      );
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                          child: _StatusSummaryCard(
                            activeCount: state.activeCount,
                            offlineCount: state.offlineCount,
                            batteryLowCount: state.batteryLowCount,
                            total: state.totalBuoys,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _SearchCard(
                            controller: _searchController,
                            onChanged: (value) {
                              context.read<GeneralUserBuoysBloc>().add(
                                UpdateGeneralUserBuoysQuery(value),
                              );
                            },
                            onSearchTap: () => _handleSearchTap(context, state),
                            onClearTap: state.query.trim().isNotEmpty
                                ? () {
                                    context.read<GeneralUserBuoysBloc>().add(
                                      const ClearGeneralUserBuoysQuery(),
                                    );
                                  }
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _FilterRow(
                            selectedFilter: state.selectedFilter,
                            onFilterTap: (filter) {
                              context.read<GeneralUserBuoysBloc>().add(
                                ChangeGeneralUserBuoysFilter(filter),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: state.filteredBuoys.isEmpty
                              ? _EmptyBuoysView(
                                  query: state.query,
                                  selectedFilter: state.selectedFilter,
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    8,
                                  ),
                                  itemCount: state.filteredBuoys.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final buoy = state.filteredBuoys[index];
                                    return _AnimatedListItem(
                                      index: index,
                                      child: _BuoyCard(
                                        buoy: buoy,
                                        onTap: () => context.push(
                                          AppRoutes.buoyOverviewPath,
                                          extra: buoy.id.replaceAll(' ', ''),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        AppGeneralUserBottomNav(
                          selectedTab: GeneralUserBottomNavTab.buoys,
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

  void _handleSearchTap(BuildContext context, GeneralUserBuoysState state) {
    final query = state.query.trim();
    if (query.isEmpty) {
      AppFlushbar.info('Enter Buoy ID to search.', context: context);
      return;
    }

    if (state.filteredBuoys.isEmpty) {
      AppFlushbar.info('No buoy found for "$query".', context: context);
      return;
    }

    final first = state.filteredBuoys.first;
    context.push(
      AppRoutes.buoyOverviewPath,
      extra: first.id.replaceAll(' ', ''),
    );
  }
}

class _StatusSummaryCard extends StatelessWidget {
  final int activeCount;
  final int offlineCount;
  final int batteryLowCount;
  final int total;

  const _StatusSummaryCard({
    required this.activeCount,
    required this.offlineCount,
    required this.batteryLowCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Icons.wifi,
              iconColor: const Color(0xFF47B45E),
              title: 'Active Buoys',
              value: activeCount,
              total: total,
            ),
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.wifi_off,
              iconColor: const Color(0xFFE85A54),
              title: 'Offline Buoys',
              value: offlineCount,
              total: total,
            ),
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.battery_1_bar,
              iconColor: const Color(0xFF4F95DA),
              title: 'Battery Low',
              value: batteryLowCount,
              total: total,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int value;
  final int total;

  const _SummaryItem({
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
        Icon(icon, color: iconColor, size: 17),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: const Color(0xFF3C4146),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF252A2F),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '/$total',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF636A70),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearchTap;
  final VoidCallback? onClearTap;

  const _SearchCard({
    required this.controller,
    required this.onChanged,
    required this.onSearchTap,
    required this.onClearTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(28),
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
                color: const Color(0xFF30363B),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Search with Buoy ID',
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF9A9FA4),
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                suffixIcon: onClearTap == null
                    ? null
                    : IconButton(
                        onPressed: onClearTap,
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Color(0xFF8F9498),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSearchTap,
                customBorder: const CircleBorder(),
                child: Ink(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF007BC2),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final GeneralUserBuoyFilter selectedFilter;
  final ValueChanged<GeneralUserBuoyFilter> onFilterTap;

  const _FilterRow({required this.selectedFilter, required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            selected: selectedFilter == GeneralUserBuoyFilter.all,
            onTap: () => onFilterTap(GeneralUserBuoyFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Active',
            selected: selectedFilter == GeneralUserBuoyFilter.active,
            onTap: () => onFilterTap(GeneralUserBuoyFilter.active),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Offline',
            selected: selectedFilter == GeneralUserBuoyFilter.offline,
            onTap: () => onFilterTap(GeneralUserBuoyFilter.offline),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Battery Low',
            selected: selectedFilter == GeneralUserBuoyFilter.batteryLow,
            onTap: () => onFilterTap(GeneralUserBuoyFilter.batteryLow),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF216CC0) : const Color(0xFFE9EBED),
          borderRadius: BorderRadius.circular(22),
          border: selected
              ? null
              : Border.all(color: const Color(0xFFB1B6BB), width: 1),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: selected ? Colors.white : const Color(0xFF62676C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BuoyCard extends StatelessWidget {
  final GeneralUserBuoyItem buoy;
  final VoidCallback onTap;

  const _BuoyCard({required this.buoy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (buoy.status) {
      GeneralUserBuoyConnectionStatus.active => const Color(0xFF22BE61),
      GeneralUserBuoyConnectionStatus.offline => const Color(0xFFE45852),
      GeneralUserBuoyConnectionStatus.batteryLow => const Color(0xFF4F95DA),
    };

    final statusIcon = switch (buoy.status) {
      GeneralUserBuoyConnectionStatus.active => Icons.wifi,
      GeneralUserBuoyConnectionStatus.offline => Icons.wifi_off,
      GeneralUserBuoyConnectionStatus.batteryLow => Icons.battery_1_bar,
    };

    final statusLabel = switch (buoy.status) {
      GeneralUserBuoyConnectionStatus.active => 'Active',
      GeneralUserBuoyConnectionStatus.offline => 'Offline',
      GeneralUserBuoyConnectionStatus.batteryLow => 'Battery Low',
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  buoy.id,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF292E33),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Icon(statusIcon, size: 18, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Last Update : ${buoy.lastUpdate}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF747A80),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppInfoMetricItem(
                    icon: Icons.battery_5_bar_rounded,
                    value: buoy.battery,
                    label: 'Battery',
                  ),
                ),
                Expanded(
                  child: AppInfoMetricItem(
                    icon: Icons.gps_fixed_rounded,
                    value: buoy.gps,
                    label: 'GPS',
                  ),
                ),
                Expanded(
                  child: AppInfoMetricItem(
                    icon: Icons.network_cell_rounded,
                    value: buoy.signal,
                    label: 'Signal',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBuoysView extends StatelessWidget {
  final String query;
  final GeneralUserBuoyFilter selectedFilter;

  const _EmptyBuoysView({required this.query, required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    final message = query.trim().isEmpty
        ? 'No buoys available for selected filter.'
        : 'No buoys match "$query".';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          message,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF5E656C),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedListItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.04).clamp(0.0, 0.6);
    final end = (start + 0.35).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Interval(start, end, curve: Curves.easeOutCubic),
      builder: (context, progress, animatedChild) {
        final offsetY = (1 - progress) * 12;
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, offsetY),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}
