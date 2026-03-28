import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_export_selection_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_report_get_all_buoys_status_for_export_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_export_selection_repository.dart';

class GeneralUserExportSelectionRepositoryImpl
    implements GeneralUserExportSelectionRepository {
  GeneralUserExportSelectionRepositoryImpl({
    required GeneralUserExportSelectionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final GeneralUserExportSelectionRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<UserReportGetAllBuoysStatusForExportResponse>
  getAllBuoysStatusForExport() {
    return _remoteDataSource.getAllBuoysStatusForExport();
  }
}
