import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/create_new_drifter_buoy_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_buoy_setup_repository.dart';

class GeneralUserCreateNewDrifterBuoy {
  GeneralUserCreateNewDrifterBuoy({
    required GeneralUserBuoySetupRepository repository,
  }) : _repository = repository;

  final GeneralUserBuoySetupRepository _repository;

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
