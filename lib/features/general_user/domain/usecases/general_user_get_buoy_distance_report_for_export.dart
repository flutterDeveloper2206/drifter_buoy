import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_report_get_buoy_distance_report_for_export_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_report_repository.dart';

class GeneralUserGetBuoyDistanceReportForExport {
  GeneralUserGetBuoyDistanceReportForExport({
    required GeneralUserReportRepository repository,
  }) : _repository = repository;

  final GeneralUserReportRepository _repository;

  ResultFuture<UserReportGetBuoyDistanceReportForExportResponse> call({
    required String buoyId,
    required String fromDate,
    required String toDate,
  }) {
    return _repository.getBuoyDistanceReportForExport(
      buoyId: buoyId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
