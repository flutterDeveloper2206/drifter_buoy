import 'package:dartz_plus/dartz_plus.dart';
import 'package:drifter_buoy/core/error/failure.dart';
import 'package:drifter_buoy/core/storage/auth_session_store.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_reset_password_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_auth_repository.dart';

class GeneralUserResetPassword {
  final GeneralUserAuthRepository _repository;
  final AuthSessionStore _authSessionStore;

  GeneralUserResetPassword({
    required GeneralUserAuthRepository repository,
    required AuthSessionStore authSessionStore,
  })  : _repository = repository,
        _authSessionStore = authSessionStore;

  ResultFuture<UserAuthenticateResetPasswordResponse> call({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final resetToken = await _authSessionStore.getResetToken();
    if (resetToken == null || resetToken.trim().isEmpty) {
      return Left(
        UnknownFailure(
          'Reset token not found. Please request a new verification code.',
        ),
      );
    }

    return _repository.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}

