import 'package:drifter_buoy/core/utils/format_buoy_last_update_time.dart';
import 'package:drifter_buoy/core/utils/geo_coordinate_parse.dart';
import 'package:equatable/equatable.dart';

class UserMapDashboardGetBuoyMapDashboardItem extends Equatable {
  final String id;
  final String buoyId;
  final double latitude;
  final double longitude;
  final String buoyStatus;

  /// Raw API strings when coordinates are DMS (e.g. `15°40'51.0"N`).
  final String latitudeText;
  final String longitudeText;

  /// Shown in the map bottom card GPS row.
  final String gpsDisplay;

  final String lastUpdate;
  final double batteryVoltage;

  /// When true, [batteryVoltage] holds 0–100 and should be shown as `%`.
  final bool batteryLevelIsPercent;

  final String signalStrength;
  final String isBatteryLow;

  const UserMapDashboardGetBuoyMapDashboardItem({
    required this.id,
    required this.buoyId,
    required this.latitude,
    required this.longitude,
    required this.buoyStatus,
    required this.latitudeText,
    required this.longitudeText,
    required this.gpsDisplay,
    required this.lastUpdate,
    required this.batteryVoltage,
    required this.batteryLevelIsPercent,
    required this.signalStrength,
    required this.isBatteryLow,
  });

  factory UserMapDashboardGetBuoyMapDashboardItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final latRaw = _readAny(json, const ['latitude', 'Latitude']);
    final lngRaw = _readAny(json, const ['longitude', 'Longitude']);

    final lat = parseGeoCoordinateToDouble(latRaw);
    final lng = parseGeoCoordinateToDouble(lngRaw);

    final latStr = latRaw is String ? latRaw.trim() : '';
    final lngStr = lngRaw is String ? lngRaw.trim() : '';

    final gpsDisplay = _buildGpsDisplay(
      latitudeText: latStr,
      longitudeText: lngStr,
      latitude: lat,
      longitude: lng,
    );

    final rawVoltage = _readAny(json, const [
      'batteryVoltage',
      'BatteryVoltage',
    ]);
    final rawLevel = _readAny(json, const [
      'batteryLevel',
      'BatteryLevel',
      'battery_level',
    ]);

    var voltage = -1.0;
    var levelIsPercent = false;

    double parseLevel(dynamic raw) {
      final levelStr = raw.toString().trim();
      if (levelStr.endsWith('%')) {
        levelIsPercent = true;
        return _toDouble(levelStr.replaceAll('%', '').trim());
      }
      levelIsPercent = false;
      return _toDouble(raw);
    }

    if (rawVoltage != null) {
      voltage = _toDouble(rawVoltage);
      if (voltage < 0 && rawLevel != null) {
        voltage = parseLevel(rawLevel);
      }
    } else if (rawLevel != null) {
      voltage = parseLevel(rawLevel);
    }

    final signal =
        (_readAny(json, const ['signalStrength', 'SignalStrength']) ?? '')
            .toString()
            .trim();

    final lastRaw =
        (_readAny(json, const [
                  'datetime',
                  'Datetime',
                  'dateTime',
                  'DateTime',
                  'lastUpdateTime',
                  'lastUpdateTime',
                  'last_update',
                  'datetimeIST',
                  'DatetimeIST',
                  'datetimeGMT',
                  'DatetimeGMT',
                ]) ??
                '')
            .toString()
            .trim();
    final last = lastRaw.isEmpty ? '' : formatBuoyLastUpdateTime(lastRaw);

    final low = (_readAny(json, const ['isBatteryLow', 'IsBatteryLow']) ?? '')
        .toString()
        .trim();

    return UserMapDashboardGetBuoyMapDashboardItem(
      id: (_readAny(json, const ['_id', 'id', 'Id']) ?? '').toString(),
      buoyId: (_readAny(json, const ['buoyId', 'BuoyId']) ?? '').toString(),
      latitude: lat,
      longitude: lng,
      buoyStatus: (_readAny(json, const ['buoyStatus', 'BuoyStatus']) ?? '')
          .toString(),
      latitudeText: latStr,
      longitudeText: lngStr,
      gpsDisplay: gpsDisplay,
      lastUpdate: last,
      batteryVoltage: voltage,
      batteryLevelIsPercent: levelIsPercent,
      signalStrength: signal,
      isBatteryLow: low,
    );
  }

  String get batteryDisplay {
    if (batteryVoltage < 0) return '—';
    if (batteryLevelIsPercent) {
      return '${batteryVoltage.toStringAsFixed(0)}%';
    }
    return '${batteryVoltage.toStringAsFixed(1)} v';
  }

  String get signalDisplay {
    if (signalStrength.isEmpty) return '—';
    final n = double.tryParse(signalStrength.replaceAll('%', '').trim());
    if (n != null) return '${n.toStringAsFixed(0)}%';
    return signalStrength.contains('%') ? signalStrength : '$signalStrength%';
  }

  @override
  List<Object?> get props => [
    id,
    buoyId,
    latitude,
    longitude,
    buoyStatus,
    latitudeText,
    longitudeText,
    gpsDisplay,
    lastUpdate,
    batteryVoltage,
    batteryLevelIsPercent,
    signalStrength,
    isBatteryLow,
  ];
}

String _buildGpsDisplay({
  required String latitudeText,
  required String longitudeText,
  required double latitude,
  required double longitude,
}) {
  if (latitudeText.isNotEmpty || longitudeText.isNotEmpty) {
    return [latitudeText, longitudeText].where((e) => e.isNotEmpty).join(', ');
  }
  if (latitude == 0 && longitude == 0) return '—';
  return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
}

double _toDouble(dynamic value) {
  if (value == null) return -1;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? -1;
}

dynamic _readAny(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key)) {
      return json[key];
    }
  }
  return null;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

class UserMapDashboardGetBuoyMapDashboardResponse extends Equatable {
  final int statusCode;
  final String message;
  final List<UserMapDashboardGetBuoyMapDashboardItem> result;
  final bool isSuccess;

  const UserMapDashboardGetBuoyMapDashboardResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  factory UserMapDashboardGetBuoyMapDashboardResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserMapDashboardGetBuoyMapDashboardResponse(
      statusCode: _toInt(json['statusCode']),
      message: (json['message'] ?? '').toString(),
      isSuccess: (json['isSuccess'] ?? false) as bool,
      result: (json['result'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(UserMapDashboardGetBuoyMapDashboardItem.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [statusCode, message, result, isSuccess];
}
