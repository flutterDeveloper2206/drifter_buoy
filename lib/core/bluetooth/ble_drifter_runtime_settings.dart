import 'package:drifter_buoy/core/constants/ble_gatt_constants.dart';
import 'package:drifter_buoy/core/storage/app_prefs.dart';

/// User-adjustable BLE timing for drifter chunked writes and command responses.
class BleDrifterRuntimeSettings {
  BleDrifterRuntimeSettings({AppPrefs? appPrefs})
      : _appPrefs = appPrefs ?? AppPrefs();

  static const String prefChunkWriteDelayMsKey = 'ble_chunk_write_delay_ms';
  static const String prefCommandResponseTimeoutSecKey =
      'ble_command_response_timeout_sec';

  static const int minChunkWriteDelayMs = 0;
  static const int maxChunkWriteDelayMs = 120000;
  static const int minCommandResponseTimeoutSec = 1;
  static const int maxCommandResponseTimeoutSec = 7200;

  final AppPrefs _appPrefs;

  int _chunkWriteDelayMs = DrifterBleGatt.defaultChunkWriteDelayMs;
  int _commandResponseTimeoutSec =
      DrifterBleGatt.defaultCommandResponseTimeoutSec;

  int get chunkWriteDelayMs => _chunkWriteDelayMs;
  int get commandResponseTimeoutSec => _commandResponseTimeoutSec;

  Duration get chunkWriteDelay =>
      Duration(milliseconds: _chunkWriteDelayMs);

  Duration get commandResponseTimeout =>
      Duration(seconds: _commandResponseTimeoutSec);

  /// Applies the user-configured timeout for every drifter command response wait.
  Duration effectiveResponseTimeout(Duration catalogTimeout) =>
      commandResponseTimeout;

  Future<void> load() async {
    final chunk = await _appPrefs.getInt(prefChunkWriteDelayMsKey);
    final timeout = await _appPrefs.getInt(prefCommandResponseTimeoutSecKey);
    if (chunk != null) {
      _chunkWriteDelayMs = chunk.clamp(minChunkWriteDelayMs, maxChunkWriteDelayMs);
    }
    if (timeout != null) {
      _commandResponseTimeoutSec = timeout.clamp(
        minCommandResponseTimeoutSec,
        maxCommandResponseTimeoutSec,
      );
    }
  }

  Future<void> save({
    required int chunkWriteDelayMs,
    required int commandResponseTimeoutSec,
  }) async {
    if (chunkWriteDelayMs < minChunkWriteDelayMs ||
        chunkWriteDelayMs > maxChunkWriteDelayMs) {
      throw ArgumentError(
        'Chunk interval must be between $minChunkWriteDelayMs and '
        '$maxChunkWriteDelayMs ms.',
      );
    }
    if (commandResponseTimeoutSec < minCommandResponseTimeoutSec ||
        commandResponseTimeoutSec > maxCommandResponseTimeoutSec) {
      throw ArgumentError(
        'Command timeout must be between $minCommandResponseTimeoutSec and '
        '$maxCommandResponseTimeoutSec seconds.',
      );
    }
    _chunkWriteDelayMs = chunkWriteDelayMs;
    _commandResponseTimeoutSec = commandResponseTimeoutSec;
    await _appPrefs.setInt(prefChunkWriteDelayMsKey, chunkWriteDelayMs);
    await _appPrefs.setInt(
      prefCommandResponseTimeoutSecKey,
      commandResponseTimeoutSec,
    );
  }
}
