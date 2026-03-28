import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_report_get_all_buoys_status_for_export_response.dart';

abstract class GeneralUserExportSelectionRepository {
  ResultFuture<UserReportGetAllBuoysStatusForExportResponse>
  getAllBuoysStatusForExport();
}
