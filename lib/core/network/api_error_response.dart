import 'dart:convert';

class ApiErrorResponse {
  final int statusCode;
  final String message;
  final dynamic result;
  final bool isSuccess;

  const ApiErrorResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  /// Parses backend error payload in a "best effort" way.
  /// Backend examples:
  /// - { "statusCode":401, "message":"Incorrect...", "result":null, "isSuccess":false }
  /// - { "statusCode":500, "message":"Unexpected Error", "result":"Invalid or expired..." }
  factory ApiErrorResponse.fromJson(dynamic json) {
    if (json is String) {
      final trimmed = json.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          final decoded = jsonDecode(trimmed);
          return ApiErrorResponse.fromJson(decoded);
        } catch (_) {
          // fall through to default
        }
      }
    }

    if (json is! Map) {
      return const ApiErrorResponse(
        statusCode: 0,
        message: 'Request failed. Please try again.',
        result: null,
        isSuccess: false,
      );
    }

    final map = json.map((key, value) => MapEntry(key.toString(), value));

    final statusCode = (map['statusCode'] ?? 0);
    final message = (map['message'] ?? '').toString();
    final result = map['result'];
    final isSuccess = (map['isSuccess'] ?? false) as bool? ?? false;

    return ApiErrorResponse(
      statusCode: statusCode is int ? statusCode : int.tryParse(statusCode.toString()) ?? 0,
      message: message,
      result: result,
      isSuccess: isSuccess,
    );
  }
}

