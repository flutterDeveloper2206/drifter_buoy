import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_view_buoy_dashboard_get_all_buoys_data_overview_view_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_buoys_repository.dart';

class GeneralUserGetAllBuoysDataOverviewView {
  GeneralUserGetAllBuoysDataOverviewView({
    required GeneralUserBuoysRepository repository,
  }) : _repository = repository;

  final GeneralUserBuoysRepository _repository;

  ResultFuture<UserViewBuoyDashboardGetAllBuoysDataOverviewViewResponse> call() {
    return _repository.getAllBuoysDataOverviewView();
  }
}
