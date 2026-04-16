import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/device_token_register_response.dart';

abstract class GeneralUserDeviceTokenRepository {
  ResultFuture<DeviceTokenRegisterResponse> registerDeviceToken({
    required String deviceToken,
    required String platform,
  });
}
