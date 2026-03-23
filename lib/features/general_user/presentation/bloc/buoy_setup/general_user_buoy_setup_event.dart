import 'package:equatable/equatable.dart';

abstract class GeneralUserBuoySetupEvent extends Equatable {
  const GeneralUserBuoySetupEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserBuoySetup extends GeneralUserBuoySetupEvent {
  const LoadGeneralUserBuoySetup();
}

class UpdateGeneralUserBuoySetupField extends GeneralUserBuoySetupEvent {
  final BuoySetupField field;
  final String value;

  const UpdateGeneralUserBuoySetupField(this.field, this.value);

  @override
  List<Object> get props => [field, value];
}

class SaveGeneralUserBuoySetup extends GeneralUserBuoySetupEvent {
  const SaveGeneralUserBuoySetup();
}

enum BuoySetupField {
  stationId,
  stationName,
  transmissionInterval,
  transmissionStartTime,
}
