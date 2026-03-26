import 'package:equatable/equatable.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_map_dashboard_get_buoy_dashboard_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_map_dashboard_get_buoy_map_dashboard_response.dart';

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
  const GeneralUserDashboardLoaded({
    required this.isAdmin,
    required this.data,
    required this.mapData,
  });

  @override
  final bool isAdmin;

  final UserMapDashboardGetBuoyDashboardResult data;
  final List<UserMapDashboardGetBuoyMapDashboardItem> mapData;

  @override
  String get message => '';

  @override
  List<Object?> get props => [isAdmin, data, mapData];
}

class GeneralUserDashboardError extends GeneralUserDashboardState {
  const GeneralUserDashboardError({
    required this.message,
    required this.isAdmin,
  });

  @override
  final bool isAdmin;

  @override
  final String message;

  @override
  List<Object?> get props => [message, isAdmin];
}
