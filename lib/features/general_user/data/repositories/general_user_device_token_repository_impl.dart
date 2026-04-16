import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_device_token_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/models/device_token_register_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_device_token_repository.dart';

class GeneralUserDeviceTokenRepositoryImpl
    implements GeneralUserDeviceTokenRepository {
  const GeneralUserDeviceTokenRepositoryImpl({
    required GeneralUserDeviceTokenRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final GeneralUserDeviceTokenRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<DeviceTokenRegisterResponse> registerDeviceToken({
    required String deviceToken,
    required String platform,
  }) {
    return _remoteDataSource.registerDeviceToken(
      deviceToken: deviceToken,
      platform: platform,
    );
  }
}
