import 'package:equatable/equatable.dart';

class UserReportSearchByLatLonResponse extends Equatable {
  const UserReportSearchByLatLonResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    required this.latitude,
    required this.longitude,
  });

  final int statusCode;
  final String message;
  final bool isSuccess;
  final String latitude;
  final String longitude;

  bool get hasCoordinates =>
      latitude.trim().isNotEmpty && longitude.trim().isNotEmpty;

  factory UserReportSearchByLatLonResponse.fromJson(Map<String, dynamic> json) {
    final coords = _extractCoordinates(json['result']);
    final latitude = coords.$1;
    final longitude = coords.$2;
    final apiSuccess = json['isSuccess'] == true;

    return UserReportSearchByLatLonResponse(
      statusCode: _toInt(json['statusCode']),
      message: (json['message'] ?? '').toString(),
      isSuccess: apiSuccess || (latitude.isNotEmpty && longitude.isNotEmpty),
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  List<Object> get props => [
        statusCode,
        message,
        isSuccess,
        latitude,
        longitude,
      ];
}

const _latitudeKeys = [
  'latitude',
  'Latitude',
  'startLatitude',
  'StartLatitude',
  'lat',
  'Lat',
  'latValue',
  'LatValue',
];

const _longitudeKeys = [
  'longitude',
  'Longitude',
  'startLongitude',
  'StartLongitude',
  'lng',
  'Lng',
  'lon',
  'Lon',
  'long',
  'Long',
];

(String, String) _extractCoordinates(dynamic node, [int depth = 0]) {
  if (depth > 8 || node == null) {
    return ('', '');
  }

  if (node is String) {
    return _extractCoordinatesFromString(node);
  }

  if (node is List) {
    if (node.isEmpty) {
      return ('', '');
    }

    if (node.length >= 2) {
      final first = _coordinateToString(node[0]);
      final second = _coordinateToString(node[1]);
      if (first.isNotEmpty && second.isNotEmpty) {
        return (first, second);
      }
    }

    for (final item in node) {
      final found = _extractCoordinates(item, depth + 1);
      if (found.$1.isNotEmpty && found.$2.isNotEmpty) {
        return found;
      }
    }
    return ('', '');
  }

  if (node is Map) {
    final map = node.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    var latitude = _readCoordinate(map, _latitudeKeys);
    var longitude = _readCoordinate(map, _longitudeKeys);

    if (latitude.isNotEmpty && longitude.isNotEmpty) {
      return (latitude, longitude);
    }

    for (final value in map.values) {
      final found = _extractCoordinates(value, depth + 1);
      if (found.$1.isNotEmpty && found.$2.isNotEmpty) {
        return found;
      }
      if (latitude.isEmpty && found.$1.isNotEmpty) {
        latitude = found.$1;
      }
      if (longitude.isEmpty && found.$2.isNotEmpty) {
        longitude = found.$2;
      }
    }

    if (latitude.isNotEmpty && longitude.isNotEmpty) {
      return (latitude, longitude);
    }
  }

  return ('', '');
}

(String, String) _extractCoordinatesFromString(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty || _isNoDataText(trimmed)) {
    return ('', '');
  }

  final parts = trimmed
      .split(RegExp(r'[,;|\s]+'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList(growable: false);

  if (parts.length >= 2) {
    return (parts[0], parts[1]);
  }

  return ('', '');
}

bool _isNoDataText(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized == 'no data' ||
      normalized == 'nodata' ||
      normalized.contains('no data found');
}

String _readCoordinate(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    final text = _coordinateToString(value);
    if (text.isNotEmpty) {
      return text;
    }
  }

  for (final entry in json.entries) {
    final key = entry.key.toLowerCase();
    if (_latitudeKeys.any((k) => k.toLowerCase() == key) ||
        key.contains('latitude') ||
        key == 'lat') {
      final text = _coordinateToString(entry.value);
      if (text.isNotEmpty) {
        return text;
      }
    }
    if (_longitudeKeys.any((k) => k.toLowerCase() == key) ||
        key.contains('longitude') ||
        key == 'lng' ||
        key == 'lon') {
      final text = _coordinateToString(entry.value);
      if (text.isNotEmpty) {
        return text;
      }
    }
  }

  return '';
}

String _coordinateToString(dynamic value) {
  if (value == null) {
    return '';
  }
  if (value is num) {
    return _formatCoordinateNumber(value);
  }
  final text = value.toString().trim();
  if (text.isEmpty ||
      text.toLowerCase() == 'null' ||
      _isNoDataText(text)) {
    return '';
  }
  return text;
}

String _formatCoordinateNumber(num value) {
  final asDouble = value.toDouble();
  if (asDouble == asDouble.roundToDouble()) {
    return asDouble.toStringAsFixed(0);
  }
  return asDouble.toString();
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
