import 'dart:convert';

import 'package:drifter_buoy/core/constants/api_endpoints.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_all_buoys_data_overview_view_response.dart';

class GeneralUserBuoysRemoteDataSource {
  const GeneralUserBuoysRemoteDataSource({required ApiService apiService})
    : _apiService = apiService;

  final ApiService _apiService;

  ResultFuture<UserViewBuoyDashboardGetAllBuoysDataOverviewViewResponse>
  getAllBuoysDataOverviewView() {
    return _apiService.get<UserViewBuoyDashboardGetAllBuoysDataOverviewViewResponse>(
      ApiEndpoints.getAllBuoysDataOverviewViewUrl,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return UserViewBuoyDashboardGetAllBuoysDataOverviewViewResponse
                .fromJson(decoded);
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
}
