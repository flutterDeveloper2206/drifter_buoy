import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_search/general_user_map_search_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_search/general_user_map_search_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class GeneralUserMapSearchBloc
    extends Bloc<GeneralUserMapSearchEvent, GeneralUserMapSearchState> {
  GeneralUserMapSearchBloc()
    : super(const GeneralUserMapSearchState.initial()) {
    on<LoadGeneralUserMapSearch>(_onLoadGeneralUserMapSearch);
    on<UpdateGeneralUserMapSearchQuery>(_onUpdateGeneralUserMapSearchQuery);
    on<ClearGeneralUserMapSearchQuery>(_onClearGeneralUserMapSearchQuery);
    on<ZoomInGeneralUserMapSearch>(_onZoomInGeneralUserMapSearch);
    on<ZoomOutGeneralUserMapSearch>(_onZoomOutGeneralUserMapSearch);
  }

  Future<void> _onLoadGeneralUserMapSearch(
    LoadGeneralUserMapSearch event,
    Emitter<GeneralUserMapSearchState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserMapSearch event triggered');
    emit(
      state.copyWith(status: GeneralUserMapSearchStatus.loading, message: ''),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      final buoys = _dummySearchBuoys();
      final initialQuery = state.query;
      final filtered = _filterByQuery(buoys, initialQuery);
      emit(
        state.copyWith(
          status: GeneralUserMapSearchStatus.loaded,
          allBuoys: buoys,
          filteredBuoys: filtered,
          selectedBuoy: filtered.isNotEmpty ? filtered.first : null,
        ),
      );
      AppLogger.i(
        'LoadGeneralUserMapSearch success: ${filtered.length} results',
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'LoadGeneralUserMapSearch failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: GeneralUserMapSearchStatus.error,
          message: 'Unable to load search data. Please try again.',
        ),
      );
    }
  }

  void _onUpdateGeneralUserMapSearchQuery(
    UpdateGeneralUserMapSearchQuery event,
    Emitter<GeneralUserMapSearchState> emit,
  ) {
    final query = event.query.trim();
    final filtered = _filterByQuery(state.allBuoys, query);
    emit(
      state.copyWith(
        query: event.query,
        filteredBuoys: filtered,
        selectedBuoy: filtered.isNotEmpty ? filtered.first : null,
      ),
    );
  }

  void _onClearGeneralUserMapSearchQuery(
    ClearGeneralUserMapSearchQuery event,
    Emitter<GeneralUserMapSearchState> emit,
  ) {
    emit(
      state.copyWith(
        query: '',
        filteredBuoys: state.allBuoys,
        selectedBuoy: state.allBuoys.isNotEmpty ? state.allBuoys.first : null,
      ),
    );
  }

  void _onZoomInGeneralUserMapSearch(
    ZoomInGeneralUserMapSearch event,
    Emitter<GeneralUserMapSearchState> emit,
  ) {
    if (!state.canZoomIn) {
      return;
    }

    emit(state.copyWith(zoom: (state.zoom + 0.7).clamp(3, 17).toDouble()));
  }

  void _onZoomOutGeneralUserMapSearch(
    ZoomOutGeneralUserMapSearch event,
    Emitter<GeneralUserMapSearchState> emit,
  ) {
    if (!state.canZoomOut) {
      return;
    }

    emit(state.copyWith(zoom: (state.zoom - 0.7).clamp(3, 17).toDouble()));
  }

  List<DummyBuoy> _filterByQuery(List<DummyBuoy> source, String query) {
    if (query.isEmpty) {
      return source;
    }

    final normalizedQuery = query.toLowerCase();
    return source
        .where((buoy) => buoy.id.toLowerCase().contains(normalizedQuery))
        .toList(growable: false);
  }

  List<DummyBuoy> _dummySearchBuoys() {
    return const [
      DummyBuoy(
        id: 'DB-01',
        position: LatLng(37.7955, -122.4312),
        status: BuoyStatus.active,
      ),
      DummyBuoy(
        id: 'DB-02',
        position: LatLng(37.7570, -122.4010),
        status: BuoyStatus.active,
      ),
      DummyBuoy(
        id: 'DB-03',
        position: LatLng(37.7688, -122.3820),
        status: BuoyStatus.active,
      ),
      DummyBuoy(
        id: 'DB-04',
        position: LatLng(37.7860, -122.3738),
        status: BuoyStatus.batteryLow,
      ),
      DummyBuoy(
        id: 'DB-05',
        position: LatLng(37.7775, -122.3562),
        status: BuoyStatus.offline,
      ),
      DummyBuoy(
        id: 'DB-06',
        position: LatLng(37.7414, -122.4098),
        status: BuoyStatus.active,
      ),
      DummyBuoy(
        id: 'DB-07',
        position: LatLng(37.7244, -122.3875),
        status: BuoyStatus.active,
      ),
      DummyBuoy(
        id: 'DB-08',
        position: LatLng(37.7128, -122.3518),
        status: BuoyStatus.active,
      ),
    ];
  }
}
