import 'package:drifter_buoy/features/general_user/data/datasources/general_user_dashboard_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_map_dashboard_get_buoy_dashboard_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_dashboard_repository.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';

class GeneralUserDashboardRepositoryImpl
    implements GeneralUserDashboardRepository {
  GeneralUserDashboardRepositoryImpl({
    required GeneralUserDashboardRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final GeneralUserDashboardRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<UserMapDashboardGetBuoyDashboardResponse> getBuoyDashboard() {
    return _remoteDataSource.getBuoyDashboard();
  }
}

