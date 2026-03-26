import 'package:equatable/equatable.dart';

abstract class GeneralUserUpdateProfileEvent extends Equatable {
  const GeneralUserUpdateProfileEvent();

  @override
  List<Object?> get props => [];
}

class UpdateGeneralUserProfileRequested
    extends GeneralUserUpdateProfileEvent {
  final String userId;
  final String firstName;
  final String middleName;
  final String lastName;
  final String mobileNumber;
  final String emailAddress;

  const UpdateGeneralUserProfileRequested({
    required this.userId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.mobileNumber,
    required this.emailAddress,
  });

  @override
  List<Object?> get props => [
        userId,
        firstName,
        middleName,
        lastName,
        mobileNumber,
        emailAddress,
      ];
}

