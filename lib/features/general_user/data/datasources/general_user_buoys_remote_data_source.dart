import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drifter_buoy/core/constants/api_endpoints.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_all_buoys_data_overview_view_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_all_buoys_status_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_buoy_data_overview_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_buoy_metrics_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_buoy_trajectory_view_response.dart';
import 'package:drifter_buoy/features/general_user/data/utils/general_user_buoy_id_for_api.dart';

class GeneralUserBuoysRemoteDataSource {
  const GeneralUserBuoysRemoteDataSource({required ApiService apiService})
    : _apiService = apiService;

  final ApiService _apiService;

  ResultFuture<UserViewBuoyDashboardGetAllBuoysStatusResponse>
  getAllBuoysStatus() {
    return _apiService.get<UserViewBuoyDashboardGetAllBuoysStatusResponse>(
      ApiEndpoints.getAllBuoysStatusUrl,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return UserViewBuoyDashboardGetAllBuoysStatusResponse.fromJson(
              decoded,
            );
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid get all buoys status response format');
        }

        return UserViewBuoyDashboardGetAllBuoysStatusResponse.fromJson(data);
      },
    );
  }

  ResultFuture<UserViewBuoyDashboardGetAllBuoysDataOverviewViewResponse>
  getAllBuoysDataOverviewView() {
    return _apiService.get<
      UserViewBuoyDashboardGetAllBuoysDataOverviewViewResponse
    >(
      ApiEndpoints.getAllBuoysDataOverviewViewUrl,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return UserViewBuoyDashboardGetAllBuoysDataOverviewViewResponse.fromJson(
              decoded,
            );
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid get all buoys overview response format');
        }

        return UserViewBuoyDashboardGetAllBuoysDataOverviewViewResponse.fromJson(
          data,
        );
      },
    );
  }

  ResultFuture<UserViewBuoyDashboardGetBuoyDataOverviewResponse>
  getBuoyDataOverview(String buoyId) {
    final id = normalizeBuoyIdForGeneralUserApi(buoyId);
    final form = FormData.fromMap(<String, dynamic>{'buoyId': id});

    return _apiService.post<UserViewBuoyDashboardGetBuoyDataOverviewResponse>(
      ApiEndpoints.getBuoyDataOverviewUrl,
      data: form,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return UserViewBuoyDashboardGetBuoyDataOverviewResponse.fromJson(
              decoded,
            );
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid get buoy data overview response format');
        }

        return UserViewBuoyDashboardGetBuoyDataOverviewResponse.fromJson(data);
      },
    );
  }

  ResultFuture<UserViewBuoyDashboardGetBuoyMetricsResponse> getBuoyMetrics({
    required String buoyId,
    required String fromDate,
    required String toDate,
  }) {
    final id = normalizeBuoyIdForGeneralUserApi(buoyId);
    final form = FormData.fromMap(<String, dynamic>{
      'BuoyId': id,
      'FromDate': fromDate.trim(),
      'ToDate': toDate.trim(),
    });

    return _apiService.post<UserViewBuoyDashboardGetBuoyMetricsResponse>(
      ApiEndpoints.getBuoyMetricsUrl,
      data: form,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return UserViewBuoyDashboardGetBuoyMetricsResponse.fromJson(
              decoded,
            );
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid get buoy metrics response format');
        }

        return UserViewBuoyDashboardGetBuoyMetricsResponse.fromJson(data);
      },
    );
  }

  ResultFuture<UserViewBuoyDashboardGetBuoyTrajectoryViewResponse>
  getBuoyTrajectoryView({
    required String buoyId,
    required String fromDate,
    required String toDate,
  }) {
    final id = buoyIdForTrajectoryApi(buoyId);
    final form = FormData.fromMap(<String, dynamic>{
      'buoyId': id,
      'fromDate': fromDate.trim(),
      'toDate': toDate.trim(),
    });

    return _apiService.post<UserViewBuoyDashboardGetBuoyTrajectoryViewResponse>(
      ApiEndpoints.getBuoyTrajectoryViewUrl,
      data: form,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return UserViewBuoyDashboardGetBuoyTrajectoryViewResponse.fromJson(
              decoded,
            );
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid get buoy trajectory response format');
        }

        return UserViewBuoyDashboardGetBuoyTrajectoryViewResponse.fromJson(
          data,
        );
      },
    );
  }
}
