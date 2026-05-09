import 'dart:convert';

import 'package:drifter_buoy/core/constants/api_endpoints.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/drifter_buoy_command_model.dart';

class GeneralUserSelfTestRemoteDataSource {
  const GeneralUserSelfTestRemoteDataSource({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  ResultFuture<GetAllDrifterBuoyCommandsResponse> getAllDrifterBuoyCommands() {
    return _apiService.post<GetAllDrifterBuoyCommandsResponse>(
      ApiEndpoints.getAllDrifterBuoyCommandsUrl,
      data: const <String, dynamic>{},
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return GetAllDrifterBuoyCommandsResponse.fromJson(decoded);
          }
        }
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid GetAllDrifterBuoyCommands response');
        }
        return GetAllDrifterBuoyCommandsResponse.fromJson(data);
      },
    );
  }
}
