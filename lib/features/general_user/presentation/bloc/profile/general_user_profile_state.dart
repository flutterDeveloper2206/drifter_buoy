import 'package:equatable/equatable.dart';

enum GeneralUserProfileStatus { initial, loading, loaded, error }

class GeneralUserProfileData extends Equatable {
  final String fullName;
  final String email;
  final String role;
  final String phone;

  const GeneralUserProfileData({
    required this.fullName,
    required this.email,
    required this.role,
    required this.phone,
  });

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return 'U';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  List<Object> get props => [fullName, email, role, phone];
}

class GeneralUserProfileState extends Equatable {
  final GeneralUserProfileStatus status;
  final GeneralUserProfileData? data;
  final bool isLoggingOut;
  final bool logoutSuccess;
  final String message;

  const GeneralUserProfileState({
    required this.status,
    required this.data,
    required this.isLoggingOut,
    required this.logoutSuccess,
    required this.message,
  });

  const GeneralUserProfileState.initial()
    : status = GeneralUserProfileStatus.initial,
      data = null,
      isLoggingOut = false,
      logoutSuccess = false,
      message = '';

  GeneralUserProfileState copyWith({
    GeneralUserProfileStatus? status,
    GeneralUserProfileData? data,
    bool clearData = false,
    bool? isLoggingOut,
    bool? logoutSuccess,
    String? message,
  }) {
    return GeneralUserProfileState(
      status: status ?? this.status,
      data: clearData ? null : (data ?? this.data),
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      logoutSuccess: logoutSuccess ?? this.logoutSuccess,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, data, isLoggingOut, logoutSuccess, message];
}
