import 'package:equatable/equatable.dart';

abstract class GeneralUserForgotPasswordEvent extends Equatable {
  const GeneralUserForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class RequestVerificationCodeRequested
    extends GeneralUserForgotPasswordEvent {
  final String emailAddress;

  const RequestVerificationCodeRequested({
    required this.emailAddress,
  });

  @override
  List<Object?> get props => [emailAddress];
}

class VerifyVerificationCodeRequested
    extends GeneralUserForgotPasswordEvent {
  final String emailAddress;
  final String verificationCode;

  const VerifyVerificationCodeRequested({
    required this.emailAddress,
    required this.verificationCode,
  });

  @override
  List<Object?> get props => [emailAddress, verificationCode];
}

