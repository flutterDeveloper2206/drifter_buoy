import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_map_dashboard_get_buoy_dashboard_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_dashboard_repository.dart';

class GeneralUserGetBuoyDashboard {
  final GeneralUserDashboardRepository _repository;

  GeneralUserGetBuoyDashboard({
    required GeneralUserDashboardRepository repository,
  }) : _repository = repository;

  ResultFuture<UserMapDashboardGetBuoyDashboardResponse> call() {
    return _repository.getBuoyDashboard();
  }
}

