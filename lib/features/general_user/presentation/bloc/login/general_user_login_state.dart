import 'package:equatable/equatable.dart';

abstract class GeneralUserLoginState extends Equatable {
  const GeneralUserLoginState();
}

class GeneralUserLoginInitial extends GeneralUserLoginState {
  const GeneralUserLoginInitial();

  @override
  List<Object?> get props => const [];
}

class GeneralUserLoginLoading extends GeneralUserLoginState {
  const GeneralUserLoginLoading();

  @override
  List<Object?> get props => const [];
}

class GeneralUserLoginAuthenticated extends GeneralUserLoginState {
  final bool isAdmin;
  final String token;
  final String userId;
  final String roleName;

  const GeneralUserLoginAuthenticated({
    required this.isAdmin,
    required this.token,
    required this.userId,
    required this.roleName,
  });

  @override
  List<Object?> get props => [isAdmin, token, userId, roleName];
}

class GeneralUserLoginError extends GeneralUserLoginState {
  final String message;

  const GeneralUserLoginError({required this.message});

  @override
  List<Object?> get props => [message];
}

