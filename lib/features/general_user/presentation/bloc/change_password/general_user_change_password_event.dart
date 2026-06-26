import 'package:equatable/equatable.dart';

abstract class GeneralUserChangePasswordEvent extends Equatable {
  const GeneralUserChangePasswordEvent();

  @override
  List<Object?> get props => [];
}

class ChangeGeneralUserPasswordRequested extends GeneralUserChangePasswordEvent {
  const ChangeGeneralUserPasswordRequested({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}
