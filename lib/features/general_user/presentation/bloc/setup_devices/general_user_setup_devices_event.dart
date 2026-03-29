import 'package:equatable/equatable.dart';

abstract class GeneralUserSetupDevicesEvent extends Equatable {
  const GeneralUserSetupDevicesEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserSetupDevices extends GeneralUserSetupDevicesEvent {
  const LoadGeneralUserSetupDevices();
}

class UpdateGeneralUserSetupDevicesQuery extends GeneralUserSetupDevicesEvent {
  const UpdateGeneralUserSetupDevicesQuery(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

class ClearGeneralUserSetupDevicesQuery extends GeneralUserSetupDevicesEvent {
  const ClearGeneralUserSetupDevicesQuery();
}
