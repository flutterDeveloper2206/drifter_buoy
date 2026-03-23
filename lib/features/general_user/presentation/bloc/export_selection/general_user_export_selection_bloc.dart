import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserExportSelectionBloc extends Bloc<
  GeneralUserExportSelectionEvent,
  GeneralUserExportSelectionState
> {
  GeneralUserExportSelectionBloc()
    : super(const GeneralUserExportSelectionState.initial()) {
    on<LoadGeneralUserExportSelection>(_onLoadGeneralUserExportSelection);
    on<UpdateGeneralUserExportSelectionQuery>(
      _onUpdateGeneralUserExportSelectionQuery,
    );
    on<ToggleGeneralUserExportSelectionItem>(
      _onToggleGeneralUserExportSelectionItem,
    );
    on<ToggleGeneralUserExportSelectionAll>(
      _onToggleGeneralUserExportSelectionAll,
    );
  }

  Future<void> _onLoadGeneralUserExportSelection(
    LoadGeneralUserExportSelection event,
    Emitter<GeneralUserExportSelectionState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserExportSelection event triggered');
    emit(
      state.copyWith(
        status: GeneralUserExportSelectionStatus.loading,
        message: '',
      ),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      final allItems = _dummyItems();
      emit(
        state.copyWith(
          status: GeneralUserExportSelectionStatus.loaded,
          allItems: allItems,
          filteredItems: allItems,
          selectedIds: <String>{},
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: GeneralUserExportSelectionStatus.error,
          message: 'Unable to load buoy list. Please try again.',
        ),
      );
    }
  }

  void _onUpdateGeneralUserExportSelectionQuery(
    UpdateGeneralUserExportSelectionQuery event,
    Emitter<GeneralUserExportSelectionState> emit,
  ) {
    final query = event.query;
    emit(
      state.copyWith(
        query: query,
        filteredItems: _filterItems(state.allItems, query),
      ),
    );
  }

  void _onToggleGeneralUserExportSelectionItem(
    ToggleGeneralUserExportSelectionItem event,
    Emitter<GeneralUserExportSelectionState> emit,
  ) {
    final updated = Set<String>.from(state.selectedIds);
    if (updated.contains(event.id)) {
      updated.remove(event.id);
    } else {
      updated.add(event.id);
    }
    emit(state.copyWith(selectedIds: updated));
  }

  void _onToggleGeneralUserExportSelectionAll(
    ToggleGeneralUserExportSelectionAll event,
    Emitter<GeneralUserExportSelectionState> emit,
  ) {
    final visibleIds = state.filteredItems.map((item) => item.id).toSet();
    final updated = Set<String>.from(state.selectedIds);
    if (state.allFilteredSelected) {
      updated.removeAll(visibleIds);
    } else {
      updated.addAll(visibleIds);
    }
    emit(state.copyWith(selectedIds: updated));
  }

  List<GeneralUserExportSelectionItem> _filterItems(
    List<GeneralUserExportSelectionItem> source,
    String query,
  ) {
    final normalized = query.trim().toLowerCase().replaceAll(' ', '');
    if (normalized.isEmpty) {
      return source;
    }

    return source.where((item) {
      final id = item.id.toLowerCase().replaceAll(' ', '');
      return id.contains(normalized);
    }).toList(growable: false);
  }

  List<GeneralUserExportSelectionItem> _dummyItems() {
    return List<GeneralUserExportSelectionItem>.generate(12, (index) {
      final idNumber = (index + 1).toString().padLeft(2, '0');
      return GeneralUserExportSelectionItem(
        id: 'DB - $idNumber',
        lastUpdate: '09:20 AM',
        isActive: true,
      );
    });
  }
}
