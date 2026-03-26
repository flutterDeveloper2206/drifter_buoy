import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_request_verification_code_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_auth_repository.dart';

class GeneralUserRequestVerificationCode {
  final GeneralUserAuthRepository _repository;

  GeneralUserRequestVerificationCode(this._repository);

  ResultFuture<UserAuthenticateRequestVerificationCodeResponse> call({
    required String emailAddress,
  }) {
    return _repository.requestVerificationCode(emailAddress: emailAddress);
  }
}

