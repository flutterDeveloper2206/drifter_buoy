import 'package:equatable/equatable.dart';

enum GeneralUserBuoysStatus { initial, loading, loaded, error }

enum GeneralUserBuoyFilter { all, active, offline, batteryLow }

enum GeneralUserBuoyConnectionStatus { active, offline, batteryLow }

class GeneralUserBuoyItem extends Equatable {
  final String id;
  final String lastUpdate;
  final String battery;
  final String gps;
  final String signal;
  final GeneralUserBuoyConnectionStatus status;

  const GeneralUserBuoyItem({
    required this.id,
    required this.lastUpdate,
    required this.battery,
    required this.gps,
    required this.signal,
    required this.status,
  });

  @override
  List<Object> get props => [id, lastUpdate, battery, gps, signal, status];
}

class GeneralUserBuoysState extends Equatable {
  final GeneralUserBuoysStatus status;
  final String query;
  final GeneralUserBuoyFilter selectedFilter;
  final List<GeneralUserBuoyItem> allBuoys;
  final List<GeneralUserBuoyItem> filteredBuoys;
  final int activeCount;
  final int offlineCount;
  final int batteryLowCount;
  final int totalBuoys;
  final String message;

  const GeneralUserBuoysState({
    required this.status,
    required this.query,
    required this.selectedFilter,
    required this.allBuoys,
    required this.filteredBuoys,
    required this.activeCount,
    required this.offlineCount,
    required this.batteryLowCount,
    required this.totalBuoys,
    required this.message,
  });

  const GeneralUserBuoysState.initial()
    : status = GeneralUserBuoysStatus.initial,
      query = '',
      selectedFilter = GeneralUserBuoyFilter.all,
      allBuoys = const [],
      filteredBuoys = const [],
      activeCount = 0,
      offlineCount = 0,
      batteryLowCount = 0,
      totalBuoys = 0,
      message = '';

  GeneralUserBuoysState copyWith({
    GeneralUserBuoysStatus? status,
    String? query,
    GeneralUserBuoyFilter? selectedFilter,
    List<GeneralUserBuoyItem>? allBuoys,
    List<GeneralUserBuoyItem>? filteredBuoys,
    int? activeCount,
    int? offlineCount,
    int? batteryLowCount,
    int? totalBuoys,
    String? message,
  }) {
    return GeneralUserBuoysState(
      status: status ?? this.status,
      query: query ?? this.query,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      allBuoys: allBuoys ?? this.allBuoys,
      filteredBuoys: filteredBuoys ?? this.filteredBuoys,
      activeCount: activeCount ?? this.activeCount,
      offlineCount: offlineCount ?? this.offlineCount,
      batteryLowCount: batteryLowCount ?? this.batteryLowCount,
      totalBuoys: totalBuoys ?? this.totalBuoys,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [
    status,
    query,
    selectedFilter,
    allBuoys,
    filteredBuoys,
    activeCount,
    offlineCount,
    batteryLowCount,
    totalBuoys,
    message,
  ];
}
