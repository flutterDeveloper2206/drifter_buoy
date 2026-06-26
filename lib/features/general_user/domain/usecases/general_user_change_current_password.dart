import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_change_current_password_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_profile_repository.dart';

class GeneralUserChangeCurrentPassword {
  const GeneralUserChangeCurrentPassword({
    required GeneralUserProfileRepository repository,
  }) : _repository = repository;

  final GeneralUserProfileRepository _repository;

  ResultFuture<UserAuthenticateChangeCurrentPasswordResponse> call({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _repository.changeCurrentPassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
