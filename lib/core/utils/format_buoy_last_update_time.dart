/// Parses backend last-update strings such as `23-03-2026 02:03:01 PM` and
/// formats the clock time as `2:03 PM` / `10:14 AM`. Returns [raw] if unknown.
String formatBuoyLastUpdateTime(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return '—';
  }
  final parsed = _parseDdMmYyyyHmsAmPm(trimmed);
  if (parsed == null) {
    return trimmed;
  }
  return _formatH12MmAmPm(parsed);
}

DateTime? _parseDdMmYyyyHmsAmPm(String s) {
  final re = RegExp(
    r'^(\d{2})-(\d{2})-(\d{4})\s+(\d{1,2}):(\d{2}):(\d{2})\s+(AM|PM)$',
    caseSensitive: false,
  );
  final m = re.firstMatch(s);
  if (m == null) {
    return null;
  }
  final day = int.tryParse(m.group(1)!);
  final month = int.tryParse(m.group(2)!);
  final year = int.tryParse(m.group(3)!);
  var hour = int.tryParse(m.group(4)!);
  final minute = int.tryParse(m.group(5)!);
  final ampm = m.group(7)!.toUpperCase();
  if (day == null || month == null || year == null || hour == null || minute == null) {
    return null;
  }
  if (ampm == 'PM' && hour != 12) {
    hour += 12;
  }
  if (ampm == 'AM' && hour == 12) {
    hour = 0;
  }
  return DateTime(year, month, day, hour, minute);
}

String _formatH12MmAmPm(DateTime dt) {
  final hour = dt.hour;
  final minute = dt.minute;
  final isPm = hour >= 12;
  final h12 = hour % 12 == 0 ? 12 : hour % 12;
  final period = isPm ? 'PM' : 'AM';
  final mm = minute.toString().padLeft(2, '0');
  return '$h12:$mm $period';
}
