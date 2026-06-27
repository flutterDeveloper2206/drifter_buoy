import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drifter_buoy/core/constants/api_endpoints.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_report_get_buoy_distance_report_for_export_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_report_search_by_lat_lon_response.dart';
import 'package:drifter_buoy/features/general_user/data/utils/general_user_buoy_id_for_api.dart';

class GeneralUserReportRemoteDataSource {
  const GeneralUserReportRemoteDataSource({required ApiService apiService})
    : _apiService = apiService;

  final ApiService _apiService;

  ResultFuture<UserReportGetBuoyDistanceReportForExportResponse>
  getBuoyDistanceReportForExport({
    required String buoyId,
    required String fromDate,
    required String toDate,
    String? startTime,
    String? startLatitude,
    String? startLongitude,
  }) {
    final id = normalizeBuoyIdForGeneralUserApi(buoyId);
    final formMap = <String, dynamic>{
      'buoyId': id,
      'fromDate': fromDate,
      'toDate': toDate,
    };
    if (startTime != null && startTime.trim().isNotEmpty) {
      formMap['startTime'] = startTime.trim();
    }
    if (startLatitude != null && startLatitude.trim().isNotEmpty) {
      formMap['startLatitude'] = startLatitude.trim();
    }
    if (startLongitude != null && startLongitude.trim().isNotEmpty) {
      formMap['startLongitude'] = startLongitude.trim();
    }
    final form = FormData.fromMap(formMap);

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

  ResultFuture<UserReportGetBuoyDistanceReportForExportResponse>
  getBuoyDataReportForExport({
    required String buoyIdsCsv,
    required String fromDate,
    required String toDate,
    String? startTime,
    String? startLatitude,
    String? startLongitude,
  }) {
    final formMap = <String, dynamic>{
      'BuoyIds': buoyIdsCsv,
      'FromDate': fromDate,
      'ToDate': toDate,
    };
    if (startTime != null && startTime.trim().isNotEmpty) {
      formMap['startTime'] = startTime.trim();
    }
    if (startLatitude != null && startLatitude.trim().isNotEmpty) {
      formMap['startLatitude'] = startLatitude.trim();
    }
    if (startLongitude != null && startLongitude.trim().isNotEmpty) {
      formMap['startLongitude'] = startLongitude.trim();
    }
    final form = FormData.fromMap(formMap);

    return _apiService.post<UserReportGetBuoyDistanceReportForExportResponse>(
      ApiEndpoints.getBuoyDataReportForExportUrl,
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
          throw Exception('Invalid buoy data report for export response format');
        }

        return UserReportGetBuoyDistanceReportForExportResponse.fromJson(data);
      },
    );
  }

  ResultFuture<UserReportSearchByLatLonResponse> searchByLatLon({
    required String buoyId,
    required String fromDate,
    required String toDate,
    required String latLng,
  }) {
    final id = normalizeBuoyIdForGeneralUserApi(buoyId);
    final form = FormData.fromMap({
      'buoyId': id,
      'fromDate': fromDate.trim(),
      'toDate': toDate.trim(),
      'latLng': latLng.trim(),
    });

    return _apiService.post<UserReportSearchByLatLonResponse>(
      ApiEndpoints.searchByLatLonUrl,
      data: form,
      requireApiSuccess: false,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return UserReportSearchByLatLonResponse.fromJson(decoded);
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid search by lat/lon response format');
        }

        return UserReportSearchByLatLonResponse.fromJson(data);
      },
    );
  }
}
