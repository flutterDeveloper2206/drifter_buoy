import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/alerts/general_user_alerts_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/alerts/general_user_alerts_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserAlertsBloc
    extends Bloc<GeneralUserAlertsEvent, GeneralUserAlertsState> {
  GeneralUserAlertsBloc() : super(const GeneralUserAlertsState.initial()) {
    on<LoadGeneralUserAlerts>(_onLoadGeneralUserAlerts);
  }

  Future<void> _onLoadGeneralUserAlerts(
    LoadGeneralUserAlerts event,
    Emitter<GeneralUserAlertsState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserAlerts event triggered');
    emit(
      state.copyWith(status: GeneralUserAlertsStatus.loading, message: ''),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      emit(
        state.copyWith(
          status: GeneralUserAlertsStatus.loaded,
          alerts: _dummyAlerts(),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: GeneralUserAlertsStatus.error,
          message: 'Unable to load alerts. Please try again.',
        ),
      );
    }
  }

  List<GeneralUserAlertItem> _dummyAlerts() {
    return const [
      GeneralUserAlertItem(
        title: 'Low Battery Level',
        message: 'Battery level dropped to 18%. Expected shutdown in 1 hour.',
        timeLabel: '27 Oct 2025, 09:50 AM',
        isUnread: true,
      ),
      GeneralUserAlertItem(
        title: 'Signal Weak',
        message: 'GPRS signal dropped below threshold for DB - 03.',
        timeLabel: '27 Oct 2025, 09:20 AM',
        isUnread: true,
      ),
      GeneralUserAlertItem(
        title: 'Offline Detected',
        message: 'DB - 09 has gone offline unexpectedly.',
        timeLabel: '27 Oct 2025, 08:58 AM',
        isUnread: true,
      ),
      GeneralUserAlertItem(
        title: 'Battery Restored',
        message: 'Battery level recovered above 35% for DB - 04.',
        timeLabel: '26 Oct 2025, 07:30 PM',
        isUnread: true,
      ),
      GeneralUserAlertItem(
        title: 'Connectivity Restored',
        message: 'DB - 09 connection re-established.',
        timeLabel: '26 Oct 2025, 05:20 PM',
        isUnread: true,
      ),
      GeneralUserAlertItem(
        title: 'Firmware Update',
        message: 'New firmware package available for selected buoys.',
        timeLabel: '26 Oct 2025, 03:04 PM',
        isUnread: true,
      ),
      GeneralUserAlertItem(
        title: 'Zone Alert',
        message: 'DB - 02 moved outside configured zone boundary.',
        timeLabel: '26 Oct 2025, 01:44 PM',
        isUnread: true,
      ),
      GeneralUserAlertItem(
        title: 'GPS Drift',
        message: 'GPS jitter detected for DB - 01 trajectory.',
        timeLabel: '26 Oct 2025, 11:02 AM',
        isUnread: true,
      ),
    ];
  }
}
