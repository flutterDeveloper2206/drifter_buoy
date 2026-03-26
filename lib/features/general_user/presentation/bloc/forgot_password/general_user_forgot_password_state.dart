import 'package:equatable/equatable.dart';

abstract class GeneralUserForgotPasswordState extends Equatable {
  const GeneralUserForgotPasswordState();
}

class GeneralUserForgotPasswordInitial extends GeneralUserForgotPasswordState {
  const GeneralUserForgotPasswordInitial();

  @override
  List<Object?> get props => const [];
}

class GeneralUserForgotPasswordRequestingCode
    extends GeneralUserForgotPasswordState {
  const GeneralUserForgotPasswordRequestingCode();

  @override
  List<Object?> get props => const [];
}

class GeneralUserForgotPasswordCodeRequested
    extends GeneralUserForgotPasswordState {
  final String message;

  const GeneralUserForgotPasswordCodeRequested({required this.message});

  @override
  List<Object?> get props => [message];
}

class GeneralUserForgotPasswordVerifyingCode
    extends GeneralUserForgotPasswordState {
  const GeneralUserForgotPasswordVerifyingCode();

  @override
  List<Object?> get props => const [];
}

class GeneralUserForgotPasswordVerified extends GeneralUserForgotPasswordState {
  final String resetToken;

  const GeneralUserForgotPasswordVerified({required this.resetToken});

  @override
  List<Object?> get props => [resetToken];
}

class GeneralUserForgotPasswordError extends GeneralUserForgotPasswordState {
  final String message;

  const GeneralUserForgotPasswordError({required this.message});

  @override
  List<Object?> get props => [message];
}

