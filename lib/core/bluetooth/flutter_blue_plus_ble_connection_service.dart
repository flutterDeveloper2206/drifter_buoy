import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math' show min;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:drifter_buoy/core/bluetooth/ble_drifter_runtime_settings.dart';
import 'package:drifter_buoy/core/bluetooth/ble_connection_service.dart';
import 'package:drifter_buoy/core/bluetooth/ble_scan_result.dart';
import 'package:drifter_buoy/core/constants/ble_gatt_constants.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Central-role BLE using [FlutterBluePlus]. For-profit apps may require a commercial FBP license.
class FlutterBluePlusBleConnectionService implements BleConnectionService {
  FlutterBluePlusBleConnectionService({
    BleDrifterRuntimeSettings? runtimeSettings,
  }) : _runtimeSettings = runtimeSettings ?? BleDrifterRuntimeSettings();

  final BleDrifterRuntimeSettings _runtimeSettings;
  String? _connectedRemoteId;
  final StreamController<String> _disconnectedRemoteIdsController =
      StreamController<String>.broadcast();
  StreamSubscription<BluetoothConnectionState>? _connectionStateSub;

  BluetoothCharacteristic? _drifterWriteChar;
  BluetoothCharacteristic? _drifterNotifyChar;
  StreamSubscription<List<int>>? _drifterNotifySub;
  final StringBuffer _drifterRxBuffer = StringBuffer();
  Completer<String>? _drifterLineCompleter;

  @override
  String? get connectedRemoteId => _connectedRemoteId;

  @override
  Stream<List<BleScanResult>> get scanResults =>
      FlutterBluePlus.scanResults.map(_dedupeAndSort);

  @override
  Stream<String> get disconnectedRemoteIds =>
      _disconnectedRemoteIdsController.stream;

