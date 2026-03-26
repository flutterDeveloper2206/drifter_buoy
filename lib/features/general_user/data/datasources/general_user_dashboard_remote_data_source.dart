import 'dart:convert';

import 'package:drifter_buoy/core/constants/api_endpoints.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_map_dashboard_get_buoy_dashboard_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_map_dashboard_get_buoy_map_dashboard_response.dart';

class GeneralUserDashboardRemoteDataSource {
  const GeneralUserDashboardRemoteDataSource({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  ResultFuture<UserMapDashboardGetBuoyDashboardResponse> getBuoyDashboard() {
    return _apiService.get<UserMapDashboardGetBuoyDashboardResponse>(
      ApiEndpoints.getBuoyDashboardUrl,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return UserMapDashboardGetBuoyDashboardResponse.fromJson(decoded);
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid get buoy dashboard response format');
        }

        return UserMapDashboardGetBuoyDashboardResponse.fromJson(data);
      },
    );
  }

  ResultFuture<UserMapDashboardGetBuoyMapDashboardResponse>
      getBuoyMapDashboard() {
    return _apiService.get<UserMapDashboardGetBuoyMapDashboardResponse>(
      ApiEndpoints.getBuoyMapDashboardUrl,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return UserMapDashboardGetBuoyMapDashboardResponse.fromJson(
              decoded,
            );
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid get buoy map dashboard response format');
        }

        return UserMapDashboardGetBuoyMapDashboardResponse.fromJson(data);
      },
    );
  }
}

