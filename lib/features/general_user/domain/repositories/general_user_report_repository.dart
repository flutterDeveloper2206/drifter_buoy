import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_report_get_buoy_distance_report_for_export_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_report_search_by_lat_lon_response.dart';

abstract class GeneralUserReportRepository {
  ResultFuture<UserReportGetBuoyDistanceReportForExportResponse>
  getBuoyDistanceReportForExport({
    required String buoyId,
    required String fromDate,
    required String toDate,
    String? startTime,
    String? startLatitude,
    String? startLongitude,
  });

  ResultFuture<UserReportGetBuoyDistanceReportForExportResponse>
  getBuoyDataReportForExport({
    required String buoyIdsCsv,
    required String fromDate,
    required String toDate,
    String? startTime,
    String? startLatitude,
    String? startLongitude,
  });

  ResultFuture<UserReportSearchByLatLonResponse> searchByLatLon({
    required String buoyId,
    required String fromDate,
    required String toDate,
    required String latLng,
  });
}
