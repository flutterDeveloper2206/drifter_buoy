import 'package:equatable/equatable.dart';

class UserMapDashboardGetBuoyDashboardSummary
    extends Equatable {
  final int totalBuoys;
  final int activeBuoys;
  final int offlineBuoys;
  final int batteryLowBuoys;

  const UserMapDashboardGetBuoyDashboardSummary({
    required this.totalBuoys,
    required this.activeBuoys,
    required this.offlineBuoys,
    required this.batteryLowBuoys,
  });

  factory UserMapDashboardGetBuoyDashboardSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    final activeVal = json['activeBuoys'] ?? json['onlineBuoys'];
    return UserMapDashboardGetBuoyDashboardSummary(
      totalBuoys: _toInt(json['totalBuoys']),
      activeBuoys: _toInt(activeVal),
      offlineBuoys: _toInt(json['offlineBuoys']),
      batteryLowBuoys: _toInt(json['batteryLowBuoys']),
    );
  }

  @override
  List<Object?> get props =>
      [totalBuoys, activeBuoys, offlineBuoys, batteryLowBuoys];
}

class UserMapDashboardGetBuoyDashboardLocation extends Equatable {
  final String buoyId;
  final double latitude;
  final double longitude;

  const UserMapDashboardGetBuoyDashboardLocation({
    required this.buoyId,
    required this.latitude,
    required this.longitude,
  });

  factory UserMapDashboardGetBuoyDashboardLocation.fromJson(
    Map<String, dynamic> json,
  ) {
    final lat = (json['latitude'] ?? 0);
    final lng = (json['longitude'] ?? 0);

    return UserMapDashboardGetBuoyDashboardLocation(
      buoyId: (json['buoyId'] ?? '').toString(),
      latitude: lat is num ? lat.toDouble() : double.tryParse(lat.toString()) ?? 0,
      longitude:
          lng is num ? lng.toDouble() : double.tryParse(lng.toString()) ?? 0,
    );
  }

  @override
  List<Object?> get props => [buoyId, latitude, longitude];
}

class UserMapDashboardGetBuoyDashboardResult extends Equatable {
  final UserMapDashboardGetBuoyDashboardSummary summary;
  final List<UserMapDashboardGetBuoyDashboardLocation> buoyLocations;

  const UserMapDashboardGetBuoyDashboardResult({
    required this.summary,
    required this.buoyLocations,
  });

  factory UserMapDashboardGetBuoyDashboardResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserMapDashboardGetBuoyDashboardResult(
      summary: UserMapDashboardGetBuoyDashboardSummary.fromJson(
        (json['summary'] as Map<String, dynamic>? ?? const {}),
      ),
      buoyLocations: (json['buoyLocations'] as List<dynamic>? ?? const [])
          .map(
            (e) => UserMapDashboardGetBuoyDashboardLocation.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [summary, buoyLocations];
}

class UserMapDashboardGetBuoyDashboardResponse extends Equatable {
  final int statusCode;
  final String message;
  final UserMapDashboardGetBuoyDashboardResult result;
  final bool isSuccess;

  const UserMapDashboardGetBuoyDashboardResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  factory UserMapDashboardGetBuoyDashboardResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserMapDashboardGetBuoyDashboardResponse(
      statusCode: _toInt(json['statusCode']),
      message: (json['message'] ?? '').toString(),
      isSuccess: (json['isSuccess'] ?? false) as bool,
      result: UserMapDashboardGetBuoyDashboardResult.fromJson(
        (json['result'] as Map<String, dynamic>? ?? const {}),
      ),
    );
  }

  @override
  List<Object?> get props => [statusCode, message, result, isSuccess];
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

