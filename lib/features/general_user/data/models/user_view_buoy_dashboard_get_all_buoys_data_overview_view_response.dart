import 'package:equatable/equatable.dart';

class UserViewBuoyDashboardGetAllBuoysDataOverviewViewResponse
    extends Equatable {
  final int statusCode;
  final String message;
  final List<BuoysOverviewResultModel> result;
  final bool isSuccess;

  const UserViewBuoyDashboardGetAllBuoysDataOverviewViewResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  factory UserViewBuoyDashboardGetAllBuoysDataOverviewViewResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawResult = json['result'];
    final parsedResult = rawResult is List
        ? rawResult
              .whereType<Map<String, dynamic>>()
              .map(BuoysOverviewResultModel.fromJson)
              .toList(growable: false)
        : const <BuoysOverviewResultModel>[];

    return UserViewBuoyDashboardGetAllBuoysDataOverviewViewResponse(
      statusCode: _toInt(json['statusCode']),
      message: (json['message'] ?? '').toString(),
      result: parsedResult,
      isSuccess: json['isSuccess'] == true,
    );
  }

  @override
  List<Object> get props => [statusCode, message, result, isSuccess];
}

class BuoysOverviewResultModel extends Equatable {
  final BuoysOverviewSummaryModel summary;
  final List<BuoyOverviewListItemModel> buoyList;

  const BuoysOverviewResultModel({
    required this.summary,
    required this.buoyList,
  });

  factory BuoysOverviewResultModel.fromJson(Map<String, dynamic> json) {
    final rawBuoys = json['buoyList'];
    final parsedBuoys = rawBuoys is List
        ? rawBuoys
              .whereType<Map<String, dynamic>>()
              .map(BuoyOverviewListItemModel.fromJson)
              .toList(growable: false)
        : const <BuoyOverviewListItemModel>[];

    return BuoysOverviewResultModel(
      summary: BuoysOverviewSummaryModel.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? const {},
      ),
      buoyList: parsedBuoys,
    );
  }

  @override
  List<Object> get props => [summary, buoyList];
}

class BuoysOverviewSummaryModel extends Equatable {
  final int totalBuoys;
  final int activeBuoys;
  final int offlineBuoys;
  final int batteryLowBuoys;

  const BuoysOverviewSummaryModel({
    required this.totalBuoys,
    required this.activeBuoys,
    required this.offlineBuoys,
    required this.batteryLowBuoys,
  });

  factory BuoysOverviewSummaryModel.fromJson(Map<String, dynamic> json) {
    return BuoysOverviewSummaryModel(
      totalBuoys: _toInt(json['totalBuoys']),
      activeBuoys: _toInt(json['activeBuoys']),
      offlineBuoys: _toInt(json['offlineBuoys']),
      batteryLowBuoys: _toInt(json['batteryLowBuoys']),
    );
  }

  @override
  List<Object> get props => [totalBuoys, activeBuoys, offlineBuoys, batteryLowBuoys];
}

class BuoyOverviewListItemModel extends Equatable {
  final String buoyId;
  final String status;
  final String lastReceived;
  final double batteryVoltage;
  final double latitude;
  final double longitude;
  final String signalStrength;

  const BuoyOverviewListItemModel({
    required this.buoyId,
    required this.status,
    required this.lastReceived,
    required this.batteryVoltage,
    required this.latitude,
    required this.longitude,
    required this.signalStrength,
  });

  factory BuoyOverviewListItemModel.fromJson(Map<String, dynamic> json) {
    return BuoyOverviewListItemModel(
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
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
