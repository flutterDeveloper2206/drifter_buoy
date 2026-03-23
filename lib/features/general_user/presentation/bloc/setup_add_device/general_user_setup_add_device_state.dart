import 'package:equatable/equatable.dart';

enum GeneralUserSetupAddDeviceStatus { initial, loading, loaded, error }

class GeneralUserSetupAddDeviceState extends Equatable {
  final GeneralUserSetupAddDeviceStatus status;
  final bool enableConfiguration;
  final String signalStrength;
  final String bluetoothDevice;
  final String lastSync;
  final String connectionStatus;
  final String memoryStatus;
  final List<String> nearbyDevices;
  final String? selectedDevice;
  final String message;

  const GeneralUserSetupAddDeviceState({
    required this.status,
    required this.enableConfiguration,
    required this.signalStrength,
    required this.bluetoothDevice,
    required this.lastSync,
    required this.connectionStatus,
    required this.memoryStatus,
    required this.nearbyDevices,
    required this.selectedDevice,
    required this.message,
  });

  const GeneralUserSetupAddDeviceState.initial()
    : status = GeneralUserSetupAddDeviceStatus.initial,
      enableConfiguration = true,
      signalStrength = '--',
      bluetoothDevice = '--',
      lastSync = '--',
      connectionStatus = 'Disconnected',
      memoryStatus = '0 Records',
      nearbyDevices = const [],
      selectedDevice = null,
      message = '';

  GeneralUserSetupAddDeviceState copyWith({
    GeneralUserSetupAddDeviceStatus? status,
    bool? enableConfiguration,
    String? signalStrength,
    String? bluetoothDevice,
    String? lastSync,
    String? connectionStatus,
    String? memoryStatus,
    List<String>? nearbyDevices,
    String? selectedDevice,
    bool clearSelectedDevice = false,
    String? message,
  }) {
    return GeneralUserSetupAddDeviceState(
      status: status ?? this.status,
      enableConfiguration: enableConfiguration ?? this.enableConfiguration,
      signalStrength: signalStrength ?? this.signalStrength,
      bluetoothDevice: bluetoothDevice ?? this.bluetoothDevice,
      lastSync: lastSync ?? this.lastSync,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      memoryStatus: memoryStatus ?? this.memoryStatus,
      nearbyDevices: nearbyDevices ?? this.nearbyDevices,
      selectedDevice: clearSelectedDevice
          ? null
          : (selectedDevice ?? this.selectedDevice),
      message: message ?? this.message,
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
    nearbyDevices,
    selectedDevice,
    message,
  ];
}
