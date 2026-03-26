import 'package:equatable/equatable.dart';

abstract class GeneralUserDashboardState extends Equatable {
  const GeneralUserDashboardState();

  bool get isAdmin;

  String get message;
}

class GeneralUserDashboardInitial extends GeneralUserDashboardState {
  const GeneralUserDashboardInitial();

  @override
  bool get isAdmin => false;

  @override
  String get message => '';

  @override
  List<Object?> get props => const [];
}

class GeneralUserDashboardLoading extends GeneralUserDashboardState {
  const GeneralUserDashboardLoading({required this.isAdmin});

  @override
  final bool isAdmin;

  @override
  String get message => '';

  @override
  List<Object?> get props => [isAdmin];
}

class GeneralUserDashboardLoaded extends GeneralUserDashboardState {
  const GeneralUserDashboardLoaded({required this.isAdmin});

  @override
  final bool isAdmin;

  @override
  String get message => '';

  @override
  List<Object?> get props => [isAdmin];
}

class GeneralUserDashboardError extends GeneralUserDashboardState {
  const GeneralUserDashboardError({required this.message});

  @override
  bool get isAdmin => false;

  @override
  final String message;

  @override
  List<Object?> get props => [message];
}
