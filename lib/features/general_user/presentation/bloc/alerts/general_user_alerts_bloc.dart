import 'package:drifter_buoy/core/constants/app_constants.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/data/models/get_all_notifications_item.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_all_notifications.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/alerts/general_user_alerts_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/alerts/general_user_alerts_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserAlertsBloc
    extends Bloc<GeneralUserAlertsEvent, GeneralUserAlertsState> {
  GeneralUserAlertsBloc({required GeneralUserGetAllNotifications getAllNotifications})
      : _getAllNotifications = getAllNotifications,
        super(const GeneralUserAlertsState.initial()) {
    on<LoadGeneralUserAlerts>(_onLoadGeneralUserAlerts);
  }

  final GeneralUserGetAllNotifications _getAllNotifications;

  Future<void> _onLoadGeneralUserAlerts(
    LoadGeneralUserAlerts event,
    Emitter<GeneralUserAlertsState> emit,
  ) async {
    final pullRefresh = event.isPullToRefresh &&
        state.status == GeneralUserAlertsStatus.loaded;

    if (pullRefresh) {
      emit(state.copyWith(isRefreshing: true, message: ''));
    } else {
      emit(
        state.copyWith(
          status: GeneralUserAlertsStatus.loading,
          message: '',
          isRefreshing: false,
        ),
      );
    }

    final outcome = await _getAllNotifications();
    outcome.fold(
      (failure) {
        final text = failure.message.trim().isNotEmpty
            ? failure.message
            : AppConstants.genericErrorMessage;

        if (pullRefresh) {
          AppLogger.w('Pull-to-refresh notifications failed: $text');
          emit(state.copyWith(isRefreshing: false));
          return;
        }

        emit(
          state.copyWith(
            status: GeneralUserAlertsStatus.error,
            message: text,
            isRefreshing: false,
          ),
        );
      },
      (response) {
        final alerts = response.result.map(_mapToAlertItem).toList();
        emit(
          state.copyWith(
            status: GeneralUserAlertsStatus.loaded,
            alerts: alerts,
            message: '',
            isRefreshing: false,
          ),
        );
      },
    );
  }

  GeneralUserAlertItem _mapToAlertItem(GetAllNotificationsItem item) {
    final unread = item.status.trim().toLowerCase() == 'unread';
    return GeneralUserAlertItem(
      title: item.notificationTitle,
      message: item.notificationMessage,
      timeLabel: item.createdOn,
      isUnread: unread,
      notificationType: item.notificationType,
      priorityLevel: item.priorityLevel,
      createdBy: item.createdBy,
    );
  }
}
