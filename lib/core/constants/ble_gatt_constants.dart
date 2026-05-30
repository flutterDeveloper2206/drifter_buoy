import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// GATT UUIDs for drifter buoy serial-style commands (phone writes, device notifies).
///
/// Defaults match the common **Nordic UART Service** layout. If these UUIDs are not
/// present, the BLE service falls back to the first writable
/// characteristic plus the first notify/indicate characteristic (preferring both in
/// the same service). For deterministic pairing, set UUIDs here to match firmware.
class DrifterBleGatt {
  DrifterBleGatt._();

  static final Guid serviceUuid = Guid('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');

  /// Central writes outbound ASCII commands here (Nordic UART **RX** characteristic).
  static final Guid writeCharacteristicUuid = Guid(
    '6E400002-B5A3-F393-E0A9-E50E24DCCA9E',
  );

  /// Central subscribes for inbound data here (Nordic UART **TX** characteristic).
  static final Guid notifyCharacteristicUuid = Guid(
    '6E400003-B5A3-F393-E0A9-E50E24DCCA9E',
  );

  /// Drifter buoy accepts outbound commands in **20-character** ASCII frames per write.
  static const int maxCharactersPerChunk = 20;

  /// Same as [maxCharactersPerChunk] for ATT payload limit at default MTU 23.
  static const int maxPayloadBytesPerWrite = maxCharactersPerChunk;

  /// Pause between chunked writes so UART-style peripherals can absorb each frame.
  static const Duration delayBetweenChunkWrites = Duration(milliseconds: 15);
}
