import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserSetupDetailPage extends StatelessWidget {
  const GeneralUserSetupDetailPage({super.key});

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
                  BlocBuilder<
                    GeneralUserSetupDetailBloc,
                    GeneralUserSetupDetailState
                  >(
                    builder: (context, state) {
                      if (state.status == GeneralUserSetupDetailStatus.loading ||
                          state.status == GeneralUserSetupDetailStatus.initial) {
                        return const AppLoader();
                      }
                      if (state.status == GeneralUserSetupDetailStatus.error) {
                        return AppErrorView(
                          message: state.message,
                          onRetry: () {
                            context.read<GeneralUserSetupDetailBloc>().add(
                              const LoadGeneralUserSetupDetail(),
                            );
                          },
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          children: [
                            _TopTabs(
                              selectedTab: state.selectedTab,
                              onTabChanged: (tab) {
                                context.read<GeneralUserSetupDetailBloc>().add(
                                  ChangeGeneralUserSetupDetailTab(tab),
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                            _Card(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Enable Configuration to Set Up Buoy',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            color: const Color(0xFF3D4349),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: state.enableConfiguration,
                                        onChanged: (_) {
                                          context
                                              .read<GeneralUserSetupDetailBloc>()
                                              .add(
                                                const ToggleGeneralUserEnableConfiguration(),
                                              );
                                        },
                                        activeTrackColor: const Color(
                                          0xFF1682C9,
                                        ),
                                        activeThumbColor: Colors.white,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            _MetricRow(
                              title: 'Signal Strength',
                              value: state.signalStrength,
                            ),
                            const SizedBox(height: 8),
                            _MetricRow(
                              title: 'Bluetooth Device',
                              value: state.bluetoothDevice,
                            ),
                            const SizedBox(height: 8),
                            _MetricRow(title: 'Last Sync', value: state.lastSync),
                            const SizedBox(height: 10),
                            _Card(
                              child: _ActionTile(
                                title: 'Bluetooth Setup',
                                value: state.connectionStatus,
                                onTap: () =>
                                    context.push(AppRoutes.setupAddDevicePath),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _Card(
                              child: _ActionTile(
                                title: 'Connection Status',
                                value: state.connectionStatus,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _Card(
                              child: _ActionTile(
                                title: 'Memory Status',
                                value: state.memoryStatus,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _Card(
                              child: _ActionTile(
                                title: 'Self-Test and Debug',
                                value: '',
                                onTap: () =>
                                    context.push(AppRoutes.selfTestDebugPath),
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
                context.go(AppRoutes.setupPath);
              }
            },
            icon: Icons.arrow_back,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Add New',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

class _TopTabs extends StatelessWidget {
  final SetupDetailTab selectedTab;
  final ValueChanged<SetupDetailTab> onTabChanged;

  const _TopTabs({required this.selectedTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Add New',
            selected: selectedTab == SetupDetailTab.addNew,
            onTap: () => onTabChanged(SetupDetailTab.addNew),
          ),
          _TabButton(
            label: 'Backup',
            selected: selectedTab == SetupDetailTab.backup,
            onTap: () => onTabChanged(SetupDetailTab.backup),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
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
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1A66B8) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: selected ? Colors.white : const Color(0xFF6B6B6B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String title;
  final String value;

  const _MetricRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF4A4A4A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF2A2F34),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _ActionTile({required this.title, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF2A2F34),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF6A7178),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}
