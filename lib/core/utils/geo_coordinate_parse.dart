import 'package:drifter_buoy/core/utils/google_maps_camera_utils.dart';

/// Parses latitude/longitude from decimal numbers or DMS strings such as
/// `88°51'50.4"N`, `N 88°51'50.4"`, or `21.1458 N`.
double parseGeoCoordinateToDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();

  final raw = value.toString().trim();
  if (raw.isEmpty || _isMissingCoordinateText(raw)) return 0;

  final normalized = raw
      .replaceAll('º', '°')
      .replaceAll('’', "'")
      .replaceAll('′', "'")
      .replaceAll('″', '"')
      .replaceAll('“', '"')
      .replaceAll('”', '"')
      .replaceAll(',', '.');

  if (!normalized.contains('°') &&
      !RegExp(r'[NSEW]', caseSensitive: false).hasMatch(normalized)) {
    final decimal = double.tryParse(normalized);
    if (decimal != null) {
      return decimal;
    }
  }

  final dms = _parseDmsCoordinate(normalized);
  if (dms != null) {
    return dms;
  }

  final decimalHemisphere = _parseDecimalWithHemisphere(normalized);
  if (decimalHemisphere != null) {
    return decimalHemisphere;
  }

  final fallback = double.tryParse(normalized.replaceAll(RegExp(r'[^0-9.\-]'), ''));
  return fallback ?? 0;
}

/// Reads latitude/longitude from common API keys and DMS/text fallbacks.
(double latitude, double longitude) resolveLatitudeLongitudeFromJson(
  Map<String, dynamic> json,
) {
  const latKeys = [
    'latitude',
    'Latitude',
    'lat',
    'Lat',
    'latitudeDMS',
    'LatitudeDMS',
    'latitude_dms',
    'gpsLatitude',
    'GpsLatitude',
    'startLatitude',
    'StartLatitude',
  ];
  const lngKeys = [
    'longitude',
    'Longitude',
    'lng',
    'Lng',
    'lon',
    'Lon',
    'long',
    'Long',
    'longitudeDMS',
    'LongitudeDMS',
    'longitude_dms',
    'gpsLongitude',
    'GpsLongitude',
    'startLongitude',
    'StartLongitude',
  ];

  final lat = _readFirstParsedCoordinate(json, latKeys);
  final lng = _readFirstParsedCoordinate(json, lngKeys);

  if (isValidMapCoordinate(lat, lng)) {
    return (lat, lng);
  }

  final combined = _readAny(json, const ['gps', 'GPS', 'gpsDisplay', 'GpsDisplay']);
  if (combined != null) {
    final parts = combined
        .toString()
        .split(RegExp(r'[,;|]'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.length >= 2) {
      final parsedLat = parseGeoCoordinateToDouble(parts[0]);
      final parsedLng = parseGeoCoordinateToDouble(parts[1]);
      if (isValidMapCoordinate(parsedLat, parsedLng)) {
        return (parsedLat, parsedLng);
      }
    }
  }

  return (lat, lng);
}

double? _parseDmsCoordinate(String normalized) {
  final suffix = RegExp(
    r"^\s*(\d+(?:\.\d+)?)\s*°\s*(\d+(?:\.\d+)?)?\s*'?\s*(\d+(?:\.\d+)?)?\s*[\u0022\u2033]?\s*([NSEW])\s*$",
    caseSensitive: false,
  ).firstMatch(normalized);
  if (suffix != null) {
    return _dmsToDecimal(suffix);
  }

  final prefix = RegExp(
    r"^\s*([NSEW])\s*(\d+(?:\.\d+)?)\s*°\s*(\d+(?:\.\d+)?)?\s*'?\s*(\d+(?:\.\d+)?)?\s*[\u0022\u2033]?\s*$",
    caseSensitive: false,
  ).firstMatch(normalized);
  if (prefix != null) {
    final hemi = prefix.group(1)!;
    final deg = double.tryParse(prefix.group(2) ?? '') ?? 0;
    final min = double.tryParse(prefix.group(3) ?? '') ?? 0;
    final sec = double.tryParse(prefix.group(4) ?? '') ?? 0;
    return _applyHemisphere(deg + (min / 60) + (sec / 3600), hemi);
  }

  return null;
}

double? _parseDecimalWithHemisphere(String normalized) {
  final match = RegExp(
    r'^\s*([+-]?\d+(?:\.\d+)?)\s*([NSEW])\s*$',
    caseSensitive: false,
  ).firstMatch(normalized);
  if (match == null) {
    return null;
  }
  final value = double.tryParse(match.group(1) ?? '');
  final hemi = match.group(2) ?? '';
  if (value == null) {
    return null;
  }
  return _applyHemisphere(value.abs(), hemi);
}

double _dmsToDecimal(RegExpMatch match) {
  final deg = double.tryParse(match.group(1) ?? '') ?? 0;
  final min = double.tryParse(match.group(2) ?? '') ?? 0;
  final sec = double.tryParse(match.group(3) ?? '') ?? 0;
  final hemi = match.group(4) ?? '';
  return _applyHemisphere(deg + (min / 60) + (sec / 3600), hemi);
}

double _applyHemisphere(double value, String hemisphere) {
  final hemi = hemisphere.toUpperCase();
  if (hemi == 'S' || hemi == 'W') {
    return -value.abs();
  }
  return value.abs();
}

bool _isMissingCoordinateText(String raw) {
  final normalized = raw.trim().toLowerCase();
  return normalized == '—' ||
      normalized == '-' ||
      normalized == 'null' ||
      normalized == 'n/a' ||
      normalized == 'na' ||
      normalized.contains('no data');
}

double _readFirstParsedCoordinate(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    if (!json.containsKey(key)) {
      continue;
    }
    final parsed = parseGeoCoordinateToDouble(json[key]);
    final raw = json[key]?.toString().trim() ?? '';
    if (raw.isEmpty || _isMissingCoordinateText(raw)) {
      continue;
    }
    if (parsed != 0 || raw == '0' || raw == '0.0') {
      return parsed;
    }
  }
  return 0;
}

dynamic _readAny(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key)) {
      return json[key];
    }
  }
  return null;
}
