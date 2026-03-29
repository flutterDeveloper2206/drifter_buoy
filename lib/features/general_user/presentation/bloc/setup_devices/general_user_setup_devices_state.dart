import 'package:equatable/equatable.dart';

enum GeneralUserSetupDevicesStatus { initial, loading, loaded, error }

enum GeneralUserSetupDeviceConnectionStatus { active, offline, batteryLow }

class GeneralUserSetupDeviceItem extends Equatable {
  const GeneralUserSetupDeviceItem({
    required this.id,
    required this.lastUpdate,
    required this.battery,
    required this.gps,
    required this.signal,
    required this.connectionStatus,
    required this.statusLabel,
  });

  final String id;
  final String lastUpdate;
  final String battery;
  final String gps;
  final String signal;
  final GeneralUserSetupDeviceConnectionStatus connectionStatus;
  final String statusLabel;

  @override
  List<Object> get props => [
    id,
    lastUpdate,
    battery,
    gps,
    signal,
    connectionStatus,
    statusLabel,
  ];
}

class GeneralUserSetupDevicesState extends Equatable {
  const GeneralUserSetupDevicesState({
    required this.status,
    required this.query,
    required this.allDevices,
    required this.filteredDevices,
    required this.message,
  });

  final GeneralUserSetupDevicesStatus status;
  final String query;
  final List<GeneralUserSetupDeviceItem> allDevices;
  final List<GeneralUserSetupDeviceItem> filteredDevices;
  final String message;

  const GeneralUserSetupDevicesState.initial()
    : status = GeneralUserSetupDevicesStatus.initial,
      query = '',
      allDevices = const [],
      filteredDevices = const [],
      message = '';

  GeneralUserSetupDevicesState copyWith({
    GeneralUserSetupDevicesStatus? status,
    String? query,
    List<GeneralUserSetupDeviceItem>? allDevices,
    List<GeneralUserSetupDeviceItem>? filteredDevices,
    String? message,
  }) {
    return GeneralUserSetupDevicesState(
      status: status ?? this.status,
      query: query ?? this.query,
      allDevices: allDevices ?? this.allDevices,
      filteredDevices: filteredDevices ?? this.filteredDevices,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [
    status,
    query,
    allDevices,
    filteredDevices,
    message,
  ];
}
