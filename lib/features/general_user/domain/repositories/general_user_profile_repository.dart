import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/admin_user_update_user_profile_response.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_change_current_password_response.dart';

abstract class GeneralUserProfileRepository {
  ResultFuture<AdminUserUpdateUserProfileResponse> updateUserProfile({
    required String userId,
    required String firstName,
    required String middleName,
    required String lastName,
    required String mobileNumber,
    required String emailAddress,
  });

  ResultFuture<UserAuthenticateChangeCurrentPasswordResponse>
      changeCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}

