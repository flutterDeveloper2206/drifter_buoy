import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserBuoysBloc
    extends Bloc<GeneralUserBuoysEvent, GeneralUserBuoysState> {
  GeneralUserBuoysBloc() : super(const GeneralUserBuoysState.initial()) {
    on<LoadGeneralUserBuoys>(_onLoadGeneralUserBuoys);
    on<UpdateGeneralUserBuoysQuery>(_onUpdateGeneralUserBuoysQuery);
    on<ClearGeneralUserBuoysQuery>(_onClearGeneralUserBuoysQuery);
    on<ChangeGeneralUserBuoysFilter>(_onChangeGeneralUserBuoysFilter);
  }

  Future<void> _onLoadGeneralUserBuoys(
    LoadGeneralUserBuoys event,
    Emitter<GeneralUserBuoysState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserBuoys event triggered');
    emit(state.copyWith(status: GeneralUserBuoysStatus.loading, message: ''));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      final allBuoys = _dummyBuoys();
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
          activeCount: 8,
          offlineCount: 1,
          batteryLowCount: 0,
          totalBuoys: 10,
          message: '',
        ),
      );
      AppLogger.i(
        'LoadGeneralUserBuoys success: ${filtered.length} displayed buoys',
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'LoadGeneralUserBuoys failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: GeneralUserBuoysStatus.error,
          message: 'Unable to load buoy list. Please try again.',
        ),
      );
    }
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

  List<GeneralUserBuoyItem> _dummyBuoys() {
    return const [
      GeneralUserBuoyItem(
        id: 'DB - 01',
        lastUpdate: '09:20 AM',
        battery: '11.8 v',
        gps: '15°40\'51.0"N',
        signal: '79%',
        status: GeneralUserBuoyConnectionStatus.active,
      ),
      GeneralUserBuoyItem(
        id: 'DB - 02',
        lastUpdate: '09:18 AM',
        battery: '11.6 v',
        gps: '15°40\'45.2"N',
        signal: '76%',
        status: GeneralUserBuoyConnectionStatus.active,
      ),
      GeneralUserBuoyItem(
        id: 'DB - 03',
        lastUpdate: '09:11 AM',
        battery: '11.7 v',
        gps: '15°40\'39.9"N',
        signal: '78%',
        status: GeneralUserBuoyConnectionStatus.active,
      ),
      GeneralUserBuoyItem(
        id: 'DB - 04',
        lastUpdate: '08:58 AM',
        battery: '11.5 v',
        gps: '15°40\'31.4"N',
        signal: '74%',
        status: GeneralUserBuoyConnectionStatus.active,
      ),
      GeneralUserBuoyItem(
        id: 'DB - 05',
        lastUpdate: '08:49 AM',
        battery: '11.8 v',
        gps: '15°40\'26.0"N',
        signal: '81%',
        status: GeneralUserBuoyConnectionStatus.active,
      ),
      GeneralUserBuoyItem(
        id: 'DB - 06',
        lastUpdate: '08:42 AM',
        battery: '11.6 v',
        gps: '15°40\'20.5"N',
        signal: '75%',
        status: GeneralUserBuoyConnectionStatus.active,
      ),
      GeneralUserBuoyItem(
        id: 'DB - 07',
        lastUpdate: '08:31 AM',
        battery: '11.8 v',
        gps: '15°40\'15.1"N',
        signal: '80%',
        status: GeneralUserBuoyConnectionStatus.active,
      ),
      GeneralUserBuoyItem(
        id: 'DB - 08',
        lastUpdate: '08:25 AM',
        battery: '11.7 v',
        gps: '15°40\'09.0"N',
        signal: '77%',
        status: GeneralUserBuoyConnectionStatus.active,
      ),
      GeneralUserBuoyItem(
        id: 'DB - 09',
        lastUpdate: '08:07 AM',
        battery: '11.3 v',
        gps: '15°40\'04.6"N',
        signal: '39%',
        status: GeneralUserBuoyConnectionStatus.offline,
      ),
      GeneralUserBuoyItem(
        id: 'DB - 10',
        lastUpdate: '07:52 AM',
        battery: '11.4 v',
        gps: '15°39\'58.3"N',
        signal: '58%',
        status: GeneralUserBuoyConnectionStatus.active,
      ),
    ];
  }
}
