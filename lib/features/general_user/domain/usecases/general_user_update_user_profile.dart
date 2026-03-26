import 'package:dartz_plus/dartz_plus.dart';
import 'package:drifter_buoy/core/storage/auth_session_store.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/admin_user_update_user_profile_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_login_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_profile_repository.dart';

class GeneralUserUpdateUserProfile {
  final GeneralUserProfileRepository _repository;
  final AuthSessionStore _authSessionStore;

  GeneralUserUpdateUserProfile({
    required GeneralUserProfileRepository repository,
    required AuthSessionStore authSessionStore,
  })  : _repository = repository,
        _authSessionStore = authSessionStore;

  ResultFuture<AdminUserUpdateUserProfileResponse> call({
    required String userId,
    required String firstName,
    required String middleName,
    required String lastName,
    required String mobileNumber,
    required String emailAddress,
  }) async {
    final result = await _repository.updateUserProfile(
      userId: userId,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      mobileNumber: mobileNumber,
      emailAddress: emailAddress,
    );

    return result.fold(
      (failure) => Left(failure),
      (response) async {
        // Keep profile screen data consistent by updating the stored session.
        final loginResponse = await _authSessionStore.getLoginResponse();
        if (loginResponse != null) {
          final old = loginResponse.result;
          final updatedFullName = _formatFullName(
            firstName: firstName,
            middleName: middleName,
            lastName: lastName,
          );

          final updatedResult = UserAuthenticateLoginResult(
            userId: old.userId,
            roleName: old.roleName,
            userCode: old.userCode,
            firstName: firstName,
            middleName: middleName,
            lastName: lastName,
            fullName: updatedFullName,
            userName: old.userName,
            emailAddress: emailAddress,
            mobileNumber: mobileNumber,
            clientCode: old.clientCode,
            token: old.token,
            refreshToken: old.refreshToken,
            dbProvider: old.dbProvider,
            profileDetails: old.profileDetails,
            profileDetailsList: old.profileDetailsList,
            isActive: old.isActive,
          );

          await _authSessionStore.saveLoginResponse(
            UserAuthenticateLoginResponse(
              statusCode: response.statusCode,
              message: response.message,
              result: updatedResult,
              isSuccess: response.isSuccess,
            ),
          );
        }

        return Right(response);
      },
    );
  }

  String _formatFullName({
    required String firstName,
    required String middleName,
    required String lastName,
  }) {
    return '$firstName $middleName $lastName'
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

