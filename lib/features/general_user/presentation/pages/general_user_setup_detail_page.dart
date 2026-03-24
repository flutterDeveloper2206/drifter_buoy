import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/setup_bluetooth_devices_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserSetupDetailPage extends StatelessWidget {
  const GeneralUserSetupDetailPage({super.key});

  static const _blue = Color(0xFF206BBE);

  Future<void> _openBluetoothPicker(BuildContext context) async {
    final bloc = context.read<GeneralUserSetupDetailBloc>();
    final picked = await showSetupBluetoothDeviceSheet(context);
    if (!context.mounted || picked == null) {
      return;
    }
    bloc.add(
      SelectBluetoothDevice(
        displayName: picked.$1,
        bluetoothId: picked.$2,
      ),
    );
  }

  Future<void> _onBluetoothSwitch(BuildContext context, bool value) async {
    final bloc = context.read<GeneralUserSetupDetailBloc>();
    if (!value) {
      bloc.add(const ClearBluetoothSetup());
      return;
    }
    await _openBluetoothPicker(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: BlocBuilder<GeneralUserSetupDetailBloc,
                  GeneralUserSetupDetailState>(
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

                  final bluetoothOn = state.bluetoothDevice != '--';

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _WhiteCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Bluetooth Setup',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: const Color(0xFF1D2329),
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    Switch(
                                      value: bluetoothOn,
                                      onChanged: (v) =>
                                          _onBluetoothSwitch(context, v),
                                      activeTrackColor: const Color(0xFF1682C9),
                                      activeThumbColor: Colors.white,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _BluetoothGrid(
                                  state: state,
                                  onCellTap: () => _openBluetoothPicker(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _WhiteCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Enable Configuration',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: const Color(0xFF1D2329),
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
                                      activeTrackColor: const Color(0xFF1682C9),
                                      activeThumbColor: Colors.white,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Enable Configuration to Set Up Buoy',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: const Color(0xFF6A7178),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                if (state.enableConfiguration && bluetoothOn) ...[
                                  const SizedBox(height: 14),
                                  InkWell(
                                    onTap: () =>
                                        context.push(AppRoutes.buoySetupPath),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.arrow_circle_right_outlined,
                                            color: _blue,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Continue to Buoy Setup',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: _blue,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _WhiteCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Memory Status',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: const Color(0xFF1D2329),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.memoryStatus,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: const Color(0xFF2A2F34),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _WhiteCard(
                            child: InkWell(
                              onTap: () =>
                                  context.push(AppRoutes.selfTestDebugPath),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Self-Test and Debug',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: const Color(0xFF1D2329),
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Color(0xFF8A9095),
                                      size: 28,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _WhiteCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Backup',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: const Color(0xFF1D2329),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      color: _blue.withValues(alpha: 0.85),
                                      size: 26,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Backup Data to Server',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: _blue,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

class _BluetoothGrid extends StatelessWidget {
  const _BluetoothGrid({
    required this.state,
    required this.onCellTap,
  });

  final GeneralUserSetupDetailState state;
  final VoidCallback onCellTap;

  static const _divider = Color(0xFFE0E4E8);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget cell({
      required IconData icon,
      required String label,
      required String value,
    }) {
      return InkWell(
        onTap: onCellTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: const Color(0xFF5C6368)),
              const SizedBox(height: 8),
              Text(
                label,
                style: t.bodySmall?.copyWith(
                  color: const Color(0xFF8A9095),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: t.titleMedium?.copyWith(
                  color: const Color(0xFF1D2329),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: cell(
                  icon: Icons.bluetooth_rounded,
                  label: 'Bluetooth Device',
                  value: state.bluetoothDevice,
                ),
              ),
              Container(width: 1, color: _divider),
              Expanded(
                child: cell(
                  icon: Icons.link_rounded,
                  label: 'Connection Status',
                  value: state.connectionStatus,
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: _divider),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: cell(
                  icon: Icons.signal_cellular_alt_rounded,
                  label: 'Signal Strength',
                  value: state.signalStrength,
                ),
              ),
              Container(width: 1, color: _divider),
              Expanded(
                child: cell(
                  icon: Icons.sync_rounded,
                  label: 'Last Sync',
                  value: state.lastSync,
                ),
              ),
            ],
          ),
        ),
      ],
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

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
