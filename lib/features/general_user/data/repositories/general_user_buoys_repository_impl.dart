import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_buoys_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_all_buoys_data_overview_view_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_buoy_data_overview_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_buoys_repository.dart';

class GeneralUserBuoysRepositoryImpl implements GeneralUserBuoysRepository {
  GeneralUserBuoysRepositoryImpl({
    required GeneralUserBuoysRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final GeneralUserBuoysRemoteDataSource _remoteDataSource;

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
}
