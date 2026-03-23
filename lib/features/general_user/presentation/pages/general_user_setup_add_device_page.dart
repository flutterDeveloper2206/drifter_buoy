import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_add_device/general_user_setup_add_device_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_add_device/general_user_setup_add_device_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_add_device/general_user_setup_add_device_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserSetupAddDevicePage extends StatelessWidget {
  const GeneralUserSetupAddDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: BlocBuilder<
                GeneralUserSetupAddDeviceBloc,
                GeneralUserSetupAddDeviceState
              >(
                builder: (context, state) {
                  if (state.status ==
                          GeneralUserSetupAddDeviceStatus.loading ||
                      state.status == GeneralUserSetupAddDeviceStatus.initial) {
                    return const AppLoader();
                  }
                  if (state.status == GeneralUserSetupAddDeviceStatus.error) {
                    return AppErrorView(
                      message: state.message,
                      onRetry: () {
                        context.read<GeneralUserSetupAddDeviceBloc>().add(
                          const LoadGeneralUserSetupAddDevice(),
                        );
                      },
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [
                        const _TopTabs(),
                        const SizedBox(height: 14),
                        const _ConfigCard(),
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
                        _SimpleActionTile(
                          title: 'Bluetooth Setup',
                          value: state.connectionStatus,
                        ),
                        const SizedBox(height: 10),
                        _SimpleActionTile(
                          title: 'Connection Status',
                          value: state.connectionStatus,
                        ),
                        const SizedBox(height: 10),
                        _SimpleActionTile(
                          title: 'Memory Status',
                          value: state.memoryStatus,
                        ),
                        const SizedBox(height: 10),
                        _NearbyDevicesCard(state: state),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: state.selectedDevice == null
                                ? null
                                : () => context.push(AppRoutes.buoySetupPath),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF206BBE),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Continue to Buoy Setup'),
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
                context.go(AppRoutes.setupDetailPath);
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
  const _TopTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          _TabChip(label: 'Add New', selected: true),
          _TabChip(label: 'Backup', selected: false),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _TabChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
    );
  }
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Enable Configuration to Set Up Buoy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF3D4349),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(
            value: true,
            onChanged: null,
            activeTrackColor: const Color(0xFF1682C9),
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String title;
  final String value;

  const _MetricRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
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

class _SimpleActionTile extends StatelessWidget {
  final String title;
  final String value;

  const _SimpleActionTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
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

class _NearbyDevicesCard extends StatelessWidget {
  final GeneralUserSetupAddDeviceState state;

  const _NearbyDevicesCard({required this.state});

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Nearby Bluetooth Devices',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF2A2F34),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...state.nearbyDevices.map((device) {
            final selected = state.selectedDevice == device;
            return InkWell(
              onTap: () {
                context.read<GeneralUserSetupAddDeviceBloc>().add(
                  SelectGeneralUserNearbyDevice(device),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selected
                          ? const Color(0xFF206BBE)
                          : const Color(0xFFA0A6AD),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      device,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF3B4249),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
