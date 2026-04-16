import 'dart:convert';

import 'package:drifter_buoy/core/constants/api_endpoints.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/get_all_notifications_response.dart';

class GeneralUserNotificationsRemoteDataSource {
  const GeneralUserNotificationsRemoteDataSource({
    required ApiService apiService,
  }) : _apiService = apiService;

  final ApiService _apiService;

  ResultFuture<GetAllNotificationsResponse> getAllNotifications() {
    return _apiService.get<GetAllNotificationsResponse>(
      ApiEndpoints.getAllNotificationsUrl,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return GetAllNotificationsResponse.fromJson(decoded);
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid get all notifications response format');
        }

        return GetAllNotificationsResponse.fromJson(data);
      },
    );
  }
}
