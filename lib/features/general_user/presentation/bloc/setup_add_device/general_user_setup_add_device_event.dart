import 'package:equatable/equatable.dart';

abstract class GeneralUserSetupAddDeviceEvent extends Equatable {
  const GeneralUserSetupAddDeviceEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserSetupAddDevice extends GeneralUserSetupAddDeviceEvent {
  const LoadGeneralUserSetupAddDevice();
}

class SelectGeneralUserNearbyDevice extends GeneralUserSetupAddDeviceEvent {
  final String deviceName;

  const SelectGeneralUserNearbyDevice(this.deviceName);

  @override
  List<Object> get props => [deviceName];
}
