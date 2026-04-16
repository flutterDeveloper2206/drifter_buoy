import 'package:equatable/equatable.dart';

class DeviceTokenRegisterResponse extends Equatable {
  final int statusCode;
  final String message;
  final String result;
  final bool isSuccess;

  const DeviceTokenRegisterResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  factory DeviceTokenRegisterResponse.fromJson(Map<String, dynamic> json) {
    return DeviceTokenRegisterResponse(
      statusCode: (json['statusCode'] ?? 0) as int,
      message: (json['message'] ?? '').toString(),
      result: (json['result'] ?? '').toString(),
      isSuccess: (json['isSuccess'] ?? false) as bool,
    );
  }

  @override
  List<Object?> get props => [statusCode, message, result, isSuccess];
}
