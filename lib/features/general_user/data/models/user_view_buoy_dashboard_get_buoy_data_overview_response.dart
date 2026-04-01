import 'package:equatable/equatable.dart';

/// Response for
/// `POST .../UserViewBuoyDashboard/GetBuoyDataOverview` (multipart `buoyId`).
class UserViewBuoyDashboardGetBuoyDataOverviewResponse extends Equatable {
  final int statusCode;
  final String message;
  final BuoyDataOverviewResult? result;
  final bool isSuccess;

  const UserViewBuoyDashboardGetBuoyDataOverviewResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  factory UserViewBuoyDashboardGetBuoyDataOverviewResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawResult = json['result'];
    BuoyDataOverviewResult? parsed;
    if (rawResult is Map<String, dynamic>) {
      parsed = BuoyDataOverviewResult.fromJson(rawResult);
    }

    return UserViewBuoyDashboardGetBuoyDataOverviewResponse(
      statusCode: _toInt(json['statusCode']),
      message: (json['message'] ?? '').toString(),
      result: parsed,
      isSuccess: json['isSuccess'] == true,
    );
  }

  @override
  List<Object?> get props => [statusCode, message, result, isSuccess];
}

class BuoyDataOverviewResult extends Equatable {
  final List<BuoyDataOverviewBuoyRow> buoyOverview;
  final List<BuoyDataOverviewMetricsRow> metrics;
  final List<BuoyDataOverviewTrajectoryRow> trajectory;

  const BuoyDataOverviewResult({
    required this.buoyOverview,
    required this.metrics,
    required this.trajectory,
  });

  factory BuoyDataOverviewResult.fromJson(Map<String, dynamic> json) {
    return BuoyDataOverviewResult(
      buoyOverview: _mapList(json['buoyOverview'], BuoyDataOverviewBuoyRow.fromJson),
      metrics: _mapList(json['metrics'], BuoyDataOverviewMetricsRow.fromJson),
      trajectory: _mapList(
        json['trajectory'],
        BuoyDataOverviewTrajectoryRow.fromJson,
      ),
    );
  }

  @override
  List<Object> get props => [buoyOverview, metrics, trajectory];
}

class BuoyDataOverviewBuoyRow extends Equatable {
  final String buoyId;
  final String buoyStatus;
  final String lastUpdate;

  const BuoyDataOverviewBuoyRow({
    required this.buoyId,
    required this.buoyStatus,
    required this.lastUpdate,
  });

  factory BuoyDataOverviewBuoyRow.fromJson(Map<String, dynamic> json) {
    return BuoyDataOverviewBuoyRow(
      buoyId: (json['buoyId'] ?? '').toString(),
      buoyStatus: (json['buoyStatus'] ?? '').toString(),
      lastUpdate: (json['lastUpdate'] ?? '').toString(),
    );
  }

  @override
  List<Object> get props => [buoyId, buoyStatus, lastUpdate];
}

class BuoyDataOverviewMetricsRow extends Equatable {
  final double batteryVoltage;
  final double latitude;
  final double longitude;
  final String latitudeDMS;
  final String longitudeDMS;
  final String signalStrength;
  final String isBatteryLow;

  const BuoyDataOverviewMetricsRow({
    required this.batteryVoltage,
    required this.latitude,
    required this.longitude,
    required this.latitudeDMS,
    required this.longitudeDMS,
    required this.signalStrength,
    required this.isBatteryLow,
  });

  factory BuoyDataOverviewMetricsRow.fromJson(Map<String, dynamic> json) {
    return BuoyDataOverviewMetricsRow(
      batteryVoltage: _toDouble(json['batteryVoltage']),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      latitudeDMS: _readString(json, const [
        'latitudeDMS',
        'LatitudeDMS',
        'latitude_dms',
      ]),
      longitudeDMS: _readString(json, const [
        'longitudeDMS',
        'LongitudeDMS',
        'longitude_dms',
      ]),
      signalStrength: (json['signalStrength'] ?? '').toString(),
      isBatteryLow: (json['isBatteryLow'] ?? '').toString(),
    );
  }

  @override
  List<Object> get props => [
        batteryVoltage,
        latitude,
        longitude,
        latitudeDMS,
        longitudeDMS,
        signalStrength,
        isBatteryLow,
      ];
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key) && json[key] != null) {
      return json[key].toString().trim();
    }
  }
  return '';
}

class BuoyDataOverviewTrajectoryRow extends Equatable {
  final double firstLatitude;
  final double firstLongitude;
  final double lastLatitude;
  final double lastLongitude;

  const BuoyDataOverviewTrajectoryRow({
    required this.firstLatitude,
    required this.firstLongitude,
    required this.lastLatitude,
    required this.lastLongitude,
  });

  factory BuoyDataOverviewTrajectoryRow.fromJson(Map<String, dynamic> json) {
    return BuoyDataOverviewTrajectoryRow(
      firstLatitude: _toDouble(json['firstLatitude']),
      firstLongitude: _toDouble(json['firstLongitude']),
      lastLatitude: _toDouble(json['lastLatitude']),
      lastLongitude: _toDouble(json['lastLongitude']),
    );
  }

  @override
  List<Object> get props => [
        firstLatitude,
        firstLongitude,
        lastLatitude,
        lastLongitude,
      ];
}

List<T> _mapList<T>(
  dynamic raw,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList(growable: false);
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

double _toDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
