import 'package:equatable/equatable.dart';

enum GeneralUserExportSelectionStatus { initial, loading, loaded, error }

class GeneralUserExportSelectionItem extends Equatable {
  final String id;
  final String lastUpdate;
  final bool isActive;

  const GeneralUserExportSelectionItem({
    required this.id,
    required this.lastUpdate,
    required this.isActive,
  });

  @override
  List<Object> get props => [id, lastUpdate, isActive];
}

class GeneralUserExportSelectionState extends Equatable {
  final GeneralUserExportSelectionStatus status;
  final String query;
  final List<GeneralUserExportSelectionItem> allItems;
  final List<GeneralUserExportSelectionItem> filteredItems;
  final Set<String> selectedIds;
  final String message;

  const GeneralUserExportSelectionState({
    required this.status,
    required this.query,
    required this.allItems,
    required this.filteredItems,
    required this.selectedIds,
    required this.message,
  });

  const GeneralUserExportSelectionState.initial()
    : status = GeneralUserExportSelectionStatus.initial,
      query = '',
      allItems = const [],
      filteredItems = const [],
      selectedIds = const {},
      message = '';

  int get selectedCount => selectedIds.length;

  bool get allFilteredSelected {
    if (filteredItems.isEmpty) {
      return false;
    }
    return filteredItems.every((item) => selectedIds.contains(item.id));
  }

  GeneralUserExportSelectionState copyWith({
    GeneralUserExportSelectionStatus? status,
    String? query,
    List<GeneralUserExportSelectionItem>? allItems,
    List<GeneralUserExportSelectionItem>? filteredItems,
    Set<String>? selectedIds,
    String? message,
  }) {
    return GeneralUserExportSelectionState(
      status: status ?? this.status,
      query: query ?? this.query,
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedIds: selectedIds ?? this.selectedIds,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [
    status,
    query,
    allItems,
    filteredItems,
    selectedIds,
    message,
  ];
}
