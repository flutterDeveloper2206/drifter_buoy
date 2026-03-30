import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_buoy_trajectory_view_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_buoys_repository.dart';

class GeneralUserGetBuoyTrajectoryView {
  GeneralUserGetBuoyTrajectoryView({
    required GeneralUserBuoysRepository repository,
  }) : _repository = repository;

  final GeneralUserBuoysRepository _repository;

  ResultFuture<UserViewBuoyDashboardGetBuoyTrajectoryViewResponse> call({
    required String buoyId,
    required String fromDate,
    required String toDate,
  }) {
    return _repository.getBuoyTrajectoryView(
      buoyId: buoyId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
