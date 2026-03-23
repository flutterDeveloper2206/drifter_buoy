import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_event.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

enum GeneralUserBuoyOverviewStatus { initial, loading, loaded, error }

class GeneralUserBuoyOverviewData extends Equatable {
  final String id;
  final bool isActive;
  final String lastUpdate;
  final String batteryVoltage;
  final String gpsLatitude;
  final String gpsLongitude;
  final String signalStrength;
  final List<LatLng> trajectoryPoints;

  const GeneralUserBuoyOverviewData({
    required this.id,
    required this.isActive,
    required this.lastUpdate,
    required this.batteryVoltage,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.signalStrength,
    required this.trajectoryPoints,
  });

  @override
  List<Object> get props => [
    id,
    isActive,
    lastUpdate,
    batteryVoltage,
    gpsLatitude,
    gpsLongitude,
    signalStrength,
    trajectoryPoints,
  ];
}

class GeneralUserBuoyOverviewState extends Equatable {
  final GeneralUserBuoyOverviewStatus status;
  final GeneralUserBuoyOverviewTab selectedTab;
  final GeneralUserBuoyOverviewData? data;
  final String message;
  final bool isSuccessMessage;

  const GeneralUserBuoyOverviewState({
    required this.status,
    required this.selectedTab,
    required this.data,
    required this.message,
    required this.isSuccessMessage,
  });

  const GeneralUserBuoyOverviewState.initial()
    : status = GeneralUserBuoyOverviewStatus.initial,
      selectedTab = GeneralUserBuoyOverviewTab.overview,
      data = null,
      message = '',
      isSuccessMessage = false;

  GeneralUserBuoyOverviewState copyWith({
    GeneralUserBuoyOverviewStatus? status,
    GeneralUserBuoyOverviewTab? selectedTab,
    GeneralUserBuoyOverviewData? data,
    bool clearData = false,
    String? message,
    bool? isSuccessMessage,
  }) {
    return GeneralUserBuoyOverviewState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      data: clearData ? null : (data ?? this.data),
      message: message ?? this.message,
      isSuccessMessage: isSuccessMessage ?? this.isSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedTab,
    data,
    message,
    isSuccessMessage,
  ];
}
