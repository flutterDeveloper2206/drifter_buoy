import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/animated_list_entrance.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/general_user_back_navigation_scope.dart';
import 'package:drifter_buoy/core/utils/widgets/app_general_user_main_app_bar.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_devices/general_user_setup_devices_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_devices/general_user_setup_devices_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_devices/general_user_setup_devices_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/general_user_loading_shimmers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserSetupPage extends StatefulWidget {
  const GeneralUserSetupPage({super.key});

  @override
  State<GeneralUserSetupPage> createState() => _GeneralUserSetupPageState();
}

class _GeneralUserSetupPageState extends State<GeneralUserSetupPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GeneralUserTabRootPopScope(
      child: Scaffold(
        backgroundColor: const Color(0xFFDDE1E4),
        body: SafeArea(
          child:
              BlocListener<
                GeneralUserSetupDevicesBloc,
                GeneralUserSetupDevicesState
              >(
                listenWhen: (previous, current) =>
                    previous.query != current.query,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppGeneralUserMainAppBar(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Set Up',
                            style: textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF242A2F),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () =>
                                context.push(AppRoutes.setupDetailPath),
                            icon: const Icon(
                              Icons.add,
                              size: 22,
                              color: Color(0xFF206BBE),
                            ),
                            label: Text(
                              'Add New',
                              style: textTheme.titleSmall?.copyWith(
                                color: const Color(0xFF206BBE),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                          BlocBuilder<
                            GeneralUserSetupDevicesBloc,
                            GeneralUserSetupDevicesState
                          >(
                            builder: (context, state) {
                              if (state.status ==
                                      GeneralUserSetupDevicesStatus.loading ||
                                  state.status ==
                                      GeneralUserSetupDevicesStatus.initial) {
                                return const GeneralUserBuoysShimmer();
                              }

                              if (state.status ==
                                  GeneralUserSetupDevicesStatus.error) {
                                return AppErrorView(
                                  message: state.message,
                                  onRetry: () {
                                    context
                                        .read<GeneralUserSetupDevicesBloc>()
                                        .add(
                                          const LoadGeneralUserSetupDevices(),
                                        );
                                  },
                                );
                              }

                              return RefreshIndicator(
                                color: const Color(0xFF1F88D1),
                                onRefresh: () async {
                                  final bloc = context
                                      .read<GeneralUserSetupDevicesBloc>();
                                  bloc.add(const LoadGeneralUserSetupDevices());
                                  await bloc.stream.firstWhere(
                                    (s) =>
                                        s.status !=
                                        GeneralUserSetupDevicesStatus.loading,
                                  );
                                },
                                child: ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    0,
                                    0,
                                    8,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        12,
                                        16,
                                        12,
                                      ),
                                      child: _SetupSearchBar(
                                        controller: _searchController,
                                        onChanged: (value) {
                                          context
                                              .read<
                                                GeneralUserSetupDevicesBloc
                                              >()
                                              .add(
                                                UpdateGeneralUserSetupDevicesQuery(
                                                  value,
                                                ),
                                              );
                                        },
                                        onSearchTap: () {
                                          FocusScope.of(context).unfocus();
                                        },
                                        onClearTap:
                                            state.query.trim().isNotEmpty
                                            ? () {
                                                context
                                                    .read<
                                                      GeneralUserSetupDevicesBloc
                                                    >()
                                                    .add(
                                                      const ClearGeneralUserSetupDevicesQuery(),
                                                    );
                                                FocusScope.of(
                                                  context,
                                                ).unfocus();
                                              }
                                            : null,
                                      ),
                                    ),
                                    if (state.filteredDevices.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          0,
                                        ),
                                        child: SizedBox(
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.5,
                                          child: _SetupEmptyView(
                                            searchQuery: state.query,
                                          ),
                                        ),
                                      )
                                    else
                                      ...state.filteredDevices
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                            final index = entry.key;
                                            final item = entry.value;
                                            return Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                16,
                                                0,
                                                16,
                                                index ==
                                                        state
                                                                .filteredDevices
                                                                .length -
                                                            1
                                                    ? 0
                                                    : 12,
                                              ),
                                              child: AnimatedListEntrance(
                                                index: index,
                                                child: _SetupDeviceCard(
                                                  item: item,
                                                  onTap: () => context.push(
                                                    AppRoutes.setupDetailPath,
                                                    extra: item.id,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                  ],
                                ),
                              );
                            },
                          ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

class _SetupEmptyView extends StatelessWidget {
  const _SetupEmptyView({required this.searchQuery});

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final trimmed = searchQuery.trim();
    final isSearching = trimmed.isNotEmpty;
    final title = isSearching
        ? 'No buoys match "$trimmed".'
        : 'No devices added yet.';
    final subtitle = isSearching
        ? 'Try a different Buoy ID.'
        : 'Use Add New above to register and configure a buoy.';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.settings_suggest_outlined,
              size: 56,
              color: const Color(0xFF5E656C).withValues(alpha: 0.55),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                color: const Color(0xFF5E656C),
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8A9095),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
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
    required this.onClearTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearchTap;
  final VoidCallback? onClearTap;

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
                contentPadding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
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

  final GeneralUserSetupDeviceItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (icon, iconColor, textColor) = switch (item.connectionStatus) {
      GeneralUserSetupDeviceConnectionStatus.active => (
        Icons.wifi_rounded,
        const Color(0xFF22BE61),
        const Color(0xFF22BE61),
      ),
      GeneralUserSetupDeviceConnectionStatus.offline => (
        Icons.wifi_off_rounded,
        const Color(0xFFD94A4A),
        const Color(0xFFD94A4A),
      ),
      GeneralUserSetupDeviceConnectionStatus.batteryLow => (
        Icons.battery_alert_rounded,
        const Color(0xFFE6A23C),
        const Color(0xFFE6A23C),
      ),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
                        style: textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF1D2329),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(icon, color: iconColor, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      item.statusLabel,
                      style: textTheme.titleSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.lastUpdate,
                  style: textTheme.bodySmall?.copyWith(
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
                        maxLines: 3,
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
    this.maxLines = 2,
  });

  final IconData icon;
  final String value;
  final String label;
  final int maxLines;

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
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelMedium?.copyWith(
            color: const Color(0xFF1D2329),
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: const Color(0xFF8A9095),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
