import 'package:drifter_buoy/core/utils/google_maps_camera_utils.dart';
import 'package:drifter_buoy/core/utils/report_export_date_format.dart';
import 'package:drifter_buoy/core/utils/trajectory_datetime_parse.dart';
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
  final indexed = <({BuoyTrajectoryViewRowModel row, int index})>[];
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i];
    if (!isValidMapCoordinate(row.latitude, row.longitude)) {
      continue;
    }
    indexed.add((row: row, index: i));
  }

  if (indexed.isEmpty) {
    return const [];
  }

  indexed.sort((a, b) {
    final ta = parseTrajectoryDateTime(a.row.sortDatetime);
    final tb = parseTrajectoryDateTime(b.row.sortDatetime);
    return compareTrajectoryDateTimeParts(
      ta,
      tb,
      indexA: a.index,
      indexB: b.index,
    );
  });

  final startIndex = 0;
  final endIndex = indexed.length - 1;

  return indexed
      .asMap()
      .entries
      .map(
        (entry) => _rowToPoint(
          entry.value.row,
          isStartPoint: entry.key == startIndex,
          isEndPoint: entry.key == endIndex && endIndex != startIndex,
        ),
      )
      .toList(growable: false);
}

List<TrajectoryBuoyPoint> applyTrajectoryBatteryDisplayFilter(
  List<TrajectoryBuoyPoint> points, {
  required bool batteryLogsEnabled,
}) {
  if (batteryLogsEnabled) {
    return points;
  }

  return points
      .map(
        (point) => point.status == BuoyStatus.batteryLow
            ? point.copyWith(status: BuoyStatus.online)
            : point,
      )
      .toList(growable: false);
}

TrajectoryBuoyPoint _rowToPoint(
  BuoyTrajectoryViewRowModel row, {
  required bool isStartPoint,
  required bool isEndPoint,
}) {
  return TrajectoryBuoyPoint(
    position: LatLng(row.latitude, row.longitude),
    status: _statusForRow(row),
    label: _labelForRow(row),
    secondaryLabel: _secondaryLabelForRow(row),
    gpsLabel:
        '${row.latitude.toStringAsFixed(5)}, ${row.longitude.toStringAsFixed(5)}',
    timestampLabel: _timestampForRow(row),
    batteryLabel: _batteryForRow(row),
    isStartPoint: isStartPoint,
    isEndPoint: isEndPoint,
  );
}

BuoyStatus _statusForRow(BuoyTrajectoryViewRowModel row) {
  if (row.batteryVoltage < 0) {
    return BuoyStatus.offline;
  }

  final batteryLow = row.isBatteryLow.trim().toLowerCase();
  if (batteryLow == 'yes' || batteryLow == 'true' || batteryLow == '1') {
    return BuoyStatus.batteryLow;
  }

  return BuoyStatus.online;
}

String _labelForRow(BuoyTrajectoryViewRowModel row) {
  return _timestampForRow(row);
}

String _timestampForRow(BuoyTrajectoryViewRowModel row) {
  return formatTrajectoryTimestampLabel(row.datetime);
}

String? _secondaryLabelForRow(BuoyTrajectoryViewRowModel row) {
  return formatTrajectorySecondaryDateLabel(row.sortDatetime);
}

String _batteryForRow(BuoyTrajectoryViewRowModel row) {
  if (row.batteryVoltage < 0) {
    return '—';
  }
  return '${row.batteryVoltage.toStringAsFixed(1)} V';
}
