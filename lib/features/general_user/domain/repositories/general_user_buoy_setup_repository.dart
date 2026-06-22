import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/create_new_drifter_buoy_response.dart';

abstract class GeneralUserBuoySetupRepository {
  ResultFuture<CreateNewDrifterBuoyResponse> createNewDrifterBuoy({
    required String stationId,
    required String stationName,
    required String transmissionInterval,
    required String transmissionStartTime,
  });
}