  @override
  Future<void> ensureReadyForScan() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Bluetooth LE is not supported on web in this app.',
      );
    }
    if (!await FlutterBluePlus.isSupported) {
      throw StateError('Bluetooth is not supported on this device.');
    }

    await _requestPlatformPermissions();

    if (defaultTargetPlatform == TargetPlatform.android) {
      await FlutterBluePlus.turnOn();
    }

    final state = await FlutterBluePlus.adapterState
        .where((s) => s != BluetoothAdapterState.unknown)
        .first
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => BluetoothAdapterState.off,
        );

    if (state == BluetoothAdapterState.unauthorized) {
      throw StateError('Bluetooth permission was denied.');
    }
    if (state != BluetoothAdapterState.on) {
      throw StateError('Bluetooth is off. Turn it on to scan for devices.');
    }
  }

  Future<void> _requestPlatformPermissions() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final android = await DeviceInfoPlugin().androidInfo;
    final sdk = android.version.sdkInt;

    if (sdk >= 31) {
      final scan = await Permission.bluetoothScan.request();
      final connect = await Permission.bluetoothConnect.request();
      if (!scan.isGranted || !connect.isGranted) {
        throw StateError(
          'Bluetooth permissions are required to scan and connect.',
        );
      }
    } else {
      final location = await Permission.locationWhenInUse.request();
      if (!location.isGranted) {
        throw StateError(
          'Location permission is required for Bluetooth scanning on this Android version.',
        );
      }
    }
  }

  @override
  Future<void> startScan({Duration? timeout}) async {
    await FlutterBluePlus.startScan(
      timeout: timeout,
      androidUsesFineLocation: false,
    );
  }

  @override
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  @override
  Future<void> connect(String remoteId, {bool showFeedback = true}) async {
    if (_connectedRemoteId != null && _connectedRemoteId != remoteId) {
      await disconnect(showFeedback: false);
    }
    final device = BluetoothDevice.fromId(remoteId);
    await device.connect(
      license: License.free,
      timeout: const Duration(seconds: 35),
    );
    _connectedRemoteId = remoteId;
    await _connectionStateSub?.cancel();
    _connectionStateSub = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _handleConnectionDropped(remoteId);
      }
    });
    resetDrifterCommandChannel();
    if (showFeedback) {
      unawaited(
        AppFlushbar.success(
          'Connected to the buoy over Bluetooth.',
          title: 'Connected',
        ),
      );
    }
  }

  @override
  Future<void> disconnect({bool showFeedback = true}) async {
    final id = _connectedRemoteId;
    if (id == null) {
      return;
    }
    if (showFeedback) {
      unawaited(
        AppFlushbar.info(
          'Bluetooth was disconnected from this app.',
          title: 'Disconnected',
        ),
      );
    }
    try {
      await _connectionStateSub?.cancel();
      _connectionStateSub = null;
      resetDrifterCommandChannel();
      await BluetoothDevice.fromId(id).disconnect();
    } finally {
      _connectedRemoteId = null;
      _disconnectedRemoteIdsController.add(id);
    }
  }

  void _handleConnectionDropped(String remoteId) {
    if (_connectedRemoteId != remoteId) {
      return;
    }
    _connectionStateSub?.cancel();
    _connectionStateSub = null;
    resetDrifterCommandChannel();
    _connectedRemoteId = null;
    _disconnectedRemoteIdsController.add(remoteId);
    unawaited(
      AppFlushbar.info(
        'Connection lost. The buoy may be powered off, out of range, or the '
        'link was interrupted.',
        title: 'Connection lost',
      ),
    );
  }

  @override
  Future<void> prepareDrifterCommandChannel() async {
    final id = _connectedRemoteId;
    if (id == null) {
      throw StateError('Not connected to a buoy. Connect from Setup first.');
    }
    final device = BluetoothDevice.fromId(id);
    if (device.isDisconnected) {
      throw StateError('Device disconnected.');
    }

    if (_drifterWriteChar != null &&
        _drifterNotifyChar != null &&
        _drifterNotifySub != null) {
      await _drifterNotifyChar!.setNotifyValue(true);
      return;
    }

    await device.discoverServices(timeout: 30);

    final resolved = _resolveDrifterCharacteristics(device);
    final write = resolved.$1;
    final notify = resolved.$2;

    if (write == null || notify == null) {
      AppLogger.w(_summarizeGattTree(device));
      throw StateError(
        'Could not find BLE characteristics for commands. '
        'Need one writable characteristic and one with notify/indicate for replies. '
        'See logs above for what the peripheral exposes.',
      );
    }

    if (resolved.$3 != _DrifterResolutionMode.explicitUuid) {
      AppLogger.i(
        'Using auto-detected command channel: write=${write.uuid.str}, '
        'notify=${notify.uuid.str}',
      );
    }

    _drifterWriteChar = write;
    _drifterNotifyChar = notify;

    await _drifterNotifySub?.cancel();
    _drifterNotifySub = _drifterNotifyChar!.onValueReceived.listen(
      _onDrifterNotifyChunk,
    );
    await _drifterNotifyChar!.setNotifyValue(true);
  }

  void _onDrifterNotifyChunk(List<int> bytes) {
    if (bytes.isEmpty) {
      return;
    }
    _drifterRxBuffer.write(String.fromCharCodes(bytes));
    final acc = _drifterRxBuffer.toString();
    final hashIdx = acc.indexOf('#');
    if (hashIdx >= 0 &&
        _drifterLineCompleter != null &&
        !_drifterLineCompleter!.isCompleted) {
      final line = acc.substring(0, hashIdx + 1).trim();
      _drifterLineCompleter!.complete(line);
      _drifterLineCompleter = null;
      _drifterRxBuffer.clear();
    }
  }

  @override
  Future<String> sendDrifterAsciiCommand(
    String command,
    Duration responseTimeout,
  ) async {
    await prepareDrifterCommandChannel();
    final cmd = command.trim();
    if (cmd.isEmpty) {
      throw ArgumentError('Empty command');
    }

    _drifterRxBuffer.clear();
    _drifterLineCompleter = Completer<String>();

    _logBleIo('SEND_CMD', 'total ${cmd.length} chars | $cmd');
    await _writeDrifterChunked(cmd);

    final completer = _drifterLineCompleter;
    if (completer == null) {
      throw StateError('Command listener not ready.');
    }

    try {
      final wait = _runtimeSettings.effectiveResponseTimeout(responseTimeout);
      final responseLine = await completer.future.timeout(
        wait,
        onTimeout: () {
          _drifterLineCompleter = null;
          throw TimeoutException(
            'No response ending with # within ${wait.inSeconds}s',
            wait,
          );
        },
      );
      _logBleIo('RESPONSE', responseLine);
      return responseLine;
    } on TimeoutException {
      rethrow;
    }
  }

  static void _logBleIo(String direction, String payload) {
    final safe = payload.replaceAll('\r', '\\r').replaceAll('\n', '\\n');
    final msg = '[DrifterBLE][$direction] $safe';
    // Avoid debugPrint — it throttles/truncates long BLE lines. Full payloads for debugging:
    AppLogger.i(msg);
    // ignore: avoid_print — full BLE lines; debugPrint throttles/truncates.
    print(msg);
    developer.log(msg, name: 'DrifterBLE');
  }

  Future<void> _writeDrifterChunked(String ascii) async {
    final write = _drifterWriteChar;
    if (write == null) {
      throw StateError('Write characteristic not ready.');
    }
    const maxChars = DrifterBleGatt.maxCharactersPerChunk;
    final useWithoutResp =
        !write.properties.write && write.properties.writeWithoutResponse;

    if (ascii.length <= maxChars) {
      _logBleIo('SEND', 'single BLE write (${ascii.length} chars) | $ascii');
      await _writeBleChunk(write, ascii, useWithoutResp: useWithoutResp);
      return;
    }

    final totalChunks = (ascii.length + maxChars - 1) ~/ maxChars;
    _logBleIo(
      'SEND_CHUNKS',
      'splitting ${ascii.length} chars into $totalChunks writes of $maxChars chars each',
    );

    var index = 0;
    for (var i = 0; i < ascii.length; i += maxChars) {
      index++;
      final end = min(i + maxChars, ascii.length);
      final chunkText = ascii.substring(i, end);
      _logBleIo(
        'SEND_CHUNK',
        'BLE write $index/$totalChunks | chars[$i-${end - 1}] '
            '(${chunkText.length} chars) | $chunkText',
      );
      await _writeBleChunk(write, chunkText, useWithoutResp: useWithoutResp);
      if (end < ascii.length) {
        await Future<void>.delayed(_runtimeSettings.chunkWriteDelay);
      }
    }

    _logBleIo(
      'SEND_CHUNKS_DONE',
      'completed $totalChunks BLE write(s), ${ascii.length} chars total',
    );
  }

  Future<void> _writeBleChunk(
    BluetoothCharacteristic write,
    String chunkText, {
    required bool useWithoutResp,
  }) async {
    if (chunkText.length > DrifterBleGatt.maxCharactersPerChunk) {
      throw ArgumentError(
        'Chunk length ${chunkText.length} exceeds '
        '${DrifterBleGatt.maxCharactersPerChunk} characters.',
      );
    }
    final chunkBytes = utf8.encode(chunkText);
    if (chunkBytes.length > DrifterBleGatt.maxPayloadBytesPerWrite) {
      throw ArgumentError(
        'Chunk UTF-8 length ${chunkBytes.length} exceeds '
        '${DrifterBleGatt.maxPayloadBytesPerWrite} bytes.',
      );
    }
    await write.write(
      chunkBytes,
      withoutResponse: useWithoutResp,
      allowLongWrite: false,
    );
  }

  @override
  void resetDrifterCommandChannel() {
    _drifterNotifySub?.cancel();
    _drifterNotifySub = null;
    _drifterWriteChar = null;
    _drifterNotifyChar = null;
    _drifterRxBuffer.clear();
    if (_drifterLineCompleter != null && !_drifterLineCompleter!.isCompleted) {
      _drifterLineCompleter!.completeError(StateError('Connection closed'));
    }
    _drifterLineCompleter = null;
  }

  static List<BleScanResult> _dedupeAndSort(List<ScanResult> raw) {
    final best = <String, BleScanResult>{};
    for (final sr in raw) {
      final id = sr.device.remoteId.str;
      final name = _displayName(sr);
      final candidate = BleScanResult(
        remoteId: id,
        displayName: name,
        rssi: sr.rssi,
      );
      final existing = best[id];
      if (existing == null || candidate.rssi > existing.rssi) {
        best[id] = candidate;
      }
    }
    final list = best.values.toList()..sort((a, b) => b.rssi.compareTo(a.rssi));
    return list;
  }

  static String _displayName(ScanResult sr) {
    final adv = sr.advertisementData.advName.trim();
    final platform = sr.device.platformName.trim();
    final an = sr.device.advName.trim();
    for (final s in [adv, an, platform]) {
      if (s.isNotEmpty) {
        return s;
      }
    }
    return 'Unknown device';
  }

  /// Resolves UART-like pair: explicit UUIDs from [DrifterBleGatt], else any
  /// writable + any notify/indicate characteristic (prefer same service).
  static (
    BluetoothCharacteristic?,
    BluetoothCharacteristic?,
    _DrifterResolutionMode,
  )
  _resolveDrifterCharacteristics(BluetoothDevice device) {
    BluetoothCharacteristic? explicitWrite;
    BluetoothCharacteristic? explicitNotify;

    for (final s in device.servicesList) {
      if (s.uuid == DrifterBleGatt.serviceUuid) {
        for (final c in s.characteristics) {
          if (c.uuid == DrifterBleGatt.writeCharacteristicUuid) {
            explicitWrite = c;
          }
          if (c.uuid == DrifterBleGatt.notifyCharacteristicUuid) {
            explicitNotify = c;
          }
        }
      }
    }
    if (explicitWrite != null && explicitNotify != null) {
      return (
        explicitWrite,
        explicitNotify,
        _DrifterResolutionMode.explicitUuid,
      );
    }

    for (final s in device.servicesList) {
      final writes = s.characteristics
          .where(_characteristicIsWritable)
          .toList();
      final notifies = s.characteristics
          .where(_characteristicIsNotifiable)
          .toList();
      if (writes.isEmpty || notifies.isEmpty) {
        continue;
      }

      final w = writes.first;
      BluetoothCharacteristic n;
      try {
        n = notifies.firstWhere((c) => !_sameCharacteristic(c, w));
      } catch (_) {
        n = notifies.first;
      }
      return (w, n, _DrifterResolutionMode.heuristicSameService);
    }

    final allWrites = <BluetoothCharacteristic>[];
    final allNotifies = <BluetoothCharacteristic>[];
    for (final s in device.servicesList) {
      allWrites.addAll(s.characteristics.where(_characteristicIsWritable));
      allNotifies.addAll(s.characteristics.where(_characteristicIsNotifiable));
    }
    if (allWrites.isNotEmpty && allNotifies.isNotEmpty) {
      final w = allWrites.first;
      BluetoothCharacteristic n;
      try {
        n = allNotifies.firstWhere((c) => !_sameCharacteristic(c, w));
      } catch (_) {
        n = allNotifies.first;
      }
      return (w, n, _DrifterResolutionMode.heuristicGlobal);
    }

    return (null, null, _DrifterResolutionMode.failed);
  }

  static bool _characteristicIsWritable(BluetoothCharacteristic c) {
    final p = c.properties;
    return p.write || p.writeWithoutResponse;
  }

  static bool _characteristicIsNotifiable(BluetoothCharacteristic c) {
    final p = c.properties;
    return p.notify || p.indicate;
  }

  static bool _sameCharacteristic(
    BluetoothCharacteristic a,
    BluetoothCharacteristic b,
  ) {
    return a.uuid == b.uuid && a.instanceId == b.instanceId;
  }

  static String _summarizeGattTree(BluetoothDevice device) {
    final buf = StringBuffer('Discovered GATT:\n');
    for (final s in device.servicesList) {
      buf.writeln('  service ${s.uuid.str}');
      for (final c in s.characteristics) {
        final p = c.properties;
        buf.writeln(
          '    char ${c.uuid.str}  write=${p.write}/${p.writeWithoutResponse} '
          'notify=${p.notify}/${p.indicate} read=${p.read}',
        );
      }
    }
    return buf.toString();
  }
}

enum _DrifterResolutionMode {
  explicitUuid,
  heuristicSameService,
  heuristicGlobal,
  failed,
}
