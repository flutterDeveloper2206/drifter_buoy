import 'package:equatable/equatable.dart';

class UserAuthenticateResetPasswordResponse extends Equatable {
  final int statusCode;
  final String message;
  final String result;
  final bool isSuccess;

  const UserAuthenticateResetPasswordResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  factory UserAuthenticateResetPasswordResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserAuthenticateResetPasswordResponse(
      statusCode: (json['statusCode'] ?? 0) as int,
      message: (json['message'] ?? '').toString(),
      result: (json['result'] ?? '').toString(),
      isSuccess: (json['isSuccess'] ?? false) as bool,
    );
  }

  @override
  List<Object?> get props => [statusCode, message, result, isSuccess];
}

