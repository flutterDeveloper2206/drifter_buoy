import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_all_buoys_status.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_devices/general_user_setup_devices_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_devices/general_user_setup_devices_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserSetupDevicesBloc
    extends Bloc<GeneralUserSetupDevicesEvent, GeneralUserSetupDevicesState> {
  GeneralUserSetupDevicesBloc({
    required GeneralUserGetAllBuoysStatus getAllBuoysStatus,
  }) : _getAllBuoysStatus = getAllBuoysStatus,
       super(const GeneralUserSetupDevicesState.initial()) {
    on<LoadGeneralUserSetupDevices>(_onLoad);
    on<UpdateGeneralUserSetupDevicesQuery>(_onQueryChanged);
    on<ClearGeneralUserSetupDevicesQuery>(_onClearQuery);
  }

  final GeneralUserGetAllBuoysStatus _getAllBuoysStatus;

  Future<void> _onLoad(
    LoadGeneralUserSetupDevices event,
    Emitter<GeneralUserSetupDevicesState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserSetupDevices');
    emit(
      state.copyWith(
        status: GeneralUserSetupDevicesStatus.loading,
        message: '',
      ),
    );

    final result = await _getAllBuoysStatus();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: GeneralUserSetupDevicesStatus.error,
            message: failure.message,
          ),
        );
      },
      (response) {
        final allDevices = response.result.buoyStatusList
            .where((e) => e.buoyId.trim().isNotEmpty)
            .map(
              (item) => GeneralUserSetupDeviceItem(
                id: item.buoyId.trim(),
                lastUpdate:
                    'Last Update : ${_formatLastReceived(item.lastReceived)}',
                battery: _formatBattery(item.batteryVoltage),
                gps: _formatGps(item.latitude, item.longitude),
                signal: _formatSignal(item.signalStrength),
                connectionStatus: _mapConnectionStatus(item.status),
                statusLabel: _formatStatusLabel(item.status),
              ),
            )
            .toList(growable: false);

        emit(
          state.copyWith(
            status: GeneralUserSetupDevicesStatus.loaded,
            allDevices: allDevices,
            filteredDevices: _filterByQuery(allDevices, state.query),
            message: '',
          ),
        );
      },
    );
  }

  void _onQueryChanged(
    UpdateGeneralUserSetupDevicesQuery event,
    Emitter<GeneralUserSetupDevicesState> emit,
  ) {
    final q = event.query;
    emit(
      state.copyWith(
        query: q,
        filteredDevices: _filterByQuery(state.allDevices, q),
      ),
    );
  }

  void _onClearQuery(
    ClearGeneralUserSetupDevicesQuery event,
    Emitter<GeneralUserSetupDevicesState> emit,
  ) {
    emit(
      state.copyWith(
        query: '',
        filteredDevices: _filterByQuery(state.allDevices, ''),
      ),
    );
  }

  List<GeneralUserSetupDeviceItem> _filterByQuery(
    List<GeneralUserSetupDeviceItem> source,
    String query,
  ) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return List<GeneralUserSetupDeviceItem>.from(source);
    }
    return source
        .where(
          (d) => d.id
              .toLowerCase()
              .replaceAll(' ', '')
              .contains(trimmed.replaceAll(' ', '')),
        )
        .toList(growable: false);
  }
}

GeneralUserSetupDeviceConnectionStatus _mapConnectionStatus(String raw) {
  final status = raw.trim().toLowerCase();
  if (status == 'active') {
    return GeneralUserSetupDeviceConnectionStatus.active;
  }
  if (status == 'offline') {
    return GeneralUserSetupDeviceConnectionStatus.offline;
  }
  if (status == 'battery low' ||
      status == 'batterylow' ||
      status == 'low battery') {
    return GeneralUserSetupDeviceConnectionStatus.batteryLow;
  }
  return GeneralUserSetupDeviceConnectionStatus.offline;
}

String _formatStatusLabel(String raw) {
  final s = raw.trim();
  if (s.isEmpty) {
    return 'Unknown';
  }
  return s
      .split(' ')
      .map(
        (w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String _formatLastReceived(String raw) {
  final value = raw.trim();
  if (value.isEmpty) {
    return '--';
  }

  final match = RegExp(
    r'^(\d{4})-(\d{1,2})-(\d{1,2})\s+(\d{1,2}):(\d{2}):(\d{2})$',
  ).firstMatch(value);
  if (match == null) {
    return value;
  }

  final year = int.tryParse(match.group(1) ?? '');
  final month = int.tryParse(match.group(2) ?? '');
  final day = int.tryParse(match.group(3) ?? '');
  final hour24 = int.tryParse(match.group(4) ?? '');
  final minute = int.tryParse(match.group(5) ?? '');
  if (year == null ||
      month == null ||
      day == null ||
      hour24 == null ||
      minute == null ||
      month < 1 ||
      month > 12 ||
      hour24 < 0 ||
      hour24 > 23) {
    return value;
  }

  const monthNames = <String>[
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
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final dd = day.toString().padLeft(2, '0');
  final mm = minute.toString().padLeft(2, '0');
  return '$dd ${monthNames[month - 1]} $year, $hour12:$mm $period';
}

String _formatBattery(double batteryVoltage) {
  if (batteryVoltage <= 0) {
    return '--';
  }
  return '${batteryVoltage.toStringAsFixed(1)} v';
}

String _formatGps(double latitude, double longitude) {
  if (latitude == 0 && longitude == 0) {
    return '--';
  }
  final latDir = latitude >= 0 ? 'N' : 'S';
  final lonDir = longitude >= 0 ? 'E' : 'W';
  final lat = latitude.abs().toStringAsFixed(2);
  final lon = longitude.abs().toStringAsFixed(2);
  return '$lat$latDir\n$lon$lonDir';
}

String _formatSignal(String signalStrength) {
  final value = signalStrength.trim();
  return value.isEmpty ? '--' : value;
}
