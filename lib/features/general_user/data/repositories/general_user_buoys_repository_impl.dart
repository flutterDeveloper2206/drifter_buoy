import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_buoys_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_all_buoys_data_overview_view_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_all_buoys_status_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_buoy_data_overview_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_buoy_metrics_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_buoys_repository.dart';

class GeneralUserBuoysRepositoryImpl implements GeneralUserBuoysRepository {
  GeneralUserBuoysRepositoryImpl({
    required GeneralUserBuoysRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final GeneralUserBuoysRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<UserViewBuoyDashboardGetAllBuoysStatusResponse>
  getAllBuoysStatus() {
    return _remoteDataSource.getAllBuoysStatus();
  }

  @override
  ResultFuture<UserViewBuoyDashboardGetAllBuoysDataOverviewViewResponse>
  getAllBuoysDataOverviewView() {
    return _remoteDataSource.getAllBuoysDataOverviewView();
  }

  @override
  ResultFuture<UserViewBuoyDashboardGetBuoyDataOverviewResponse>
  getBuoyDataOverview(String buoyId) {
    return _remoteDataSource.getBuoyDataOverview(buoyId);
  }

  @override
  ResultFuture<UserViewBuoyDashboardGetBuoyMetricsResponse> getBuoyMetrics({
    required String buoyId,
    required String fromDate,
    required String toDate,
  }) {
    return _remoteDataSource.getBuoyMetrics(
      buoyId: buoyId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
