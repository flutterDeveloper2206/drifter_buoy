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
