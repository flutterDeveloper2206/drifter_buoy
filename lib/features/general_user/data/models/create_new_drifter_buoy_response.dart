import 'package:equatable/equatable.dart';

class CreateNewDrifterBuoyResponse extends Equatable {
  const CreateNewDrifterBuoyResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
  });

  final int statusCode;
  final String message;
  final bool isSuccess;

  factory CreateNewDrifterBuoyResponse.fromJson(Map<String, dynamic> json) {
    return CreateNewDrifterBuoyResponse(
      statusCode: _toInt(json['statusCode']),
      message: (json['message'] ?? '').toString(),
      isSuccess: json['isSuccess'] == true,
    );
  }

  @override
  List<Object> get props => [statusCode, message, isSuccess];
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
