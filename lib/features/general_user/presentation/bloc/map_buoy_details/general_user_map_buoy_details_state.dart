import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserMapBuoyDetailsStatus { initial, loading, loaded, error }

class GeneralUserBuoyDetail extends Equatable {
  final DummyBuoy buoy;
  final String lastUpdate;
  final String batteryVoltage;
  final String gpsValue;
  final String signalValue;
  final String statusLabel;

  const GeneralUserBuoyDetail({
    required this.buoy,
    required this.lastUpdate,
    required this.batteryVoltage,
    required this.gpsValue,
    required this.signalValue,
    required this.statusLabel,
  });

  @override
  List<Object> get props => [
    buoy,
    lastUpdate,
    batteryVoltage,
    gpsValue,
    signalValue,
    statusLabel,
  ];
}

class GeneralUserMapBuoyDetailsState extends Equatable {
  final GeneralUserMapBuoyDetailsStatus status;
  final List<GeneralUserBuoyDetail> buoyDetails;
  final int selectedIndex;
  final double zoom;
  final String message;

  const GeneralUserMapBuoyDetailsState({
    required this.status,
    required this.buoyDetails,
    required this.selectedIndex,
    required this.zoom,
    required this.message,
  });

  const GeneralUserMapBuoyDetailsState.initial()
    : status = GeneralUserMapBuoyDetailsStatus.initial,
      buoyDetails = const [],
      selectedIndex = 0,
      zoom = 10.3,
      message = '';

  GeneralUserBuoyDetail? get selectedDetail {
    if (buoyDetails.isEmpty) {
      return null;
    }

    final index = selectedIndex.clamp(0, buoyDetails.length - 1).toInt();
    return buoyDetails[index];
  }

  List<DummyBuoy> get buoys =>
      buoyDetails.map((detail) => detail.buoy).toList(growable: false);

  bool get canZoomIn => zoom < 17;

  bool get canZoomOut => zoom > 3;

  GeneralUserMapBuoyDetailsState copyWith({
    GeneralUserMapBuoyDetailsStatus? status,
    List<GeneralUserBuoyDetail>? buoyDetails,
    int? selectedIndex,
    double? zoom,
    String? message,
  }) {
    return GeneralUserMapBuoyDetailsState(
      status: status ?? this.status,
      buoyDetails: buoyDetails ?? this.buoyDetails,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      zoom: zoom ?? this.zoom,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [status, buoyDetails, selectedIndex, zoom, message];
}
