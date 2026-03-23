import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserMapStatus { initial, loading, loaded, error }

class GeneralUserMapState extends Equatable {
  final GeneralUserMapStatus status;
  final List<DummyBuoy> buoys;
  final bool showActive;
  final bool showOffline;
  final bool showBatteryLow;
  final bool isFilterPanelExpanded;
  final double zoom;
  final String message;

  const GeneralUserMapState({
    required this.status,
    required this.buoys,
    required this.showActive,
    required this.showOffline,
    required this.showBatteryLow,
    required this.isFilterPanelExpanded,
    required this.zoom,
    required this.message,
  });

  const GeneralUserMapState.initial()
    : status = GeneralUserMapStatus.initial,
      buoys = const [],
      showActive = true,
      showOffline = true,
      showBatteryLow = true,
      isFilterPanelExpanded = false,
      zoom = 10.3,
      message = '';

  List<DummyBuoy> get filteredBuoys {
    return buoys
        .where((buoy) {
          return switch (buoy.status) {
            BuoyStatus.active => showActive,
            BuoyStatus.offline => showOffline,
            BuoyStatus.batteryLow => showBatteryLow,
          };
        })
        .toList(growable: false);
  }

  bool get canZoomIn => zoom < 17;

  bool get canZoomOut => zoom > 3;

  GeneralUserMapState copyWith({
    GeneralUserMapStatus? status,
    List<DummyBuoy>? buoys,
    bool? showActive,
    bool? showOffline,
    bool? showBatteryLow,
    bool? isFilterPanelExpanded,
    double? zoom,
    String? message,
  }) {
    return GeneralUserMapState(
      status: status ?? this.status,
      buoys: buoys ?? this.buoys,
      showActive: showActive ?? this.showActive,
      showOffline: showOffline ?? this.showOffline,
      showBatteryLow: showBatteryLow ?? this.showBatteryLow,
      isFilterPanelExpanded:
          isFilterPanelExpanded ?? this.isFilterPanelExpanded,
      zoom: zoom ?? this.zoom,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [
    status,
    buoys,
    showActive,
    showOffline,
    showBatteryLow,
    isFilterPanelExpanded,
    zoom,
    message,
  ];
}
