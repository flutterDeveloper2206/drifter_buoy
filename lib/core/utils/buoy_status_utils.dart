import 'package:drifter_buoy/features/general_user/data/models/user_map_dashboard_get_buoy_map_dashboard_response.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';

/// API may return `Online` (new) or `Active` (legacy).
bool isBuoyOnlineApiStatus(String status) {
  final normalized = status.trim().toLowerCase();
  return normalized == 'online' || normalized == 'active';
}

bool isBuoyBatteryLowFlag(String? raw) {
  final low = (raw ?? '').trim().toLowerCase();
  return low == 'yes' || low == 'true' || low == '1';
}

BuoyStatus buoyStatusFromApiString(
  String status, {
  String? isBatteryLow,
}) {
  final looksLow = isBuoyBatteryLowFlag(isBatteryLow);
  final statusRaw = status.trim();
  if (statusRaw.isEmpty && looksLow) {
    return BuoyStatus.batteryLow;
  }
  final fromApi = _baseBuoyStatusFromApi(statusRaw);
  if (looksLow && fromApi == BuoyStatus.active) {
    return BuoyStatus.batteryLow;
  }
  return fromApi;
}

BuoyStatus _baseBuoyStatusFromApi(String status) {
  final normalized = status.trim().toLowerCase();
  if (isBuoyOnlineApiStatus(normalized)) {
    return BuoyStatus.active;
  }
  if (normalized == 'battery low' ||
      normalized == 'batterylow' ||
      normalized == 'low battery') {
    return BuoyStatus.batteryLow;
  }
  return BuoyStatus.offline;
}

BuoyStatus mapDashboardItemToBuoyStatus(
  UserMapDashboardGetBuoyMapDashboardItem item,
) {
  return buoyStatusFromApiString(
    item.buoyStatus,
    isBatteryLow: item.isBatteryLow,
  );
}

/// User-facing label for map / overview chips.
String buoyStatusDisplayLabel(BuoyStatus status) {
  return switch (status) {
    BuoyStatus.active => 'Online',
    BuoyStatus.offline => 'Offline',
    BuoyStatus.batteryLow => 'Battery Low',
  };
}

/// User-facing label for raw API status strings (export list, setup).
String formatApiBuoyStatusLabel(String raw) {
  final normalized = raw.trim().toLowerCase();
  if (normalized.isEmpty) {
    return 'Unknown';
  }
  if (isBuoyOnlineApiStatus(normalized)) {
    return 'Online';
  }
  if (normalized == 'offline') {
    return 'Offline';
  }
  if (normalized == 'battery low' ||
      normalized == 'batterylow' ||
      normalized == 'low battery') {
    return 'Battery Low';
  }
  return raw
      .trim()
      .split(' ')
      .map(
        (w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
      )
      .join(' ');
}
