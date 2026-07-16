import 'package:equatable/equatable.dart';

abstract class GeneralUserSetupDetailEvent extends Equatable {
  const GeneralUserSetupDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserSetupDetail extends GeneralUserSetupDetailEvent {
  const LoadGeneralUserSetupDetail({this.buoyId});

  /// When set (e.g. from setup list), detail flow is scoped to this buoy.
  final String? buoyId;

  @override
  List<Object?> get props => [buoyId];
}

class ToggleGeneralUserEnableConfiguration extends GeneralUserSetupDetailEvent {
  const ToggleGeneralUserEnableConfiguration();
}

class ClearBluetoothSetup extends GeneralUserSetupDetailEvent {
  const ClearBluetoothSetup();
}

class SyncBluetoothDisconnected extends GeneralUserSetupDetailEvent {
  const SyncBluetoothDisconnected();
}

class SelectBluetoothDevice extends GeneralUserSetupDetailEvent {
  const SelectBluetoothDevice({
    required this.displayName,
    required this.bluetoothId,
    this.rssi = -70,
  });

  final String displayName;
  final String bluetoothId;

  /// Scan RSSI in dBm at connect time (optional; default used if omitted).
  final int rssi;

  @override
  List<Object?> get props => [displayName, bluetoothId, rssi];
}

class SaveBleTimingSettings extends GeneralUserSetupDetailEvent {
  const SaveBleTimingSettings({
    required this.chunkWriteDelayMs,
    required this.commandResponseTimeoutSec,
  });

  final int chunkWriteDelayMs;
  final int commandResponseTimeoutSec;

  @override
  List<Object?> get props => [chunkWriteDelayMs, commandResponseTimeoutSec];
}

class ClearBleTimingSettingsMessage extends GeneralUserSetupDetailEvent {
  const ClearBleTimingSettingsMessage();
}
