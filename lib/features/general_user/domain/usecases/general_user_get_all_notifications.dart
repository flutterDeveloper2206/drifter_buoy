import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/get_all_notifications_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_notifications_repository.dart';

class GeneralUserGetAllNotifications {
  GeneralUserGetAllNotifications({required GeneralUserNotificationsRepository repository})
      : _repository = repository;

  final GeneralUserNotificationsRepository _repository;

  ResultFuture<GetAllNotificationsResponse> call() {
    return _repository.getAllNotifications();
  }
}
