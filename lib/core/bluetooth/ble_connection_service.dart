import 'package:drifter_buoy/core/bluetooth/ble_scan_result.dart';

/// App-facing BLE API. Implementations must not leak `flutter_blue_plus` types.
abstract class BleConnectionService {
  /// Combined scan results, deduplicated by [BleScanResult.remoteId] (best RSSI kept).
  Stream<List<BleScanResult>> get scanResults;

  /// Emits remote id whenever connection drops (manual or unexpected).
  Stream<String> get disconnectedRemoteIds;

  /// Throws if Bluetooth is unsupported, permissions are denied, or the adapter stays off.
  Future<void> ensureReadyForScan();

  Future<void> startScan({Duration? timeout});

  Future<void> stopScan();

  /// Connect to a device discovered in a previous scan ([BleScanResult.remoteId]).
  /// Set [showFeedback] false when the UI layer shows its own message (e.g. bottom sheet).
  Future<void> connect(String remoteId, {bool showFeedback = true});

  /// Set [showFeedback] false when chaining disconnect during device switch.
  Future<void> disconnect({bool showFeedback = true});

  /// Remote id of the device last successfully connected by this service, if any.
  String? get connectedRemoteId;

  /// Discover UART-like service, enable notify on the inbound characteristic.
  Future<void> prepareDrifterCommandChannel();

  /// Writes [command] in **20-character** chunks (spaces preserved), then waits for
  /// one ASCII line ending with `#` within [responseTimeout].
  Future<String> sendDrifterAsciiCommand(
    String command,
    Duration responseTimeout,
  );

  /// Drops cached characteristics and notify subscription (call on disconnect).
  void resetDrifterCommandChannel();
}
