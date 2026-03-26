import 'package:dartz_plus/dartz_plus.dart';
import 'package:drifter_buoy/core/device/login_device_info_service.dart';
import 'package:drifter_buoy/core/error/failure.dart';
import 'package:drifter_buoy/core/storage/auth_session_store.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_login_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_auth_repository.dart';

class GeneralUserLogin {
  final GeneralUserAuthRepository _repository;
  final LoginDeviceInfoService _deviceInfoService;
  final AuthSessionStore _authSessionStore;

  GeneralUserLogin({
    required GeneralUserAuthRepository repository,
    required LoginDeviceInfoService deviceInfoService,
    required AuthSessionStore authSessionStore,
  })  : _repository = repository,
        _deviceInfoService = deviceInfoService,
        _authSessionStore = authSessionStore;

  ResultFuture<UserAuthenticateLoginResponse> call({
    required String userName,
    required String password,
  }) async {
    try {
      final deviceInfo = await _deviceInfoService.getLoginDeviceInfo();
      final result = await _repository.login(
        userName: userName,
        password: password,
        deviceInfo: deviceInfo,
      );

      return await result.fold(
        (failure) async => Left(failure),
        (response) async {
          await _authSessionStore.saveLoginResponse(response);
          return Right(response);
        },
      );
    } catch (e) {
      return Left(
        UnknownFailure(
          'Failed to collect device info or login. Please try again.',
        ),
      );
    }
  }
}

