import 'package:equatable/equatable.dart';

/// Response from `GetBuoyTrajectoryView` (multipart: buoyId, fromDate, toDate).
class UserViewBuoyDashboardGetBuoyTrajectoryViewResponse extends Equatable {
  const UserViewBuoyDashboardGetBuoyTrajectoryViewResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  final int statusCode;
  final String message;
  final List<BuoyTrajectoryViewRowModel> result;
  final bool isSuccess;

  factory UserViewBuoyDashboardGetBuoyTrajectoryViewResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final raw = json['result'];
    final list = <BuoyTrajectoryViewRowModel>[];
    if (raw is List) {
      for (final element in raw) {
        if (element is Map) {
          list.add(
            BuoyTrajectoryViewRowModel.fromJson(
              Map<String, dynamic>.from(element),
            ),
          );
        }
      }
    }

    return UserViewBuoyDashboardGetBuoyTrajectoryViewResponse(
      statusCode: _toInt(json['statusCode']),
      message: (json['message'] ?? '').toString(),
      result: list,
      isSuccess: json['isSuccess'] == true,
    );
  }

  @override
  List<Object> get props => [statusCode, message, result, isSuccess];
}

class BuoyTrajectoryViewRowModel extends Equatable {
  const BuoyTrajectoryViewRowModel({
    required this.buoyId,
    required this.datetime,
    required this.latitude,
    required this.longitude,
    required this.batteryVoltage,
    required this.isBatteryLow,
  });

  final String buoyId;
  final String datetime;
  final double latitude;
  final double longitude;
  final double batteryVoltage;
  final String isBatteryLow;

  factory BuoyTrajectoryViewRowModel.fromJson(Map<String, dynamic> json) {
    final dateIst = (_readAny(json, const ['datetimeIST', 'DatetimeIST']) ?? '')
        .toString()
        .trim();
    final dateGmt = (_readAny(json, const ['datetimeGMT', 'DatetimeGMT']) ?? '')
        .toString()
        .trim();
    final fallbackDate =
        (_readAny(json, const ['datetime', 'dateTime', 'Datetime']) ?? '')
            .toString()
            .trim();
    return BuoyTrajectoryViewRowModel(
      buoyId: (_readAny(json, const ['buoyId', 'BuoyId']) ?? '').toString(),
      datetime: dateIst.isNotEmpty
          ? dateIst
          : (dateGmt.isNotEmpty ? dateGmt : fallbackDate),
      latitude: _toCoordinate(_readAny(json, const ['latitude', 'Latitude'])),
      longitude: _toCoordinate(_readAny(json, const ['longitude', 'Longitude'])),
      batteryVoltage: _toDouble(
        _readAny(json, const ['batteryVoltage', 'BatteryVoltage']),
      ),
      isBatteryLow: (_readAny(json, const ['isBatteryLow', 'IsBatteryLow']) ?? '')
          .toString(),
    );
  }

  @override
  List<Object> get props => [
    buoyId,
    datetime,
    latitude,
    longitude,
    batteryVoltage,
    isBatteryLow,
  ];
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

double _toCoordinate(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();

  final raw = value.toString().trim();
  if (raw.isEmpty) return 0;

  final decimal = double.tryParse(raw);
  if (decimal != null) return decimal;

  final normalized = raw
      .replaceAll('º', '°')
      .replaceAll('’', "'")
      .replaceAll('′', "'")
      .replaceAll('″', '"')
      .replaceAll(',', '.');
  final match = RegExp(
    '^\\s*(\\d+(?:\\.\\d+)?)\\s*°\\s*(\\d+(?:\\.\\d+)?)?\\s*\'?\\s*(\\d+(?:\\.\\d+)?)?\\s*"?\\s*([NSEW])\\s*\$',
    caseSensitive: false,
  ).firstMatch(normalized);
  if (match == null) {
    return 0;
  }

  final deg = double.tryParse(match.group(1) ?? '') ?? 0;
  final min = double.tryParse(match.group(2) ?? '') ?? 0;
  final sec = double.tryParse(match.group(3) ?? '') ?? 0;
  final hemi = (match.group(4) ?? '').toUpperCase();

  var out = deg + (min / 60) + (sec / 3600);
  if (hemi == 'S' || hemi == 'W') {
    out = -out;
  }
  return out;
}

dynamic _readAny(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key)) {
      return json[key];
    }
  }
  return null;
}
