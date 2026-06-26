import 'package:equatable/equatable.dart';

abstract class GeneralUserChangePasswordState extends Equatable {
  const GeneralUserChangePasswordState();

  @override
  List<Object?> get props => [];
}

class GeneralUserChangePasswordInitial extends GeneralUserChangePasswordState {
  const GeneralUserChangePasswordInitial();
}

class GeneralUserChangePasswordLoading extends GeneralUserChangePasswordState {
  const GeneralUserChangePasswordLoading();
}

class GeneralUserChangePasswordSuccess extends GeneralUserChangePasswordState {
  const GeneralUserChangePasswordSuccess({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class GeneralUserChangePasswordError extends GeneralUserChangePasswordState {
  const GeneralUserChangePasswordError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
