import 'package:equatable/equatable.dart';

enum GeneralUserAlertsStatus { initial, loading, loaded, error }

class GeneralUserAlertItem extends Equatable {
  final String title;
  final String message;
  final String timeLabel;
  final bool isUnread;
  final String notificationType;
  final String priorityLevel;
  final String createdBy;

  const GeneralUserAlertItem({
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.isUnread,
    required this.notificationType,
    required this.priorityLevel,
    required this.createdBy,
  });

  @override
  List<Object> get props => [
        title,
        message,
        timeLabel,
        isUnread,
        notificationType,
        priorityLevel,
        createdBy,
      ];
}

class GeneralUserAlertsState extends Equatable {
  final GeneralUserAlertsStatus status;
  final List<GeneralUserAlertItem> alerts;
  final String message;
  final bool isRefreshing;

  const GeneralUserAlertsState({
    required this.status,
    required this.alerts,
    required this.message,
    required this.isRefreshing,
  });

  const GeneralUserAlertsState.initial()
    : status = GeneralUserAlertsStatus.initial,
      alerts = const [],
      message = '',
      isRefreshing = false;

  int get unreadCount => alerts.where((alert) => alert.isUnread).length;

  GeneralUserAlertsState copyWith({
    GeneralUserAlertsStatus? status,
    List<GeneralUserAlertItem>? alerts,
    String? message,
    bool? isRefreshing,
  }) {
    return GeneralUserAlertsState(
      status: status ?? this.status,
      alerts: alerts ?? this.alerts,
      message: message ?? this.message,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object> get props => [status, alerts, message, isRefreshing];
}
