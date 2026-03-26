import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_profile_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/models/admin_user_update_user_profile_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_profile_repository.dart';

class GeneralUserProfileRepositoryImpl implements GeneralUserProfileRepository {
  GeneralUserProfileRepositoryImpl({
    required GeneralUserProfileRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final GeneralUserProfileRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<AdminUserUpdateUserProfileResponse> updateUserProfile({
    required String userId,
    required String firstName,
    required String middleName,
    required String lastName,
    required String mobileNumber,
    required String emailAddress,
  }) {
    return _remoteDataSource.updateUserProfile(
      userId: userId,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      mobileNumber: mobileNumber,
      emailAddress: emailAddress,
    );
  }
}

