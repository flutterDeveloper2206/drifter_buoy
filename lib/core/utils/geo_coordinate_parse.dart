/// Parses latitude/longitude from decimal numbers or DMS strings such as
/// `88°51'50.4 N` for use with map [LatLng].
double parseGeoCoordinateToDouble(dynamic value) {
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
