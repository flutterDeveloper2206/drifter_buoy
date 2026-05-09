import 'package:equatable/equatable.dart';

bool _parseIsActive(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final raw = (value ?? '').toString().trim().toLowerCase();
  if (raw.isEmpty) {
    return true;
  }
  if (raw == 'true' || raw == '1' || raw == 'yes' || raw == 'y') {
    return true;
  }
  if (raw == 'false' || raw == '0' || raw == 'no' || raw == 'n') {
    return false;
  }
  return true;
}

class DrifterBuoyCommandModel extends Equatable {
  const DrifterBuoyCommandModel({
    required this.id,
    required this.testName,
    required this.requestCommand,
    required this.waitingPeriodSecondsRaw,
    required this.requestCommandDescription,
    required this.response,
    required this.responseDescription,
    this.isActive = true,
  });

  final String id;
  final String testName;
  final String requestCommand;
  final String waitingPeriodSecondsRaw;
  final String requestCommandDescription;
  final String response;
  final String responseDescription;
  final bool isActive;

  factory DrifterBuoyCommandModel.fromJson(Map<String, dynamic> json) {
    return DrifterBuoyCommandModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      testName: (json['testName'] ?? '').toString(),
      requestCommand: (json['requestCommand'] ?? '').toString(),
      waitingPeriodSecondsRaw: (json['waitingPeriodSeconds'] ?? 'NA')
          .toString(),
      requestCommandDescription: (json['requestCommandDescription'] ?? '')
          .toString(),
      response: (json['response'] ?? '').toString(),
      responseDescription: (json['responseDescription'] ?? '').toString(),
      isActive: _parseIsActive(json['isActive']),
    );
  }

  /// Backend uses `"NA"` or a numeric string. Default when invalid: 60 seconds.
  Duration get responseWaitTimeout {
    final raw = waitingPeriodSecondsRaw.trim();
    if (raw.toUpperCase() == 'NA' || raw.isEmpty) {
      return const Duration(seconds: 60);
    }
    final seconds = int.tryParse(raw);
    if (seconds == null || seconds <= 0) {
      return const Duration(seconds: 60);
    }
    return Duration(seconds: seconds);
  }

  @override
  List<Object?> get props => [
    id,
    testName,
    requestCommand,
    waitingPeriodSecondsRaw,
    requestCommandDescription,
    response,
    responseDescription,
    isActive,
  ];
}

class GetAllDrifterBuoyCommandsResponse extends Equatable {
  const GetAllDrifterBuoyCommandsResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  final int statusCode;
  final String message;
  final List<DrifterBuoyCommandModel> result;
  final bool isSuccess;

  factory GetAllDrifterBuoyCommandsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawResult = json['result'];
    final list = <DrifterBuoyCommandModel>[];

    if (rawResult is List) {
      for (final item in rawResult) {
        if (item is Map<String, dynamic>) {
          list.add(DrifterBuoyCommandModel.fromJson(item));
        }
      }
    } else if (rawResult is Map<String, dynamic>) {
      final rawCommands = rawResult['commands'];
      if (rawCommands is List) {
        for (final item in rawCommands) {
          if (item is Map<String, dynamic>) {
            list.add(DrifterBuoyCommandModel.fromJson(item));
          }
        }
      }
    }

    return GetAllDrifterBuoyCommandsResponse(
      statusCode: (json['statusCode'] ?? 0) is num
          ? (json['statusCode'] as num).toInt()
          : int.tryParse((json['statusCode'] ?? '0').toString()) ?? 0,
      message: (json['message'] ?? '').toString(),
      result: list,
      isSuccess: (json['isSuccess'] ?? false) as bool? ?? false,
    );
  }
  @override
  List<Object?> get props => [statusCode, message, result, isSuccess];
}
