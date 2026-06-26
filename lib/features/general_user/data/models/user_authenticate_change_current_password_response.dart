import 'package:equatable/equatable.dart';

class UserAuthenticateChangeCurrentPasswordResponse extends Equatable {
  const UserAuthenticateChangeCurrentPasswordResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  final int statusCode;
  final String message;
  final String result;
  final bool isSuccess;

  factory UserAuthenticateChangeCurrentPasswordResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserAuthenticateChangeCurrentPasswordResponse(
      statusCode: (json['statusCode'] ?? 0) as int,
      message: (json['message'] ?? '').toString(),
      result: (json['result'] ?? '').toString(),
      isSuccess: (json['isSuccess'] ?? false) as bool,
    );
  }

  @override
  List<Object?> get props => [statusCode, message, result, isSuccess];
}
