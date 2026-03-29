import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drifter_buoy/core/constants/api_endpoints.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_report_get_buoy_distance_report_for_export_response.dart';

class GeneralUserReportRemoteDataSource {
  const GeneralUserReportRemoteDataSource({required ApiService apiService})
    : _apiService = apiService;

  final ApiService _apiService;

  ResultFuture<UserReportGetBuoyDistanceReportForExportResponse>
  getBuoyDistanceReportForExport({
    required String buoyId,
    required String fromDate,
    required String toDate,
  }) {
    final form = FormData.fromMap(<String, dynamic>{
      'buoyId': buoyId.trim(),
      'fromDate': fromDate,
      'toDate': toDate,
    });

    return _apiService.post<UserReportGetBuoyDistanceReportForExportResponse>(
      ApiEndpoints.getBuoyDistanceReportForExportUrl,
      data: form,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return UserReportGetBuoyDistanceReportForExportResponse.fromJson(
              decoded,
            );
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid buoy distance report response format');
        }

        return UserReportGetBuoyDistanceReportForExportResponse.fromJson(data);
      },
    );
  }
}
