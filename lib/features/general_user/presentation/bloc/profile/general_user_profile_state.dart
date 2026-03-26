import 'package:equatable/equatable.dart';

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

abstract class GeneralUserProfileState extends Equatable {
  const GeneralUserProfileState();

  GeneralUserProfileData? get data;

  bool get isLoggingOut;

  bool get logoutSuccess;

  String get message;
}

class GeneralUserProfileInitial extends GeneralUserProfileState {
  const GeneralUserProfileInitial();

  @override
  GeneralUserProfileData? get data => null;

  @override
  bool get isLoggingOut => false;

  @override
  bool get logoutSuccess => false;

  @override
  String get message => '';

  @override
  List<Object?> get props => const [];
}

class GeneralUserProfileLoading extends GeneralUserProfileState {
  const GeneralUserProfileLoading();

  @override
  GeneralUserProfileData? get data => null;

  @override
  bool get isLoggingOut => false;

  @override
  bool get logoutSuccess => false;

  @override
  String get message => '';

  @override
  List<Object?> get props => const [];
}

class GeneralUserProfileLoaded extends GeneralUserProfileState {
  @override
  final GeneralUserProfileData data;
  @override
  final bool isLoggingOut;
  @override
  final bool logoutSuccess;
  @override
  final String message;

  const GeneralUserProfileLoaded({
    required this.data,
    required this.isLoggingOut,
    required this.logoutSuccess,
    required this.message,
  });

  @override
  List<Object?> get props => [data, isLoggingOut, logoutSuccess, message];
}

class GeneralUserProfileError extends GeneralUserProfileState {
  @override
  GeneralUserProfileData? get data => null;

  @override
  final bool isLoggingOut;

  @override
  final bool logoutSuccess;

  @override
  final String message;

  const GeneralUserProfileError({
    required this.message,
    this.isLoggingOut = false,
    this.logoutSuccess = false,
  });

  @override
  List<Object?> get props => [message, isLoggingOut, logoutSuccess];
}
