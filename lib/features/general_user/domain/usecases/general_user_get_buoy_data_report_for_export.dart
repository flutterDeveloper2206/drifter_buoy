import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_report_get_buoy_distance_report_for_export_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_report_repository.dart';

class GeneralUserGetBuoyDataReportForExport {
  GeneralUserGetBuoyDataReportForExport({
    required GeneralUserReportRepository repository,
  }) : _repository = repository;

  final GeneralUserReportRepository _repository;

  ResultFuture<UserReportGetBuoyDistanceReportForExportResponse> call({
    required String buoyIdsCsv,
    required String fromDate,
    required String toDate,
  }) {
    return _repository.getBuoyDataReportForExport(
      buoyIdsCsv: buoyIdsCsv.trim(),
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
