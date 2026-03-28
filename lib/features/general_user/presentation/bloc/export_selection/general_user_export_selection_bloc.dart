import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_all_buoys_status_for_export.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserExportSelectionBloc extends Bloc<
  GeneralUserExportSelectionEvent,
  GeneralUserExportSelectionState
> {
  GeneralUserExportSelectionBloc({
    required GeneralUserGetAllBuoysStatusForExport
    getAllBuoysStatusForExport,
  }) : _getAllBuoysStatusForExport = getAllBuoysStatusForExport,
       super(const GeneralUserExportSelectionState.initial()) {
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

  final GeneralUserGetAllBuoysStatusForExport _getAllBuoysStatusForExport;

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

    final result = await _getAllBuoysStatusForExport();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: GeneralUserExportSelectionStatus.error,
            message: failure.message,
          ),
        );
      },
      (response) {
        final allItems = response.result
            .where((item) => item.buoyId.trim().isNotEmpty)
            .map(
              (item) => GeneralUserExportSelectionItem(
                id: item.buoyId.trim(),
                lastUpdate: _formatLastUpdated(item.lastUpdated),
                isActive: item.isActive,
              ),
            )
            .toList(growable: false);

        emit(
          state.copyWith(
            status: GeneralUserExportSelectionStatus.loaded,
            allItems: allItems,
            filteredItems: _filterItems(allItems, state.query),
            selectedIds: state.selectedIds
                .where((id) => allItems.any((item) => item.id == id))
                .toSet(),
            message: '',
          ),
        );
      },
    );
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

}

String _formatLastUpdated(String raw) {
  final value = raw.trim();
  if (value.isEmpty) {
    return '--';
  }

  final match = RegExp(
    r'^(\d{1,2})\/(\d{1,2})\/(\d{4})\s+(\d{1,2}):(\d{2}):(\d{2})$',
  ).firstMatch(value);
  if (match == null) {
    return value;
  }

  final day = int.tryParse(match.group(1) ?? '');
  final month = int.tryParse(match.group(2) ?? '');
  final year = int.tryParse(match.group(3) ?? '');
  final hour24 = int.tryParse(match.group(4) ?? '');
  final minute = int.tryParse(match.group(5) ?? '');
  if (day == null ||
      month == null ||
      year == null ||
      hour24 == null ||
      minute == null) {
    return value;
  }
  if (month < 1 || month > 12 || hour24 < 0 || hour24 > 23) {
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
