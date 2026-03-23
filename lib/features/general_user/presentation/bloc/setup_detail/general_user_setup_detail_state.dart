import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_event.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserSetupDetailStatus { initial, loading, loaded, error }

class GeneralUserSetupDetailState extends Equatable {
  final GeneralUserSetupDetailStatus status;
  final SetupDetailTab selectedTab;
  final bool enableConfiguration;
  final String signalStrength;
  final String bluetoothDevice;
  final String lastSync;
  final String connectionStatus;
  final String memoryStatus;
  final String message;

  const GeneralUserSetupDetailState({
    required this.status,
    required this.selectedTab,
    required this.enableConfiguration,
    required this.signalStrength,
    required this.bluetoothDevice,
    required this.lastSync,
    required this.connectionStatus,
    required this.memoryStatus,
    required this.message,
  });

  const GeneralUserSetupDetailState.initial()
    : status = GeneralUserSetupDetailStatus.initial,
      selectedTab = SetupDetailTab.addNew,
      enableConfiguration = false,
      signalStrength = '--',
      bluetoothDevice = '--',
      lastSync = '--',
      connectionStatus = 'Disconnected',
      memoryStatus = '234 Logs',
      message = '';

  GeneralUserSetupDetailState copyWith({
    GeneralUserSetupDetailStatus? status,
    SetupDetailTab? selectedTab,
    bool? enableConfiguration,
    String? signalStrength,
    String? bluetoothDevice,
    String? lastSync,
    String? connectionStatus,
    String? memoryStatus,
    String? message,
  }) {
    return GeneralUserSetupDetailState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      enableConfiguration: enableConfiguration ?? this.enableConfiguration,
      signalStrength: signalStrength ?? this.signalStrength,
      bluetoothDevice: bluetoothDevice ?? this.bluetoothDevice,
      lastSync: lastSync ?? this.lastSync,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      memoryStatus: memoryStatus ?? this.memoryStatus,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [
    status,
    selectedTab,
    enableConfiguration,
    signalStrength,
    bluetoothDevice,
    lastSync,
    connectionStatus,
    memoryStatus,
    message,
  ];
}
