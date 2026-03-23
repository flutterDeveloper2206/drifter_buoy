import 'package:equatable/equatable.dart';

abstract class GeneralUserProfileEvent extends Equatable {
  const GeneralUserProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserProfile extends GeneralUserProfileEvent {
  const LoadGeneralUserProfile();
}

class RequestGeneralUserLogout extends GeneralUserProfileEvent {
  const RequestGeneralUserLogout();
}

class ClearGeneralUserProfileMessage extends GeneralUserProfileEvent {
  const ClearGeneralUserProfileMessage();
}
