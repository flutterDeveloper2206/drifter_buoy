import 'package:equatable/equatable.dart';

abstract class GeneralUserLoginEvent extends Equatable {
  const GeneralUserLoginEvent();

  @override
  List<Object?> get props => [];
}

class GeneralUserLoginRequested extends GeneralUserLoginEvent {
  final String userName;
  final String password;

  const GeneralUserLoginRequested({
    required this.userName,
    required this.password,
  });

  @override
  List<Object?> get props => [userName, password];
}

