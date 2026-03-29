import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_buoy_data_overview_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_buoys_repository.dart';

class GeneralUserGetBuoyDataOverview {
  GeneralUserGetBuoyDataOverview({required GeneralUserBuoysRepository repository})
    : _repository = repository;

  final GeneralUserBuoysRepository _repository;

  ResultFuture<UserViewBuoyDashboardGetBuoyDataOverviewResponse> call(
    String buoyId,
  ) {
    return _repository.getBuoyDataOverview(buoyId.trim());
  }
}
