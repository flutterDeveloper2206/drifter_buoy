import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_report_search_by_lat_lon_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_report_repository.dart';

class GeneralUserSearchByLatLon {
  GeneralUserSearchByLatLon({required GeneralUserReportRepository repository})
      : _repository = repository;

  final GeneralUserReportRepository _repository;

  ResultFuture<UserReportSearchByLatLonResponse> call({
    required String buoyId,
    required String fromDate,
    required String toDate,
    required String latLng,
  }) {
    return _repository.searchByLatLon(
      buoyId: buoyId,
      fromDate: fromDate,
      toDate: toDate,
      latLng: latLng,
    );
  }
}
