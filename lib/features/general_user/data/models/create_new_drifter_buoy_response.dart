import 'package:equatable/equatable.dart';

class CreateNewDrifterBuoyResponse extends Equatable {
  final int statusCode;
  final String message;
  final dynamic result;
  final bool isSuccess;

  const CreateNewDrifterBuoyResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  factory CreateNewDrifterBuoyResponse.fromJson(Map<String, dynamic> json) {
    return CreateNewDrifterBuoyResponse(
      statusCode: (json['statusCode'] ?? 0) as int,
      message: (json['message'] ?? '').toString(),
      result: json['result'],
      isSuccess: (json['isSuccess'] ?? false) as bool,
    );
  }

  @override
  List<Object?> get props => [statusCode, message, result, isSuccess];
}
