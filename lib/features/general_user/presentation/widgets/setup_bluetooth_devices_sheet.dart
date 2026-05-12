import 'dart:async';

import 'package:drifter_buoy/core/bluetooth/ble_connection_service.dart';
import 'package:drifter_buoy/core/bluetooth/ble_scan_result.dart';
import 'package:drifter_buoy/core/theme/app_typography.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:flutter/material.dart';

/// Opens the scanner sheet. [onConnected] runs when a device links successfully; the sheet
/// stays open until the user taps **Done** (then one success Flushbar is shown).
Future<void> showSetupBluetoothDeviceSheet(
  BuildContext context, {
  BleConnectionService? ble,
  void Function(String displayName, String remoteId)? onConnected,
}) {
  final BleConnectionService resolved = ble ?? sl<BleConnectionService>();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x99000000),
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: _SetupBluetoothDevicesSheet(
          ble: resolved,
          onConnected: onConnected,
        ),
      );
    },
  );
}

class _SetupBluetoothDevicesSheet extends StatefulWidget {
  const _SetupBluetoothDevicesSheet({
    required this.ble,
    this.onConnected,
  });

  final BleConnectionService ble;
  final void Function(String displayName, String remoteId)? onConnected;

  @override
  State<_SetupBluetoothDevicesSheet> createState() =>
      _SetupBluetoothDevicesSheetState();
}

class _SetupBluetoothDevicesSheetState extends State<_SetupBluetoothDevicesSheet> {
  StreamSubscription<List<BleScanResult>>? _scanSub;
  List<BleScanResult> _results = [];
  String? _prepareError;
  bool _preparing = true;
  String? _connectingRemoteId;
  String? _connectedDisplayName;
  String? _connectedRemoteId;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      await widget.ble.ensureReadyForScan();
      if (!mounted) {
        return;
      }
      _scanSub = widget.ble.scanResults.listen(
        (list) {
          if (mounted) {
            setState(() => _results = list);
          }
        },
        onError: (Object e, StackTrace st) {
          if (mounted) {
            setState(() => _prepareError ??= e.toString());
          }
        },
      );
      await widget.ble.startScan();
      if (mounted) {
        setState(() => _preparing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _prepareError = e.toString();
          _preparing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    unawaited(widget.ble.stopScan());
    super.dispose();
  }

  void _showFlushbarAfterSheetClosed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        AppFlushbar.success(
          'Bluetooth device is connected and ready.',
          title: 'Connected',
        ),
      );
    });
  }

  Future<void> _onPick(BleScanResult device) async {
    setState(() => _connectingRemoteId = device.remoteId);
    try {
      await widget.ble.connect(device.remoteId, showFeedback: false);
      if (!mounted) {
        return;
      }
      widget.onConnected?.call(device.displayName, device.remoteId);
      setState(() {
        _connectingRemoteId = null;
        _connectedDisplayName = device.displayName;
        _connectedRemoteId = device.remoteId;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      unawaited(
        AppFlushbar.error(
          'Could not connect: $e',
          title: 'Connection failed',
        ),
      );
      setState(() => _connectingRemoteId = null);
    }
  }

  void _onDone() {
    Navigator.of(context).pop();
    _showFlushbarAfterSheetClosed();
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.55;
    final connected = _connectedRemoteId != null;

    return SizedBox(
      height: sheetHeight,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 14),
            Text(
              'Bluetooth',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.compactAppBarTitle(
                    const Color(0xFF1D2329),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Nearby Bluetooth Devices',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.compactSupportingText(
                    const Color(0xFF70757A),
                  ),
            ),
            const SizedBox(height: 12),
            if (connected && _connectedDisplayName != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Material(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF2E7D32),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Connected to $_connectedDisplayName. Tap Done when finished.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF1B5E20),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_prepareError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  _prepareError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFB3261E),
                      ),
                ),
              ),
            Expanded(
              child: _preparing
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Searching for devices…',
                              style: TextStyle(
                                color: Color(0xFF70757A),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE8EBED),
                          ),
                          itemBuilder: (context, index) {
                            final d = _results[index];
                            final connecting = _connectingRemoteId == d.remoteId;
                            final linked =
                                widget.ble.connectedRemoteId == d.remoteId;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              title: Text(
                                d.displayName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: const Color(0xFF2A2F34),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              subtitle: Text(
                                '${d.remoteId} · ${d.rssi} dBm',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: const Color(0xFF8A9095),
                                      fontSize: 11,
                                    ),
                              ),
                              trailing: connecting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : linked
                                      ? const Icon(
                                          Icons.link_rounded,
                                          color: Color(0xFF206BBE),
                                          size: 22,
                                        )
                                      : null,
                              onTap: connecting
                                  ? null
                                  : () {
                                      unawaited(_onPick(d));
                                    },
                            );
                          },
                        ),
            ),
            if (connected)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  onPressed: _onDone,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF206BBE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
