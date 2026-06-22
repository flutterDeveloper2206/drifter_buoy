/// Validation helpers for the buoy setup form (Save Set Up).
String? validateBuoySetupStationId(String value) {
  final trimmed = value.trim().toUpperCase();
  if (trimmed.isEmpty) {
    return 'Station ID is required.';
  }
  if (trimmed.length != 8) {
    return 'Station ID must be exactly 8 characters.';
  }
  if (!RegExp(r'^[A-Z0-9]+$').hasMatch(trimmed)) {
    return 'Station ID may only contain letters and numbers.';
  }
  return null;
}

String? validateBuoySetupStationName(String value) {
  if (value.trim().isEmpty) {
    return 'Station name is required.';
  }
  return null;
}

String? validateBuoySetupHhMmSs(String value, String fieldLabel) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '$fieldLabel is required.';
  }
  final match = RegExp(r'^(\d{2}):(\d{2}):(\d{2})$').firstMatch(trimmed);
  if (match == null) {
    return '$fieldLabel must use HH:MM:SS format.';
  }
  final hour = int.tryParse(match.group(1) ?? '');
  final minute = int.tryParse(match.group(2) ?? '');
  final second = int.tryParse(match.group(3) ?? '');
  if (hour == null ||
      minute == null ||
      second == null ||
      hour > 23 ||
      minute > 59 ||
      second > 59) {
    return '$fieldLabel is not a valid time.';
  }
  return null;
}

String? validateBuoySetupForm({
  required String stationId,
  required String stationName,
  required String transmissionInterval,
  required String transmissionStartTime,
}) {
  return validateBuoySetupStationId(stationId) ??
      validateBuoySetupStationName(stationName) ??
      validateBuoySetupHhMmSs(
        transmissionInterval,
        'Transmission interval',
      ) ??
      validateBuoySetupHhMmSs(
        transmissionStartTime,
        'Transmission start time',
      );
}
