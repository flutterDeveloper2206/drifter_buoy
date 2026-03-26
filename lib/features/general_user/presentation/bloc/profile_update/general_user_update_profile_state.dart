import 'package:equatable/equatable.dart';

abstract class GeneralUserUpdateProfileState extends Equatable {
  const GeneralUserUpdateProfileState();

  @override
  List<Object?> get props => [];
}

class GeneralUserUpdateProfileInitial extends GeneralUserUpdateProfileState {
  const GeneralUserUpdateProfileInitial();
}

class GeneralUserUpdateProfileLoading extends GeneralUserUpdateProfileState {
  const GeneralUserUpdateProfileLoading();
}

class GeneralUserUpdateProfileSuccess extends GeneralUserUpdateProfileState {
  final String message;

  const GeneralUserUpdateProfileSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class GeneralUserUpdateProfileError extends GeneralUserUpdateProfileState {
  final String message;

  const GeneralUserUpdateProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

