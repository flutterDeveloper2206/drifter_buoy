import 'package:dartz_plus/dartz_plus.dart';
import 'package:drifter_buoy/core/storage/auth_session_store.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_verify_verification_code_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_auth_repository.dart';

class GeneralUserVerifyVerificationCode {
  final GeneralUserAuthRepository _repository;
  final AuthSessionStore _authSessionStore;

  GeneralUserVerifyVerificationCode({
    required GeneralUserAuthRepository repository,
    required AuthSessionStore authSessionStore,
  })  : _repository = repository,
        _authSessionStore = authSessionStore;

  ResultFuture<UserAuthenticateVerifyVerificationCodeResponse> call({
    required String emailAddress,
    required String verificationCode,
  }) async {
    final result = await _repository.verifyVerificationCode(
      emailAddress: emailAddress,
      verificationCode: verificationCode,
    );

    return await result.fold(
      (failure) async => Left(failure),
      (response) async {
        await _authSessionStore.saveResetToken(
          response.result.resetToken,
        );
        return Right(response);
      },
    );
  }
}

