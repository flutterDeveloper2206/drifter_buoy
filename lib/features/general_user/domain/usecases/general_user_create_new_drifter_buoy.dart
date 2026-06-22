import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/create_new_drifter_buoy_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_buoys_repository.dart';

class GeneralUserCreateNewDrifterBuoy {
  const GeneralUserCreateNewDrifterBuoy({required GeneralUserBuoysRepository repository})
      : _repository = repository;

  final GeneralUserBuoysRepository _repository;

  ResultFuture<CreateNewDrifterBuoyResponse> call({
    required String stationId,
    required String stationName,
    required String transmissionInterval,
    required String transmissionStartTime,
  }) {
    return _repository.createNewDrifterBuoy(
      stationId: stationId,
      stationName: stationName,
      transmissionInterval: transmissionInterval,
      transmissionStartTime: transmissionStartTime,
    );
  }
}
