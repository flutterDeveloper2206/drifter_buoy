import 'package:equatable/equatable.dart';

/// One element of `result` from
/// `/api/admin/Notification/GetAllNotifications`.
class GetAllNotificationsItem extends Equatable {
  final String notificationType;
  final String notificationTitle;
  final String notificationMessage;
  final String status;
  final String priorityLevel;
  final String createdOn;
  final String createdBy;

  const GetAllNotificationsItem({
    required this.notificationType,
    required this.notificationTitle,
    required this.notificationMessage,
    required this.status,
    required this.priorityLevel,
    required this.createdOn,
    required this.createdBy,
  });

  factory GetAllNotificationsItem.fromJson(Map<String, dynamic> json) {
    return GetAllNotificationsItem(
      notificationType: (json['notificationType'] ?? '').toString(),
      notificationTitle: (json['notificationTitle'] ?? '').toString(),
      notificationMessage: (json['notificationMessage'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      priorityLevel: (json['priorityLevel'] ?? '').toString(),
      createdOn: (json['createdOn'] ?? '').toString(),
      createdBy: (json['createdBy'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
        notificationType,
        notificationTitle,
        notificationMessage,
        status,
        priorityLevel,
        createdOn,
        createdBy,
      ];
}
