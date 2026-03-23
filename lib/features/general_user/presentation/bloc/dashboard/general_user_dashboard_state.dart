import 'package:equatable/equatable.dart';

enum GeneralUserDashboardStatus { initial, loading, loaded, error }

class GeneralUserDashboardState extends Equatable {
  final GeneralUserDashboardStatus status;
  final bool isAdmin;
  final String message;

  const GeneralUserDashboardState({
    required this.status,
    required this.isAdmin,
    required this.message,
  });

  const GeneralUserDashboardState.initial()
    : status = GeneralUserDashboardStatus.initial,
      isAdmin = false,
      message = '';

  GeneralUserDashboardState copyWith({
    GeneralUserDashboardStatus? status,
    bool? isAdmin,
    String? message,
  }) {
    return GeneralUserDashboardState(
      status: status ?? this.status,
      isAdmin: isAdmin ?? this.isAdmin,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [status, isAdmin, message];
}
