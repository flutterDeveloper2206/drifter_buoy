import 'package:equatable/equatable.dart';

enum GeneralUserAlertsStatus { initial, loading, loaded, error }

class GeneralUserAlertItem extends Equatable {
  final String title;
  final String message;
  final String timeLabel;
  final bool isUnread;

  const GeneralUserAlertItem({
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.isUnread,
  });

  @override
  List<Object> get props => [title, message, timeLabel, isUnread];
}

class GeneralUserAlertsState extends Equatable {
  final GeneralUserAlertsStatus status;
  final List<GeneralUserAlertItem> alerts;
  final String message;

  const GeneralUserAlertsState({
    required this.status,
    required this.alerts,
    required this.message,
  });

  const GeneralUserAlertsState.initial()
    : status = GeneralUserAlertsStatus.initial,
      alerts = const [],
      message = '';

  int get unreadCount => alerts.where((alert) => alert.isUnread).length;

  GeneralUserAlertsState copyWith({
    GeneralUserAlertsStatus? status,
    List<GeneralUserAlertItem>? alerts,
    String? message,
  }) {
    return GeneralUserAlertsState(
      status: status ?? this.status,
      alerts: alerts ?? this.alerts,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [status, alerts, message];
}
