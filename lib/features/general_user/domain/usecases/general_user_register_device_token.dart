import 'package:dartz_plus/dartz_plus.dart';
import 'package:drifter_buoy/core/device/push_client_platform.dart';
import 'package:drifter_buoy/core/error/failure.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/device_token_register_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_device_token_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class GeneralUserRegisterDeviceToken {
  GeneralUserRegisterDeviceToken({
    required GeneralUserDeviceTokenRepository repository,
    required FirebaseMessaging messaging,
  })  : _repository = repository,
        _messaging = messaging;

  final GeneralUserDeviceTokenRepository _repository;
  final FirebaseMessaging _messaging;

  ResultFuture<DeviceTokenRegisterResponse> call() async {
    final token = await _messaging.getToken();
    if (token == null || token.trim().isEmpty) {
      return const Left(
        UnknownFailure('FCM token is not available yet.'),
      );
    }

    return _repository.registerDeviceToken(
      deviceToken: token.trim(),
      platform: PushClientPlatform.apiValue(),
    );
  }
}
