import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/get_all_notifications_response.dart';

abstract class GeneralUserNotificationsRepository {
  ResultFuture<GetAllNotificationsResponse> getAllNotifications();
}
