import 'package:equatable/equatable.dart';

class UserMapDashboardGetBuoyMapDashboardItem extends Equatable {
  final String id;
  final String buoyId;
  final double latitude;
  final double longitude;
  final String buoyStatus;

  const UserMapDashboardGetBuoyMapDashboardItem({
    required this.id,
    required this.buoyId,
    required this.latitude,
    required this.longitude,
    required this.buoyStatus,
  });

  factory UserMapDashboardGetBuoyMapDashboardItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final lat = json['latitude'];
    final lng = json['longitude'];

    return UserMapDashboardGetBuoyMapDashboardItem(
      id: (json['_id'] ?? '').toString(),
      buoyId: (json['buoyId'] ?? '').toString(),
      latitude: lat is num ? lat.toDouble() : double.tryParse('$lat') ?? 0,
      longitude: lng is num ? lng.toDouble() : double.tryParse('$lng') ?? 0,
      buoyStatus: (json['buoyStatus'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [id, buoyId, latitude, longitude, buoyStatus];
}

class UserMapDashboardGetBuoyMapDashboardResponse extends Equatable {
  final int statusCode;
  final String message;
  final List<UserMapDashboardGetBuoyMapDashboardItem> result;
  final bool isSuccess;

  const UserMapDashboardGetBuoyMapDashboardResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  factory UserMapDashboardGetBuoyMapDashboardResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserMapDashboardGetBuoyMapDashboardResponse(
      statusCode: (json['statusCode'] ?? 0) as int,
      message: (json['message'] ?? '').toString(),
      isSuccess: (json['isSuccess'] ?? false) as bool,
      result: (json['result'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(UserMapDashboardGetBuoyMapDashboardItem.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [statusCode, message, result, isSuccess];
}

