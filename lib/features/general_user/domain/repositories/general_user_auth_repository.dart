import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_login_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_request_verification_code_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_verify_verification_code_response.dart';
import 'package:drifter_buoy/core/device/login_device_info.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';

abstract class GeneralUserAuthRepository {
  ResultFuture<UserAuthenticateLoginResponse> login({
    required String userName,
    required String password,
    required LoginDeviceInfo deviceInfo,
  });

  ResultFuture<UserAuthenticateRequestVerificationCodeResponse>
      requestVerificationCode({
    required String emailAddress,
  });

  ResultFuture<UserAuthenticateVerifyVerificationCodeResponse>
      verifyVerificationCode({
    required String emailAddress,
    required String verificationCode,
  });
}

