import 'package:equatable/equatable.dart';

abstract class GeneralUserDashboardEvent extends Equatable {
  const GeneralUserDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserDashboard extends GeneralUserDashboardEvent {
  final bool isAdmin;

  /// When true, keeps the current dashboard visible while refreshing (no
  /// full-screen shimmer or command-setup overlay when commands are cached).
  final bool silent;

  const LoadGeneralUserDashboard({
    required this.isAdmin,
    this.silent = false,
  });

  @override
  List<Object> get props => [isAdmin, silent];
}
