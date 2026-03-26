import 'package:equatable/equatable.dart';

class UserAuthenticateVerifyVerificationCodeResult extends Equatable {
  final String resetToken;

  const UserAuthenticateVerifyVerificationCodeResult({
    required this.resetToken,
  });

  factory UserAuthenticateVerifyVerificationCodeResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserAuthenticateVerifyVerificationCodeResult(
      resetToken: (json['resetToken'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [resetToken];
}

class UserAuthenticateVerifyVerificationCodeResponse
    extends Equatable {
  final int statusCode;
  final String message;
  final UserAuthenticateVerifyVerificationCodeResult result;
  final bool isSuccess;

  const UserAuthenticateVerifyVerificationCodeResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  factory UserAuthenticateVerifyVerificationCodeResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final resultJson = (json['result'] as Map<String, dynamic>?) ?? const {};
    return UserAuthenticateVerifyVerificationCodeResponse(
      statusCode: (json['statusCode'] ?? 0) as int,
      message: (json['message'] ?? '').toString(),
      isSuccess: (json['isSuccess'] ?? false) as bool,
      result:
          UserAuthenticateVerifyVerificationCodeResult.fromJson(resultJson),
    );
  }

  @override
  List<Object?> get props => [statusCode, message, result, isSuccess];
}

