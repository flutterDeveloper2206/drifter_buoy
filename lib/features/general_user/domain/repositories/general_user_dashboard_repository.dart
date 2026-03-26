import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_map_dashboard_get_buoy_dashboard_response.dart';

abstract class GeneralUserDashboardRepository {
  ResultFuture<UserMapDashboardGetBuoyDashboardResponse> getBuoyDashboard();
}

