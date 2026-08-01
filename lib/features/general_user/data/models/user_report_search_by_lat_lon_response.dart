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

final _coordinateNumberPattern = RegExp(
  r'^[+\-]?\d+(?:\.\d+)?$',
);

final _latitudeInTextPattern = RegExp(
  r'latitude\s*[:=]\s*([+\-]?\d+(?:\.\d+)?)',
  caseSensitive: false,
);

final _longitudeInTextPattern = RegExp(
  r'longitude\s*[:=]\s*([+\-]?\d+(?:\.\d+)?)',
  caseSensitive: false,
);

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
      if (_isCoordinateValue(first) && _isCoordinateValue(second)) {
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

  final latMatch = _latitudeInTextPattern.firstMatch(trimmed);
  final lonMatch = _longitudeInTextPattern.firstMatch(trimmed);
  if (latMatch != null && lonMatch != null) {
    return (
      _normalizeCoordinateText(latMatch.group(1) ?? ''),
      _normalizeCoordinateText(lonMatch.group(1) ?? ''),
    );
  }

  final parts = trimmed
      .split(RegExp(r'[,;|\s]+'))
      .map((part) => part.trim())
      .where(_isCoordinateValue)
      .map(_normalizeCoordinateText)
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
    final key = entry.key.toLowerCase().trim();
    final isExactLatitude =
        _latitudeKeys.any((k) => k.toLowerCase() == key) ||
        key == 'lat';
    final isExactLongitude =
        _longitudeKeys.any((k) => k.toLowerCase() == key) ||
        key == 'lng' ||
        key == 'lon';

    if (isExactLatitude) {
      final text = _coordinateToString(entry.value);
      if (text.isNotEmpty) {
        return text;
      }
    }
    if (isExactLongitude) {
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
  // Never treat nested maps/lists as coordinate text (avoids Map.toString()
  // like `{buoyId: BUOY0001, latitude: +23.060812, ...}` in the UI).
  if (value is Map || value is List) {
    return '';
  }
  if (value is num) {
    return _formatCoordinateNumber(value);
  }
  final text = value.toString().trim();
  if (text.isEmpty ||
      text.toLowerCase() == 'null' ||
      _isNoDataText(text) ||
      !_isCoordinateValue(text)) {
    return '';
  }
  return _normalizeCoordinateText(text);
}

bool _isCoordinateValue(String value) {
  return _coordinateNumberPattern.hasMatch(value.trim());
}

String _normalizeCoordinateText(String value) {
  final trimmed = value.trim();
  if (trimmed.startsWith('+')) {
    return trimmed.substring(1);
  }
  return trimmed;
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
