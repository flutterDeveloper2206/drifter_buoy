import 'package:equatable/equatable.dart';

abstract class GeneralUserDashboardEvent extends Equatable {
  const GeneralUserDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserDashboard extends GeneralUserDashboardEvent {
  final bool isAdmin;

  const LoadGeneralUserDashboard({required this.isAdmin});

  @override
  List<Object> get props => [isAdmin];
}
