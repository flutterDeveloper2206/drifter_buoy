import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_all_buoys_data_overview_view_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_all_buoys_status_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_buoy_data_overview_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_buoy_metrics_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_buoy_trajectory_view_response.dart';

abstract class GeneralUserBuoysRepository {
  ResultFuture<UserViewBuoyDashboardGetAllBuoysStatusResponse>
  getAllBuoysStatus();

  ResultFuture<UserViewBuoyDashboardGetAllBuoysDataOverviewViewResponse>
  getAllBuoysDataOverviewView();

  ResultFuture<UserViewBuoyDashboardGetBuoyDataOverviewResponse>
  getBuoyDataOverview(String buoyId);

  ResultFuture<UserViewBuoyDashboardGetBuoyMetricsResponse> getBuoyMetrics({
    required String buoyId,
    required String fromDate,
    required String toDate,
    required int hourlyData,
  });

  ResultFuture<UserViewBuoyDashboardGetBuoyTrajectoryViewResponse>
  getBuoyTrajectoryView({
    required String buoyId,
    required String fromDate,
    required String toDate,
    required int intervalMinutes,
  });
}
