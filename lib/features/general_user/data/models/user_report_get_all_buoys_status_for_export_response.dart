import 'package:equatable/equatable.dart';

class UserReportGetAllBuoysStatusForExportResponse extends Equatable {
  final int statusCode;
  final String message;
  final List<BuoyExportStatusItemModel> result;
  final bool isSuccess;

  const UserReportGetAllBuoysStatusForExportResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  factory UserReportGetAllBuoysStatusForExportResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawResult = json['result'];
    final parsedResult = rawResult is List
        ? rawResult
              .whereType<Map<String, dynamic>>()
              .map(BuoyExportStatusItemModel.fromJson)
              .toList(growable: false)
        : const <BuoyExportStatusItemModel>[];

    return UserReportGetAllBuoysStatusForExportResponse(
      statusCode: _toInt(json['statusCode']),
      message: (json['message'] ?? '').toString(),
      result: parsedResult,
      isSuccess: json['isSuccess'] == true,
    );
  }

  @override
  List<Object> get props => [statusCode, message, result, isSuccess];
}

class BuoyExportStatusItemModel extends Equatable {
  final String buoyId;
  final String status;
  final String lastUpdated;

  const BuoyExportStatusItemModel({
    required this.buoyId,
    required this.status,
    required this.lastUpdated,
  });

  factory BuoyExportStatusItemModel.fromJson(Map<String, dynamic> json) {
    return BuoyExportStatusItemModel(
      buoyId: (json['buoyId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      lastUpdated: (json['lastUpdated'] ?? '').toString(),
    );
  }

  bool get isActive => status.trim().toLowerCase() == 'active';

  @override
  List<Object> get props => [buoyId, status, lastUpdated];
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
