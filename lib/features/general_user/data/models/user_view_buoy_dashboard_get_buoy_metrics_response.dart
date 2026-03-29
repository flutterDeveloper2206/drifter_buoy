import 'package:equatable/equatable.dart';

/// Response from `GetBuoyMetrics` (multipart: BuoyId, FromDate, ToDate).
class UserViewBuoyDashboardGetBuoyMetricsResponse extends Equatable {
  const UserViewBuoyDashboardGetBuoyMetricsResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  final int statusCode;
  final String message;
  final List<BuoyMetricSampleModel> result;
  final bool isSuccess;

  factory UserViewBuoyDashboardGetBuoyMetricsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final raw = json['result'];
    final list = <BuoyMetricSampleModel>[];
    if (raw is List) {
      for (final element in raw) {
        if (element is Map) {
          list.add(
            BuoyMetricSampleModel.fromJson(
              Map<String, dynamic>.from(element),
            ),
          );
        }
      }
    }

    return UserViewBuoyDashboardGetBuoyMetricsResponse(
      statusCode: _toInt(json['statusCode']),
      message: (json['message'] ?? '').toString(),
      result: list,
      isSuccess: json['isSuccess'] == true,
    );
  }

  @override
  List<Object> get props => [statusCode, message, result, isSuccess];
}

class BuoyMetricSampleModel extends Equatable {
  const BuoyMetricSampleModel({
    required this.buoyId,
    required this.batteryVoltage,
    required this.signalStrength,
    required this.datetime,
    required this.latitude,
    required this.longitude,
  });

  final String buoyId;
  final String batteryVoltage;
  final String signalStrength;
  final String datetime;
  final double latitude;
  final double longitude;

  factory BuoyMetricSampleModel.fromJson(Map<String, dynamic> json) {
    return BuoyMetricSampleModel(
      buoyId: (json['buoyId'] ?? '').toString(),
      batteryVoltage: (json['batteryVoltage'] ?? '').toString(),
      signalStrength: (json['signalStrength'] ?? '').toString(),
      datetime: (json['datetime'] ?? '').toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  @override
  List<Object> get props => [
    buoyId,
    batteryVoltage,
    signalStrength,
    datetime,
    latitude,
    longitude,
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
