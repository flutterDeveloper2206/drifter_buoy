import 'package:equatable/equatable.dart';

abstract class GeneralUserCreatePasswordState extends Equatable {
  const GeneralUserCreatePasswordState();
}

class GeneralUserCreatePasswordInitial extends GeneralUserCreatePasswordState {
  const GeneralUserCreatePasswordInitial();

  @override
  List<Object?> get props => const [];
}

class GeneralUserCreatePasswordLoading
    extends GeneralUserCreatePasswordState {
  const GeneralUserCreatePasswordLoading();

  @override
  List<Object?> get props => const [];
}

class GeneralUserCreatePasswordSuccess extends GeneralUserCreatePasswordState {
  final String message;

  const GeneralUserCreatePasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class GeneralUserCreatePasswordError extends GeneralUserCreatePasswordState {
  final String message;

  const GeneralUserCreatePasswordError({required this.message});

  @override
  List<Object?> get props => [message];
}

