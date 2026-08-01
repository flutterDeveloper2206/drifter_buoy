/// Parses trajectory API datetime strings for sorting and display.
///
/// Supports:
/// - `01-Aug-2026 05:40:00`
/// - `23-03-2026 02:03:01 PM`
/// - `05:40 IST`, `19:30 GMT`, `09:37:01 IST`
class TrajectoryDateTimeParts {
  const TrajectoryDateTimeParts({
    this.dateTime,
    this.minutesOfDay,
    this.timezoneSuffix = '',
  });

  final DateTime? dateTime;
  final int? minutesOfDay;
  final String timezoneSuffix;
}

TrajectoryDateTimeParts parseTrajectoryDateTime(String raw) {
  final input = raw.trim();
  if (input.isEmpty) {
    return const TrajectoryDateTimeParts();
  }

  final full = _parseFullDateTime(input);
  if (full != null) {
    return TrajectoryDateTimeParts(dateTime: full.dateTime, timezoneSuffix: full.timezoneSuffix);
  }

  final timeOnly = _parseTimeWithTimezone(input);
  if (timeOnly != null) {
    return timeOnly;
  }

  return const TrajectoryDateTimeParts();
}

int compareTrajectoryDateTimeParts(
  TrajectoryDateTimeParts a,
  TrajectoryDateTimeParts b, {
  required int indexA,
  required int indexB,
}) {
  if (a.dateTime != null && b.dateTime != null) {
    final cmp = a.dateTime!.compareTo(b.dateTime!);
    if (cmp != 0) {
      return cmp;
    }
    return indexA.compareTo(indexB);
  }
  if (a.dateTime != null) {
    return -1;
  }
  if (b.dateTime != null) {
    return 1;
  }
  if (a.minutesOfDay != null && b.minutesOfDay != null) {
    final cmp = a.minutesOfDay!.compareTo(b.minutesOfDay!);
    if (cmp != 0) {
      return cmp;
    }
    return indexA.compareTo(indexB);
  }
  return indexA.compareTo(indexB);
}

String formatTrajectoryTimestampLabel(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return '—';
  }

  final parsed = parseTrajectoryDateTime(trimmed);
  if (parsed.dateTime != null) {
    final dt = parsed.dateTime!;
    final time =
        '${_two(dt.hour)}:${_two(dt.minute)}:${_two(dt.second)}';
    if (parsed.timezoneSuffix.isNotEmpty) {
      return '$time ${parsed.timezoneSuffix}';
    }
    return time;
  }
  if (parsed.minutesOfDay != null) {
    final minutes = parsed.minutesOfDay!;
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final time = '${_two(hour)}:${_two(minute)}:00';
    if (parsed.timezoneSuffix.isNotEmpty) {
      return '$time ${parsed.timezoneSuffix}';
    }
    return time;
  }

  return trimmed;
}

String? formatTrajectorySecondaryDateLabel(String raw) {
  final parsed = parseTrajectoryDateTime(raw.trim());
  final dt = parsed.dateTime;
  if (dt == null) {
    return null;
  }
  return '${_two(dt.day)}-${_monthLabel(dt.month)}-${dt.year}';
}

String pickTrajectorySortDatetime({
  required String fullDatetime,
  required String datetimeIst,
  required String datetimeGmt,
}) {
  for (final candidate in [fullDatetime, datetimeIst, datetimeGmt]) {
    if (candidate.trim().isEmpty) {
      continue;
    }
    final parsed = parseTrajectoryDateTime(candidate);
    if (parsed.dateTime != null || parsed.minutesOfDay != null) {
      return candidate.trim();
    }
  }
  return fullDatetime.isNotEmpty
      ? fullDatetime.trim()
      : (datetimeIst.isNotEmpty
            ? datetimeIst.trim()
            : datetimeGmt.trim());
}

TrajectoryDateTimeParts? _parseFullDateTime(String input) {
  final ddMonYyyy = RegExp(
    r'^(\d{2})-([A-Za-z]{3})-(\d{4})\s+(\d{1,2}):(\d{2}):(\d{2})(?:\s+(IST|GMT|UTC))?$',
    caseSensitive: false,
  ).firstMatch(input);
  if (ddMonYyyy != null) {
    final day = int.tryParse(ddMonYyyy.group(1)!);
    final month = _monthIndex(ddMonYyyy.group(2)!);
    final year = int.tryParse(ddMonYyyy.group(3)!);
    final hour = int.tryParse(ddMonYyyy.group(4)!);
    final minute = int.tryParse(ddMonYyyy.group(5)!);
    final second = int.tryParse(ddMonYyyy.group(6)!);
    if (day != null &&
        month != null &&
        year != null &&
        hour != null &&
        minute != null &&
        second != null) {
      return TrajectoryDateTimeParts(
        dateTime: DateTime(year, month, day, hour, minute, second),
        timezoneSuffix: (ddMonYyyy.group(7) ?? '').trim().toUpperCase(),
      );
    }
  }

  final ddMmYyyyAmPm = RegExp(
    r'^(\d{2})-(\d{2})-(\d{4})\s+(\d{1,2}):(\d{2}):(\d{2})\s+(AM|PM)$',
    caseSensitive: false,
  ).firstMatch(input);
  if (ddMmYyyyAmPm != null) {
    final day = int.tryParse(ddMmYyyyAmPm.group(1)!);
    final month = int.tryParse(ddMmYyyyAmPm.group(2)!);
    final year = int.tryParse(ddMmYyyyAmPm.group(3)!);
    var hour = int.tryParse(ddMmYyyyAmPm.group(4)!);
    final minute = int.tryParse(ddMmYyyyAmPm.group(5)!);
    final second = int.tryParse(ddMmYyyyAmPm.group(6)!);
    final ampm = ddMmYyyyAmPm.group(7)!.toUpperCase();
    if (day != null &&
        month != null &&
        year != null &&
        hour != null &&
        minute != null &&
        second != null) {
      if (ampm == 'PM' && hour != 12) {
        hour += 12;
      }
      if (ampm == 'AM' && hour == 12) {
        hour = 0;
      }
      return TrajectoryDateTimeParts(
        dateTime: DateTime(year, month, day, hour, minute, second),
      );
    }
  }

  return null;
}

TrajectoryDateTimeParts? _parseTimeWithTimezone(String input) {
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})(?::(\d{2}))?\s*(IST|GMT|UTC)?$',
    caseSensitive: false,
  ).firstMatch(input);
  if (match == null) {
    return null;
  }
  final hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2)!);
  if (hour == null || minute == null) {
    return null;
  }
  return TrajectoryDateTimeParts(
    minutesOfDay: hour * 60 + minute,
    timezoneSuffix: (match.group(4) ?? '').trim().toUpperCase(),
  );
}

int? _monthIndex(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'jan':
      return 1;
    case 'feb':
      return 2;
    case 'mar':
      return 3;
    case 'apr':
      return 4;
    case 'may':
      return 5;
    case 'jun':
      return 6;
    case 'jul':
      return 7;
    case 'aug':
      return 8;
    case 'sep':
      return 9;
    case 'oct':
      return 10;
    case 'nov':
      return 11;
    case 'dec':
      return 12;
  }
  return null;
}

String _monthLabel(int month) {
  const labels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  if (month < 1 || month > 12) {
    return '';
  }
  return labels[month - 1];
}

String _two(int value) => value.toString().padLeft(2, '0');
