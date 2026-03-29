import 'package:equatable/equatable.dart';

enum GeneralUserSetupDetailStatus { initial, loading, loaded, error }

class GeneralUserSetupDetailState extends Equatable {
  final GeneralUserSetupDetailStatus status;
  final bool enableConfiguration;
  final String signalStrength;
  final String bluetoothDevice;
  final String lastSync;
  final String connectionStatus;
  final String memoryStatus;
  final String message;
  final String? contextBuoyId;

  const GeneralUserSetupDetailState({
    required this.status,
    required this.enableConfiguration,
    required this.signalStrength,
    required this.bluetoothDevice,
    required this.lastSync,
    required this.connectionStatus,
    required this.memoryStatus,
    required this.message,
    required this.contextBuoyId,
  });

  const GeneralUserSetupDetailState.initial()
    : status = GeneralUserSetupDetailStatus.initial,
      enableConfiguration = false,
      signalStrength = '--',
      bluetoothDevice = '--',
      lastSync = '--',
      connectionStatus = 'Disconnected',
      memoryStatus = '0 Records',
      message = '',
      contextBuoyId = null;

  GeneralUserSetupDetailState copyWith({
    GeneralUserSetupDetailStatus? status,
    bool? enableConfiguration,
    String? signalStrength,
    String? bluetoothDevice,
    String? lastSync,
    String? connectionStatus,
    String? memoryStatus,
    String? message,
    String? contextBuoyId,
  }) {
    return GeneralUserSetupDetailState(
      status: status ?? this.status,
      enableConfiguration: enableConfiguration ?? this.enableConfiguration,
      signalStrength: signalStrength ?? this.signalStrength,
      bluetoothDevice: bluetoothDevice ?? this.bluetoothDevice,
      lastSync: lastSync ?? this.lastSync,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      memoryStatus: memoryStatus ?? this.memoryStatus,
      message: message ?? this.message,
      contextBuoyId: contextBuoyId ?? this.contextBuoyId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    enableConfiguration,
    signalStrength,
    bluetoothDevice,
    lastSync,
    connectionStatus,
    memoryStatus,
    message,
    contextBuoyId,
  ];
}
