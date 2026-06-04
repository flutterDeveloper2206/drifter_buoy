import 'dart:async';

import 'package:drifter_buoy/core/bluetooth/ble_drifter_runtime_settings.dart';
import 'package:drifter_buoy/core/bluetooth/ble_connection_service.dart';
import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/theme/app_typography.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:drifter_buoy/core/utils/navigation_service.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/setup_bluetooth_devices_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserSetupDetailPage extends StatefulWidget {
  const GeneralUserSetupDetailPage({super.key});

  @override
  State<GeneralUserSetupDetailPage> createState() =>
      _GeneralUserSetupDetailPageState();
}

class _GeneralUserSetupDetailPageState
    extends State<GeneralUserSetupDetailPage> {
  static const _blue = Color(0xFF206BBE);
  late final BleConnectionService _ble;
  StreamSubscription<String>? _disconnectSub;

  @override
  void initState() {
    super.initState();
    _ble = sl<BleConnectionService>();
    _disconnectSub = _ble.disconnectedRemoteIds.listen((_) {
      if (!mounted) {
        return;
      }
      context.read<GeneralUserSetupDetailBloc>().add(
        const SyncBluetoothDisconnected(),
      );
    });
  }

  @override
  void dispose() {
    _disconnectSub?.cancel();
    super.dispose();
  }

  Future<void> _openBluetoothPicker(BuildContext context) async {
    final bloc = context.read<GeneralUserSetupDetailBloc>();
    await showSetupBluetoothDeviceSheet(
      context,
      onConnected: (displayName, bluetoothId) {
        bloc.add(
          SelectBluetoothDevice(
            displayName: displayName,
            bluetoothId: bluetoothId,
          ),
        );
      },
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

  Future<void> _disconnectIfConnected({bool showFeedback = true}) async {
    if (_ble.connectedRemoteId == null) {
      return;
    }
    await _ble.disconnect(showFeedback: showFeedback);
    if (mounted) {
      context.read<GeneralUserSetupDetailBloc>().add(
        const SyncBluetoothDisconnected(),
      );
    }
  }

  /// Shows disconnect feedback on the root navigator after the current route
  /// has settled — avoids Flushbar + `pop` navigator assertion conflicts.
  void _enqueueDisconnectFlushbar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final root = NavigationService.currentContext;
      if (root == null || !root.mounted) {
        return;
      }
      unawaited(
        AppFlushbar.info(
          'Bluetooth was disconnected from this app.',
          title: 'Disconnected',
          context: root,
        ),
      );
    });
  }

  void _onSelfTestDebugTap(BuildContext context) {
    if (kDebugMode) {
      context.push(AppRoutes.selfTestDebugPath);
      return;
    }
    if (_ble.connectedRemoteId == null) {
      AppFlushbar.error(
        'Connect a Bluetooth device first to use Self-Test and Debug.',
        context: context,
      );
      return;
    }
    context.push(AppRoutes.selfTestDebugPath);
  }

  Future<void> _handleBackTap(BuildContext context) async {
    final hadConnection = _ble.connectedRemoteId != null;
    await _disconnectIfConnected(showFeedback: false);
    if (!context.mounted) {
      return;
    }
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.setupPath);
    }
    if (hadConnection) {
      _enqueueDisconnectFlushbar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          return;
        }
        final hadConnection = _ble.connectedRemoteId != null;
        unawaited(() async {
          await _disconnectIfConnected(showFeedback: false);
          if (hadConnection) {
            _enqueueDisconnectFlushbar();
          }
        }());
      },
      child: BlocListener<GeneralUserSetupDetailBloc, GeneralUserSetupDetailState>(
        listenWhen: (p, c) =>
            p.bleSettingsMessage != c.bleSettingsMessage &&
            c.bleSettingsMessage.isNotEmpty,
        listener: (context, state) {
          final message = state.bleSettingsMessage;
          if (message.isEmpty) {
            return;
          }
          if (state.bleSettingsMessageIsSuccess) {
            AppFlushbar.success(message, context: context);
          } else {
            AppFlushbar.error(message, context: context);
          }
          context.read<GeneralUserSetupDetailBloc>().add(
            const ClearBleTimingSettingsMessage(),
          );
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFDDE1E4),
          body: SafeArea(
            child: Column(
              children: [
                BlocBuilder<
                  GeneralUserSetupDetailBloc,
                  GeneralUserSetupDetailState
                >(
                  buildWhen: (p, c) =>
                      p.contextBuoyId != c.contextBuoyId ||
                      p.status != c.status,
                  builder: (context, state) {
                    final title =
                        state.contextBuoyId == null ||
                            state.contextBuoyId!.trim().isEmpty
                        ? 'Add New'
                        : state.contextBuoyId!.trim();
                    return _Header(
                      title: title,
                      onBackTap: () => _handleBackTap(context),
                    );
                  },
                ),
                Expanded(
                  child:
                      BlocBuilder<
                        GeneralUserSetupDetailBloc,
                        GeneralUserSetupDetailState
                      >(
                        builder: (context, state) {
                          if (state.status ==
                                  GeneralUserSetupDetailStatus.loading ||
                              state.status ==
                                  GeneralUserSetupDetailStatus.initial) {
                            return const AppLoader();
                          }
                          if (state.status ==
                              GeneralUserSetupDetailStatus.error) {
                            return AppErrorView(
                              message: state.message,
                              onRetry: () {
                                context.read<GeneralUserSetupDetailBloc>().add(
                                  LoadGeneralUserSetupDetail(
                                    buoyId: state.contextBuoyId,
                                  ),
                                );
                              },
                            );
                          }

                          final bluetoothOn = state.bluetoothRemoteId != null;

                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _WhiteCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Bluetooth Setup',
                                              style: Theme.of(context).textTheme
                                                  .compactSectionTitle(
                                                    const Color(0xFF1D2329),
                                                  ),
                                            ),
                                          ),
                                          Switch(
                                            value: bluetoothOn,
                                            onChanged: (v) =>
                                                _onBluetoothSwitch(context, v),
                                            activeTrackColor: const Color(
                                              0xFF1682C9,
                                            ),
                                            activeThumbColor: Colors.white,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _BluetoothGrid(
                                        state: state,
                                        onCellTap: () =>
                                            _openBluetoothPicker(context),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _WhiteCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Enable Configuration',
                                              style: Theme.of(context).textTheme
                                                  .compactSectionTitle(
                                                    const Color(0xFF1D2329),
                                                  ),
                                            ),
                                          ),
                                          Switch(
                                            value: state.enableConfiguration,
                                            onChanged: (_) {
                                              context
                                                  .read<
                                                    GeneralUserSetupDetailBloc
                                                  >()
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
                                      const SizedBox(height: 8),
                                      Text(
                                        'Enable Configuration to Set Up Buoy',
                                        style: Theme.of(context).textTheme
                                            .compactSupportingText(
                                              const Color(0xFF6A7178),
                                            ),
                                      ),
                                      if (state.enableConfiguration &&
                                          bluetoothOn) ...[
                                        const SizedBox(height: 14),
                                        InkWell(
                                          onTap: () => context.push(
                                            AppRoutes.buoySetupPath,
                                            extra: state.contextBuoyId,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .arrow_circle_right_outlined,
                                                  color: _blue,
                                                  size: 22,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Continue to Buoy Setup',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .compactActionText(_blue),
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
                                _BleTimingSettingsCard(
                                  chunkWriteDelayMs: state.chunkWriteDelayMs,
                                  commandResponseTimeoutSec:
                                      state.commandResponseTimeoutSec,
                                  onSave: (chunkMs, timeoutSec) {
                                    context
                                        .read<GeneralUserSetupDetailBloc>()
                                        .add(
                                          SaveBleTimingSettings(
                                            chunkWriteDelayMs: chunkMs,
                                            commandResponseTimeoutSec:
                                                timeoutSec,
                                          ),
                                        );
                                  },
                                ),
                                const SizedBox(height: 12),
                                _WhiteCard(
                                  child: InkWell(
                                    onTap: () => _onSelfTestDebugTap(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Self-Test and Debug',
                                              style: Theme.of(context).textTheme
                                                  .compactSectionTitle(
                                                    const Color(0xFF1D2329),
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

class _BleTimingSettingsCard extends StatefulWidget {
  const _BleTimingSettingsCard({
    required this.chunkWriteDelayMs,
    required this.commandResponseTimeoutSec,
    required this.onSave,
  });

  final int chunkWriteDelayMs;
  final int commandResponseTimeoutSec;
  final void Function(int chunkWriteDelayMs, int commandResponseTimeoutSec)
  onSave;

  @override
  State<_BleTimingSettingsCard> createState() => _BleTimingSettingsCardState();
}

class _BleTimingSettingsCardState extends State<_BleTimingSettingsCard> {
  late final TextEditingController _chunkController;
  late final TextEditingController _timeoutController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _chunkController = TextEditingController(
      text: widget.chunkWriteDelayMs.toString(),
    );
    _timeoutController = TextEditingController(
      text: widget.commandResponseTimeoutSec.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _BleTimingSettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chunkWriteDelayMs != widget.chunkWriteDelayMs) {
      _chunkController.text = widget.chunkWriteDelayMs.toString();
    }
    if (oldWidget.commandResponseTimeoutSec !=
        widget.commandResponseTimeoutSec) {
      _timeoutController.text = widget.commandResponseTimeoutSec.toString();
    }
  }

  @override
  void dispose() {
    _chunkController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  String? _validateChunkMs(String? raw) {
    final value = int.tryParse(raw?.trim() ?? '');
    if (value == null) {
      return 'Enter chunk interval in milliseconds.';
    }
    if (value < BleDrifterRuntimeSettings.minChunkWriteDelayMs ||
        value > BleDrifterRuntimeSettings.maxChunkWriteDelayMs) {
      return 'Use ${BleDrifterRuntimeSettings.minChunkWriteDelayMs}–'
          '${BleDrifterRuntimeSettings.maxChunkWriteDelayMs} ms.';
    }
    return null;
  }

  String? _validateTimeoutSec(String? raw) {
    final value = int.tryParse(raw?.trim() ?? '');
    if (value == null) {
      return 'Enter timeout in seconds.';
    }
    if (value < BleDrifterRuntimeSettings.minCommandResponseTimeoutSec ||
        value > BleDrifterRuntimeSettings.maxCommandResponseTimeoutSec) {
      return 'Use ${BleDrifterRuntimeSettings.minCommandResponseTimeoutSec}–'
          '${BleDrifterRuntimeSettings.maxCommandResponseTimeoutSec} seconds.';
    }
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    widget.onSave(
      int.parse(_chunkController.text.trim()),
      int.parse(_timeoutController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return _WhiteCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'BLE Command Timing',
              style: theme.compactSectionTitle(const Color(0xFF1D2329)),
            ),
            const SizedBox(height: 8),
            Text(
              'Chunk interval applies between each 20-character BLE write. '
              'Command timeout applies to every Self-Test / Debug response wait.',
              style: theme.compactSupportingText(const Color(0xFF6A7178)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _chunkController,
              keyboardType: TextInputType.number,
              validator: _validateChunkMs,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Chunk write interval (ms)',
                helperText:
                    'Delay between 20-character BLE chunks (default 3000).',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _timeoutController,
              keyboardType: TextInputType.number,
              validator: _validateTimeoutSec,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Command response timeout (sec)',
                helperText:
                    'Wait for device response ending with # (default 60).',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Save timing'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BluetoothGrid extends StatelessWidget {
  const _BluetoothGrid({required this.state, required this.onCellTap});

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
              Text(value, style: t.compactValueText(const Color(0xFF1D2329))),
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
  const _Header({required this.title, required this.onBackTap});

  final String title;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          AppIconCircleButton(onTap: onBackTap, icon: Icons.arrow_back),
          Expanded(
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF242A2F),
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
