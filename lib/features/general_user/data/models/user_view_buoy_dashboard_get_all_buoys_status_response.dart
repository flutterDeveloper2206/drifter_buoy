import 'package:equatable/equatable.dart';

/// Response from `GetAllBuoysStatus` (UserViewBuoyDashboard).
class UserViewBuoyDashboardGetAllBuoysStatusResponse extends Equatable {
  const UserViewBuoyDashboardGetAllBuoysStatusResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  final int statusCode;
  final String message;
  final GetAllBuoysStatusResult result;
  final bool isSuccess;

  factory UserViewBuoyDashboardGetAllBuoysStatusResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawResult = json['result'];
    final result = rawResult is Map
        ? GetAllBuoysStatusResult.fromJson(
            Map<String, dynamic>.from(rawResult),
          )
        : const GetAllBuoysStatusResult(buoyStatusList: []);

    return UserViewBuoyDashboardGetAllBuoysStatusResponse(
      statusCode: _toInt(json['statusCode']),
      message: (json['message'] ?? '').toString(),
      result: result,
      isSuccess: json['isSuccess'] == true,
    );
  }

  @override
  List<Object> get props => [statusCode, message, result, isSuccess];
}

class GetAllBuoysStatusResult extends Equatable {
  const GetAllBuoysStatusResult({required this.buoyStatusList});

  final List<BuoyStatusItemModel> buoyStatusList;

  factory GetAllBuoysStatusResult.fromJson(Map<String, dynamic> json) {
    final raw = json['buoyStatusList'];
    if (raw is! List) {
      return const GetAllBuoysStatusResult(buoyStatusList: []);
    }

    final list = <BuoyStatusItemModel>[];
    for (final element in raw) {
      if (element is Map) {
        list.add(
          BuoyStatusItemModel.fromJson(Map<String, dynamic>.from(element)),
        );
      }
    }

    return GetAllBuoysStatusResult(buoyStatusList: list);
  }

  @override
  List<Object> get props => [buoyStatusList];
}

class BuoyStatusItemModel extends Equatable {
  const BuoyStatusItemModel({
    required this.buoyId,
    required this.status,
    required this.lastReceived,
    required this.batteryVoltage,
    required this.latitude,
    required this.longitude,
    required this.signalStrength,
  });

  final String buoyId;
  final String status;
  final String lastReceived;
  final double batteryVoltage;
  final double latitude;
  final double longitude;
  final String signalStrength;

  factory BuoyStatusItemModel.fromJson(Map<String, dynamic> json) {
    return BuoyStatusItemModel(
      buoyId: (json['buoyId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      lastReceived: (json['lastReceived'] ?? '').toString(),
      batteryVoltage: _toDouble(json['batteryVoltage']),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      signalStrength: (json['signalStrength'] ?? '').toString(),
    );
  }

  @override
  List<Object> get props => [
    buoyId,
    status,
    lastReceived,
    batteryVoltage,
    latitude,
    longitude,
    signalStrength,
  ];
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
