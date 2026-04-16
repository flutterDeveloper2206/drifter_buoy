import 'dart:convert';

import 'package:drifter_buoy/core/constants/api_endpoints.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/device_token_register_response.dart';
import 'package:dio/dio.dart';

class GeneralUserDeviceTokenRemoteDataSource {
  const GeneralUserDeviceTokenRemoteDataSource({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  ResultFuture<DeviceTokenRegisterResponse> registerDeviceToken({
    required String deviceToken,
    required String platform,
  }) {
    final formData = FormData.fromMap({
      'deviceToken': deviceToken,
      'platform': platform,
    });

    return _apiService.post<DeviceTokenRegisterResponse>(
      ApiEndpoints.registerDeviceTokenUrl,
      data: formData,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return DeviceTokenRegisterResponse.fromJson(decoded);
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid device token register response format');
        }

        return DeviceTokenRegisterResponse.fromJson(data);
      },
    );
  }
}
