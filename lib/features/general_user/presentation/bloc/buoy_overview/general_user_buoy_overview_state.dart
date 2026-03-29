import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_event.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class GeneralUserBuoyOverviewData extends Equatable {
  final String id;
  final bool isActive;
  final String lastUpdate;
  final String batteryVoltage;
  final String gpsLatitude;
  final String gpsLongitude;
  final String signalStrength;
  final bool isBatteryLow;
  final List<LatLng> trajectoryPoints;

  const GeneralUserBuoyOverviewData({
    required this.id,
    required this.isActive,
    required this.lastUpdate,
    required this.batteryVoltage,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.signalStrength,
    required this.isBatteryLow,
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
        isBatteryLow,
        trajectoryPoints,
      ];
}

sealed class GeneralUserBuoyOverviewState extends Equatable {
  const GeneralUserBuoyOverviewState();

  @override
  List<Object?> get props => [];
}

final class GeneralUserBuoyOverviewInitial extends GeneralUserBuoyOverviewState {
  const GeneralUserBuoyOverviewInitial();
}

final class GeneralUserBuoyOverviewLoading extends GeneralUserBuoyOverviewState {
  const GeneralUserBuoyOverviewLoading({required this.buoyId});

  final String buoyId;

  @override
  List<Object?> get props => [buoyId];
}

final class GeneralUserBuoyOverviewLoaded extends GeneralUserBuoyOverviewState {
  const GeneralUserBuoyOverviewLoaded({
    required this.data,
    required this.selectedTab,
    this.message = '',
    this.isSuccessMessage = false,
  });

  final GeneralUserBuoyOverviewData data;
  final GeneralUserBuoyOverviewTab selectedTab;
  final String message;
  final bool isSuccessMessage;

  GeneralUserBuoyOverviewLoaded copyWith({
    GeneralUserBuoyOverviewData? data,
    GeneralUserBuoyOverviewTab? selectedTab,
    String? message,
    bool? isSuccessMessage,
  }) {
    return GeneralUserBuoyOverviewLoaded(
      data: data ?? this.data,
      selectedTab: selectedTab ?? this.selectedTab,
      message: message ?? this.message,
      isSuccessMessage: isSuccessMessage ?? this.isSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        data,
        selectedTab,
        message,
        isSuccessMessage,
      ];
}

final class GeneralUserBuoyOverviewError extends GeneralUserBuoyOverviewState {
  const GeneralUserBuoyOverviewError({
    required this.message,
    required this.buoyId,
  });

  final String message;
  final String buoyId;

  @override
  List<Object?> get props => [message, buoyId];
}
