import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_report_get_all_buoys_status_for_export_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_export_selection_repository.dart';

class GeneralUserGetAllBuoysStatusForExport {
  GeneralUserGetAllBuoysStatusForExport({
    required GeneralUserExportSelectionRepository repository,
  }) : _repository = repository;

  final GeneralUserExportSelectionRepository _repository;

  ResultFuture<UserReportGetAllBuoysStatusForExportResponse> call() {
    return _repository.getAllBuoysStatusForExport();
  }
}
