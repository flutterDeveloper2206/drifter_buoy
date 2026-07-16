import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drifter_buoy/core/constants/api_endpoints.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/create_new_drifter_buoy_response.dart';

class GeneralUserBuoySetupRemoteDataSource {
  const GeneralUserBuoySetupRemoteDataSource({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  ResultFuture<CreateNewDrifterBuoyResponse> createNewDrifterBuoy({
    required String stationId,
    required String stationName,
    required String transmissionInterval,
    required String transmissionStartTime,
  }) {
    final formData = FormData.fromMap({
      'buoyId': stationId.trim().toUpperCase(),
      'buoyName': stationName.trim(),
      // 'TransmissionInterval': transmissionInterval.trim(),
      // 'TransmissionStartTime': transmissionStartTime.trim(),
    });

    return _apiService.post<CreateNewDrifterBuoyResponse>(
      ApiEndpoints.createNewDrifterBuoyUrl,
      data: formData,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return CreateNewDrifterBuoyResponse.fromJson(decoded);
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid create buoy response format');
        }

        return CreateNewDrifterBuoyResponse.fromJson(data);
      },
    );
  }
}
