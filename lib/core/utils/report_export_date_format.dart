const _months = <String>[
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

/// Formats [d] as `02-Mar-2026` for report export APIs.
String formatReportApiDate(DateTime d) {
  final local = DateTime(d.year, d.month, d.day);
  final dd = local.day.toString().padLeft(2, '0');
  final mon = _months[local.month - 1];
  return '$dd-$mon-${local.year}';
}

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime todayLocal() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}
