import 'package:equatable/equatable.dart';

abstract class GeneralUserCreatePasswordEvent extends Equatable {
  const GeneralUserCreatePasswordEvent();

  @override
  List<Object?> get props => [];
}

class GeneralUserCreatePasswordRequested
    extends GeneralUserCreatePasswordEvent {
  final String newPassword;
  final String confirmPassword;

  const GeneralUserCreatePasswordRequested({
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [newPassword, confirmPassword];
}

