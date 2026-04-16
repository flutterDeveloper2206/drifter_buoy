import 'package:equatable/equatable.dart';

import 'package:drifter_buoy/features/general_user/data/models/get_all_notifications_item.dart';

class GetAllNotificationsResponse extends Equatable {
  final int statusCode;
  final String message;
  final List<GetAllNotificationsItem> result;
  final bool isSuccess;

  const GetAllNotificationsResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  factory GetAllNotificationsResponse.fromJson(Map<String, dynamic> json) {
    final rawResult = json['result'];
    final items = <GetAllNotificationsItem>[];
    if (rawResult is List<dynamic>) {
      for (final entry in rawResult) {
        if (entry is Map<String, dynamic>) {
          items.add(GetAllNotificationsItem.fromJson(entry));
        } else if (entry is Map) {
          items.add(
            GetAllNotificationsItem.fromJson(
              Map<String, dynamic>.from(entry),
            ),
          );
        }
      }
    }

    final statusRaw = json['statusCode'];
    final statusCode = statusRaw is num
        ? statusRaw.toInt()
        : int.tryParse(statusRaw?.toString() ?? '') ?? 0;

    final isSuccessRaw = json['isSuccess'];
    final isSuccess = isSuccessRaw is bool
        ? isSuccessRaw
        : isSuccessRaw?.toString().toLowerCase() == 'true';

    return GetAllNotificationsResponse(
      statusCode: statusCode,
      message: (json['message'] ?? '').toString(),
      result: items,
      isSuccess: isSuccess,
    );
  }

  @override
  List<Object?> get props => [statusCode, message, result, isSuccess];
}
