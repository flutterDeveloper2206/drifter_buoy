import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_notifications_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/models/get_all_notifications_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_notifications_repository.dart';

class GeneralUserNotificationsRepositoryImpl
    implements GeneralUserNotificationsRepository {
  const GeneralUserNotificationsRepositoryImpl({
    required GeneralUserNotificationsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final GeneralUserNotificationsRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<GetAllNotificationsResponse> getAllNotifications() {
    return _remoteDataSource.getAllNotifications();
  }
}
