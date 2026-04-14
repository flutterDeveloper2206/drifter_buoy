import 'package:drifter_buoy/core/utils/report_export_date_format.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_buoy_trajectory_view_response.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_trajectory_live_map_view.dart';
import 'package:latlong2/latlong.dart';

typedef TrajectoryApiDateRange = (String fromDate, String toDate);

TrajectoryApiDateRange defaultTrajectoryApiDateRange() {
  final to = todayLocal();
  final from = to.subtract(const Duration(days: 0));
  return (formatReportApiDate(from), formatReportApiDate(to));
}

List<TrajectoryBuoyPoint> mapTrajectoryRowsToPoints(
  List<BuoyTrajectoryViewRowModel> rows,
) {
  final sorted = List<BuoyTrajectoryViewRowModel>.from(rows)
    ..sort((a, b) {
      final ta = _parseApiDateTime(a.datetime);
      final tb = _parseApiDateTime(b.datetime);
      if (ta == null && tb == null) return 0;
      if (ta == null) return -1;
      if (tb == null) return 1;
      return ta.compareTo(tb);
    });

  return sorted
      .where(
        (row) =>
            row.latitude != 0 ||
            row.longitude != 0,
      )
      .map(
        (row) => TrajectoryBuoyPoint(
          position: LatLng(row.latitude, row.longitude),
          status: _statusForRow(row),
          label: _labelForRow(row),
          secondaryLabel: _secondaryLabelForRow(row),
          gpsLabel:
              '${row.latitude.toStringAsFixed(5)}, ${row.longitude.toStringAsFixed(5)}',
          timestampLabel: _timestampForRow(row),
          batteryLabel: _batteryForRow(row),
        ),
      )
      .toList(growable: false);
}

BuoyStatus _statusForRow(BuoyTrajectoryViewRowModel row) {
  if (row.batteryVoltage < 0) {
    return BuoyStatus.offline;
  }

  final batteryLow = row.isBatteryLow.trim().toLowerCase();
  if (batteryLow == 'yes' || batteryLow == 'true' || batteryLow == '1') {
    return BuoyStatus.batteryLow;
  }

  return BuoyStatus.active;
}

String _labelForRow(BuoyTrajectoryViewRowModel row) {
  // Keep legacy label for compatibility; map rendering uses gps/timestamp labels.
  return _timestampForRow(row);
}

String _timestampForRow(BuoyTrajectoryViewRowModel row) {
  final dt = _parseApiDateTime(row.datetime);
  if (dt == null) {
    return row.datetime.trim();
  }

  return '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}:${_twoDigits(dt.second)}';
}

String? _secondaryLabelForRow(BuoyTrajectoryViewRowModel row) {
  final dt = _parseApiDateTime(row.datetime);
  if (dt == null) {
    return null;
  }

  return '${_twoDigits(dt.day)}-${_monthLabel(dt.month)}-${dt.year}';
}

String _batteryForRow(BuoyTrajectoryViewRowModel row) {
  if (row.batteryVoltage < 0) {
    return '—';
  }
  return '${row.batteryVoltage.toStringAsFixed(1)} V';
}

DateTime? _parseApiDateTime(String raw) {
  final input = raw.trim();
  if (input.isEmpty) return null;

  final parts = input.split(' ');
  if (parts.length < 2) return null;

  final date = parts[0].split('-');
  final time = parts[1].split(':');
  if (date.length != 3 || time.length != 3) return null;

  final day = int.tryParse(date[0]);
  final month = _monthIndex(date[1]);
  final year = int.tryParse(date[2]);
  final hour = int.tryParse(time[0]);
  final minute = int.tryParse(time[1]);
  final second = int.tryParse(time[2]);
  if (day == null ||
      month == null ||
      year == null ||
      hour == null ||
      minute == null ||
      second == null) {
    return null;
  }

  return DateTime(year, month, day, hour, minute, second);
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
  switch (month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Aug';
    case 9:
      return 'Sep';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
  }
  return '';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
