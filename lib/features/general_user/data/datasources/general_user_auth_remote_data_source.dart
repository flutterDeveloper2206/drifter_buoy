import 'package:drifter_buoy/core/constants/api_endpoints.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/core/device/login_device_info.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_login_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_request_verification_code_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_verify_verification_code_response.dart';
import 'package:dio/dio.dart';

class GeneralUserAuthRemoteDataSource {
  const GeneralUserAuthRemoteDataSource({required ApiService apiService})
    : _apiService = apiService;

  final ApiService _apiService;

  ResultFuture<UserAuthenticateLoginResponse> login({
    required String userName,
    required String password,
    required LoginDeviceInfo deviceInfo,
  }) {
    // Backend expects `curl --form` => multipart/form-data.
    final formData = FormData.fromMap({
      'userName': userName,
      'password': password,
      'deviceName': deviceInfo.deviceName,
      'deviceType': deviceInfo.deviceType,
      'osName': deviceInfo.osName,
      'osVersion': deviceInfo.osVersion,
      'browserName': deviceInfo.browserName,
      'ipAddress': deviceInfo.ipAddress,
      'location': deviceInfo.location,
    });

    return _apiService.post<UserAuthenticateLoginResponse>(
      ApiEndpoints.loginUrl,
      data: formData,
      parser: (dynamic data) {
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid login response format');
        }
        return UserAuthenticateLoginResponse.fromJson(data);
      },
    );
  }

  ResultFuture<UserAuthenticateRequestVerificationCodeResponse>
  requestVerificationCode({required String emailAddress}) {
    final formData = FormData.fromMap({'emailAddress': emailAddress});

    return _apiService.post<UserAuthenticateRequestVerificationCodeResponse>(
      ApiEndpoints.requestVerificationCodeUrl,
      data: formData,
      parser: (dynamic data) {
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid request verification code response format');
        }
        return UserAuthenticateRequestVerificationCodeResponse.fromJson(data);
      },
    );
  }

  ResultFuture<UserAuthenticateVerifyVerificationCodeResponse>
  verifyVerificationCode({
    required String emailAddress,
    required String verificationCode,
  }) {
    final formData = FormData.fromMap({
      'emailAddress': emailAddress,
      'verificationCode': verificationCode,
    });

    return _apiService.post<UserAuthenticateVerifyVerificationCodeResponse>(
      ApiEndpoints.verifyVerificationCodeUrl,
      data: formData,
      parser: (dynamic data) {
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid verify verification code response format');
        }
        return UserAuthenticateVerifyVerificationCodeResponse.fromJson(data);
      },
    );
  }
}
