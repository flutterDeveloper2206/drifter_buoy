import 'dart:convert';

import 'package:drifter_buoy/core/constants/api_endpoints.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_report_get_all_buoys_status_for_export_response.dart';

class GeneralUserExportSelectionRemoteDataSource {
  const GeneralUserExportSelectionRemoteDataSource({
    required ApiService apiService,
  }) : _apiService = apiService;

  final ApiService _apiService;

  ResultFuture<UserReportGetAllBuoysStatusForExportResponse>
  getAllBuoysStatusForExport() {
    return _apiService.get<UserReportGetAllBuoysStatusForExportResponse>(
      ApiEndpoints.getAllBuoysStatusForExportUrl,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return UserReportGetAllBuoysStatusForExportResponse.fromJson(
              decoded,
            );
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception(
            'Invalid get all buoys status for export response format',
          );
        }

        return UserReportGetAllBuoysStatusForExportResponse.fromJson(data);
      },
    );
  }
}
