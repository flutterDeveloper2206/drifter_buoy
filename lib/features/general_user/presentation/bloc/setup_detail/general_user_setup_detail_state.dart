import 'package:drifter_buoy/core/constants/ble_gatt_constants.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserSetupDetailStatus { initial, loading, loaded, error }

class GeneralUserSetupDetailState extends Equatable {
  final GeneralUserSetupDetailStatus status;
  final bool enableConfiguration;
  final String signalStrength;
  final String bluetoothDevice;
  final String? bluetoothRemoteId;
  final String lastSync;
  final String connectionStatus;
  final String memoryStatus;
  final String message;
  final String? contextBuoyId;
  final int chunkWriteDelayMs;
  final int commandResponseTimeoutSec;
  final String bleSettingsMessage;
  final bool bleSettingsMessageIsSuccess;

  const GeneralUserSetupDetailState({
    required this.status,
    required this.enableConfiguration,
    required this.signalStrength,
    required this.bluetoothDevice,
    this.bluetoothRemoteId,
    required this.lastSync,
    required this.connectionStatus,
    required this.memoryStatus,
    required this.message,
    required this.contextBuoyId,
    required this.chunkWriteDelayMs,
    required this.commandResponseTimeoutSec,
    this.bleSettingsMessage = '',
    this.bleSettingsMessageIsSuccess = false,
  });

  const GeneralUserSetupDetailState.initial()
    : status = GeneralUserSetupDetailStatus.initial,
      enableConfiguration = false,
      signalStrength = '--',
      bluetoothDevice = '--',
      bluetoothRemoteId = null,
      lastSync = '--',
      connectionStatus = 'Disconnected',
      memoryStatus = '0 Records',
      message = '',
      contextBuoyId = null,
      chunkWriteDelayMs = DrifterBleGatt.defaultChunkWriteDelayMs,
      commandResponseTimeoutSec =
          DrifterBleGatt.defaultCommandResponseTimeoutSec,
      bleSettingsMessage = '',
      bleSettingsMessageIsSuccess = false;

  GeneralUserSetupDetailState copyWith({
    GeneralUserSetupDetailStatus? status,
    bool? enableConfiguration,
    String? signalStrength,
    String? bluetoothDevice,
    String? bluetoothRemoteId,
    bool clearBluetoothRemoteId = false,
    String? lastSync,
    String? connectionStatus,
    String? memoryStatus,
    String? message,
    String? contextBuoyId,
    int? chunkWriteDelayMs,
    int? commandResponseTimeoutSec,
    String? bleSettingsMessage,
    bool? bleSettingsMessageIsSuccess,
    bool clearBleSettingsMessage = false,
  }) {
    return GeneralUserSetupDetailState(
      status: status ?? this.status,
      enableConfiguration: enableConfiguration ?? this.enableConfiguration,
      signalStrength: signalStrength ?? this.signalStrength,
      bluetoothDevice: bluetoothDevice ?? this.bluetoothDevice,
      bluetoothRemoteId: clearBluetoothRemoteId
          ? null
          : (bluetoothRemoteId ?? this.bluetoothRemoteId),
      lastSync: lastSync ?? this.lastSync,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      memoryStatus: memoryStatus ?? this.memoryStatus,
      message: message ?? this.message,
      contextBuoyId: contextBuoyId ?? this.contextBuoyId,
      chunkWriteDelayMs: chunkWriteDelayMs ?? this.chunkWriteDelayMs,
      commandResponseTimeoutSec:
          commandResponseTimeoutSec ?? this.commandResponseTimeoutSec,
      bleSettingsMessage: clearBleSettingsMessage
          ? ''
          : (bleSettingsMessage ?? this.bleSettingsMessage),
      bleSettingsMessageIsSuccess:
          bleSettingsMessageIsSuccess ?? this.bleSettingsMessageIsSuccess,
    );
  }

  @override
  List<Object?> get props => [
    status,
    enableConfiguration,
    signalStrength,
    bluetoothDevice,
    bluetoothRemoteId,
    lastSync,
    connectionStatus,
    memoryStatus,
    message,
    contextBuoyId,
    chunkWriteDelayMs,
    commandResponseTimeoutSec,
    bleSettingsMessage,
    bleSettingsMessageIsSuccess,
  ];
}
