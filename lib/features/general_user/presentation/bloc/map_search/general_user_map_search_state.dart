import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserMapSearchStatus { initial, loading, loaded, error }

class GeneralUserMapSearchState extends Equatable {
  final GeneralUserMapSearchStatus status;
  final String query;
  final List<DummyBuoy> allBuoys;
  final List<DummyBuoy> filteredBuoys;
  final DummyBuoy? selectedBuoy;
  final double zoom;
  final String message;

  const GeneralUserMapSearchState({
    required this.status,
    required this.query,
    required this.allBuoys,
    required this.filteredBuoys,
    required this.selectedBuoy,
    required this.zoom,
    required this.message,
  });

  const GeneralUserMapSearchState.initial()
    : status = GeneralUserMapSearchStatus.initial,
      query = 'DB-01',
      allBuoys = const [],
      filteredBuoys = const [],
      selectedBuoy = null,
      zoom = 10.3,
      message = '';

  bool get canZoomIn => zoom < 17;

  bool get canZoomOut => zoom > 3;

  GeneralUserMapSearchState copyWith({
    GeneralUserMapSearchStatus? status,
    String? query,
    List<DummyBuoy>? allBuoys,
    List<DummyBuoy>? filteredBuoys,
    DummyBuoy? selectedBuoy,
    bool clearSelectedBuoy = false,
    double? zoom,
    String? message,
  }) {
    return GeneralUserMapSearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      allBuoys: allBuoys ?? this.allBuoys,
      filteredBuoys: filteredBuoys ?? this.filteredBuoys,
      selectedBuoy: clearSelectedBuoy
          ? null
          : (selectedBuoy ?? this.selectedBuoy),
      zoom: zoom ?? this.zoom,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    allBuoys,
    filteredBuoys,
    selectedBuoy,
    zoom,
    message,
  ];
}
