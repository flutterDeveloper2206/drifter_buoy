import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_all_buoys_data_overview_view.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserBuoysBloc
    extends Bloc<GeneralUserBuoysEvent, GeneralUserBuoysState> {
  GeneralUserBuoysBloc({
    required GeneralUserGetAllBuoysDataOverviewView
    getAllBuoysDataOverviewView,
  }) : _getAllBuoysDataOverviewView = getAllBuoysDataOverviewView,
       super(const GeneralUserBuoysState.initial()) {
    on<LoadGeneralUserBuoys>(_onLoadGeneralUserBuoys);
    on<UpdateGeneralUserBuoysQuery>(_onUpdateGeneralUserBuoysQuery);
    on<ClearGeneralUserBuoysQuery>(_onClearGeneralUserBuoysQuery);
    on<ChangeGeneralUserBuoysFilter>(_onChangeGeneralUserBuoysFilter);
  }

  final GeneralUserGetAllBuoysDataOverviewView _getAllBuoysDataOverviewView;

  Future<void> _onLoadGeneralUserBuoys(
    LoadGeneralUserBuoys event,
    Emitter<GeneralUserBuoysState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserBuoys event triggered');
    emit(state.copyWith(status: GeneralUserBuoysStatus.loading, message: ''));

    final result = await _getAllBuoysDataOverviewView();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: GeneralUserBuoysStatus.error,
            message: failure.message,
          ),
        );
      },
      (response) {
        final root = response.result.isNotEmpty ? response.result.first : null;
        final summary = root?.summary;
        final allBuoys = (root?.buoyList ?? const [])
            .where((item) => item.buoyId.trim().isNotEmpty)
            .map(
              (item) => GeneralUserBuoyItem(
                id: item.buoyId.trim(),
                lastUpdate: _formatLastReceived(item.lastReceived),
                battery: _formatBattery(item.batteryVoltage),
                gps: _formatGps(item.latitude, item.longitude),
                signal: _formatSignal(item.signalStrength),
                status: _mapStatus(item.status),
              ),
            )
            .toList(growable: false);

        final filtered = _applyFilters(
          source: allBuoys,
          query: state.query,
          filter: state.selectedFilter,
        );

        emit(
          state.copyWith(
            status: GeneralUserBuoysStatus.loaded,
            allBuoys: allBuoys,
            filteredBuoys: filtered,
            activeCount: summary?.activeBuoys ?? 0,
            offlineCount: summary?.offlineBuoys ?? 0,
            batteryLowCount: summary?.batteryLowBuoys ?? 0,
            totalBuoys: summary?.totalBuoys ?? allBuoys.length,
            message: '',
          ),
        );
        AppLogger.i(
          'LoadGeneralUserBuoys success: ${filtered.length} displayed buoys',
        );
      },
    );
  }

  void _onUpdateGeneralUserBuoysQuery(
    UpdateGeneralUserBuoysQuery event,
    Emitter<GeneralUserBuoysState> emit,
  ) {
    final nextQuery = event.query;
    emit(
      state.copyWith(
        query: nextQuery,
        filteredBuoys: _applyFilters(
          source: state.allBuoys,
          query: nextQuery,
          filter: state.selectedFilter,
        ),
      ),
    );
  }

  void _onClearGeneralUserBuoysQuery(
    ClearGeneralUserBuoysQuery event,
    Emitter<GeneralUserBuoysState> emit,
  ) {
    emit(
      state.copyWith(
        query: '',
        filteredBuoys: _applyFilters(
          source: state.allBuoys,
          query: '',
          filter: state.selectedFilter,
        ),
      ),
    );
  }

  void _onChangeGeneralUserBuoysFilter(
    ChangeGeneralUserBuoysFilter event,
    Emitter<GeneralUserBuoysState> emit,
  ) {
    emit(
      state.copyWith(
        selectedFilter: event.filter,
        filteredBuoys: _applyFilters(
          source: state.allBuoys,
          query: state.query,
          filter: event.filter,
        ),
      ),
    );
  }

  List<GeneralUserBuoyItem> _applyFilters({
    required List<GeneralUserBuoyItem> source,
    required String query,
    required GeneralUserBuoyFilter filter,
  }) {
    final trimmed = query.trim().toLowerCase();

    return source
        .where((buoy) {
          final statusMatch = switch (filter) {
            GeneralUserBuoyFilter.all => true,
            GeneralUserBuoyFilter.active =>
              buoy.status == GeneralUserBuoyConnectionStatus.active,
            GeneralUserBuoyFilter.offline =>
              buoy.status == GeneralUserBuoyConnectionStatus.offline,
            GeneralUserBuoyFilter.batteryLow =>
              buoy.status == GeneralUserBuoyConnectionStatus.batteryLow,
          };

          if (!statusMatch) {
            return false;
          }

          if (trimmed.isEmpty) {
            return true;
          }

          return buoy.id.toLowerCase().contains(trimmed);
        })
        .toList(growable: false);
  }

}

GeneralUserBuoyConnectionStatus _mapStatus(String rawStatus) {
  final status = rawStatus.trim().toLowerCase();
  if (status == 'active') {
    return GeneralUserBuoyConnectionStatus.active;
  }
  if (status == 'offline') {
    return GeneralUserBuoyConnectionStatus.offline;
  }
  if (status == 'battery low' ||
      status == 'batterylow' ||
      status == 'low battery') {
    return GeneralUserBuoyConnectionStatus.batteryLow;
  }
  return GeneralUserBuoyConnectionStatus.offline;
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
