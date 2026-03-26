import 'package:drifter_buoy/features/general_user/data/datasources/general_user_auth_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_auth_repository.dart';
import 'package:drifter_buoy/core/device/login_device_info.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_login_response.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_request_verification_code_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_verify_verification_code_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_reset_password_response.dart';

class GeneralUserAuthRepositoryImpl implements GeneralUserAuthRepository {
  GeneralUserAuthRepositoryImpl({
    required GeneralUserAuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final GeneralUserAuthRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<UserAuthenticateLoginResponse> login({
    required String userName,
    required String password,
    required LoginDeviceInfo deviceInfo,
  }) {
    return _remoteDataSource.login(
      userName: userName,
      password: password,
      deviceInfo: deviceInfo,
    );
  }

  @override
  ResultFuture<UserAuthenticateRequestVerificationCodeResponse>
      requestVerificationCode({
    required String emailAddress,
  }) {
    return _remoteDataSource.requestVerificationCode(
      emailAddress: emailAddress,
    );
  }

  @override
  ResultFuture<UserAuthenticateVerifyVerificationCodeResponse>
      verifyVerificationCode({
    required String emailAddress,
    required String verificationCode,
  }) {
    return _remoteDataSource.verifyVerificationCode(
      emailAddress: emailAddress,
      verificationCode: verificationCode,
    );
  }

  @override
  ResultFuture<UserAuthenticateResetPasswordResponse> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _remoteDataSource.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}

