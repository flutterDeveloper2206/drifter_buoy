import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_report_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_report_get_buoy_distance_report_for_export_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_report_repository.dart';

class GeneralUserReportRepositoryImpl implements GeneralUserReportRepository {
  GeneralUserReportRepositoryImpl({
    required GeneralUserReportRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final GeneralUserReportRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<UserReportGetBuoyDistanceReportForExportResponse>
  getBuoyDistanceReportForExport({
    required String buoyId,
    required String fromDate,
    required String toDate,
  }) {
    return _remoteDataSource.getBuoyDistanceReportForExport(
      buoyId: buoyId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
