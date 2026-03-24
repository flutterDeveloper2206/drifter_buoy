import 'package:equatable/equatable.dart';

abstract class GeneralUserSetupDetailEvent extends Equatable {
  const GeneralUserSetupDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserSetupDetail extends GeneralUserSetupDetailEvent {
  const LoadGeneralUserSetupDetail();
}

class ToggleGeneralUserEnableConfiguration extends GeneralUserSetupDetailEvent {
  const ToggleGeneralUserEnableConfiguration();
}

class ClearBluetoothSetup extends GeneralUserSetupDetailEvent {
  const ClearBluetoothSetup();
}

class SelectBluetoothDevice extends GeneralUserSetupDetailEvent {
  const SelectBluetoothDevice({
    required this.displayName,
    required this.bluetoothId,
  });

  final String displayName;
  final String bluetoothId;

  @override
  List<Object?> get props => [displayName, bluetoothId];
}
