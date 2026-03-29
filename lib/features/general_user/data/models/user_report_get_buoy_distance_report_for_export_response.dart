import 'package:equatable/equatable.dart';

class UserReportGetBuoyDistanceReportForExportResponse extends Equatable {
  final int statusCode;
  final String message;
  final List<Map<String, String>> rows;
  final bool isSuccess;

  const UserReportGetBuoyDistanceReportForExportResponse({
    required this.statusCode,
    required this.message,
    required this.rows,
    required this.isSuccess,
  });

  factory UserReportGetBuoyDistanceReportForExportResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final raw = json['result'];
    final list = raw is List ? raw : const <dynamic>[];
    final rows = list.map((e) {
      if (e is Map) {
        return e.map(
          (key, value) => MapEntry(key.toString(), _cellToString(value)),
        );
      }
      return <String, String>{};
    }).toList(growable: false);

    return UserReportGetBuoyDistanceReportForExportResponse(
      statusCode: _toInt(json['statusCode']),
      message: (json['message'] ?? '').toString(),
      rows: rows,
      isSuccess: json['isSuccess'] == true,
    );
  }

  @override
  List<Object> get props => [statusCode, message, rows, isSuccess];
}

String _cellToString(Object? value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
